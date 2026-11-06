// ======================================================
// RED DE CAMINOS DEL BOT (modo local)
// Se arma sola con las plataformas (oPlataformaPasable) y los muros (obj_wall)
// del nivel. El bot busca la ruta más corta y la sigue punto por punto.
// ======================================================
#macro BOT_NAV_STEP      32    // cada cuántos píxeles hay un punto sobre una plataforma
#macro BOT_NAV_JUMP_H    225   // lo más alto que sube el que mejor salta (salto 15 = 225). Cada bot usa solo los saltos que SU personaje alcanza
#macro BOT_NAV_JUMP_W    64    // lo más lejos que llega de lado en un salto hacia arriba
#macro BOT_NAV_REPLAN    60    // frames entre recalcular el camino
#macro BOT_NAV_STUCK     90    // frames sin avanzar antes de dar ese paso por malo y buscar otro camino
#macro BOT_NAV_GAP_W     128   // hueco más ancho que salta corriendo (a la misma altura, más o menos)

/// Arma la red una sola vez por nivel. La guarda en global.bot_nav.
function scr_bot_nav_build() {
	if (variable_global_exists("bot_nav") && is_struct(global.bot_nav) && global.bot_nav.rm == room) return;

	// 1. Superficies donde se puede parar
	var _surf = [];
	with (oPlataformaPasable) {
		var _banda = (object_index == oConveyor) ? push_speed : 0;   // las bandas empujan 2 px por frame
		array_push(_surf, { x0: bbox_left, x1: bbox_right + 1, top: bbox_top, pas: true, belt: _banda });
	}
	with (obj_wall) {
		if (bbox_top > 0 && bbox_top < room_height) {
			array_push(_surf, { x0: bbox_left, x1: bbox_right + 1, top: bbox_top, pas: false, belt: 0 });
		}
	}

	// Une las piezas pegadas a la misma altura (cada pedazo de banda es una pieza aparte
	// y el bot brincaba de pieza en pieza)
	// (ordena: tipo, altura, banda y de izquierda a derecha)
	for (var s = 1; s < array_length(_surf); s++) {
		var _cur = _surf[s];
		var _j = s - 1;
		while (_j >= 0) {
			var _o = _surf[_j];
			var _mayor = false;
			if (_o.pas != _cur.pas) _mayor = _o.pas;
			else if (_o.top != _cur.top) _mayor = (_o.top > _cur.top);
			else if (_o.belt != _cur.belt) _mayor = (_o.belt > _cur.belt);
			else _mayor = (_o.x0 > _cur.x0);
			if (!_mayor) break;
			_surf[_j + 1] = _o;
			_j -= 1;
		}
		_surf[_j + 1] = _cur;
	}
	var _unidas = [];
	for (var s = 0; s < array_length(_surf); s++) {
		var _sf = _surf[s];
		var _k = array_length(_unidas) - 1;
		if (_k >= 0) {
			var _u = _unidas[_k];
			if (_u.pas == _sf.pas && _u.top == _sf.top && _u.belt == _sf.belt && _sf.x0 <= _u.x1 + 1) {
				_u.x1 = max(_u.x1, _sf.x1);
				continue;
			}
		}
		array_push(_unidas, { x0: _sf.x0, x1: _sf.x1, top: _sf.top, pas: _sf.pas, belt: _sf.belt });
	}
	_surf = _unidas;

	// 2. Puntos sobre cada superficie (si arriba hay muro, ese punto no sirve)
	var _nodes = [];
	for (var s = 0; s < array_length(_surf); s++) {
		var _sf = _surf[s];
		var _a = _sf.x0 + 12;
		var _b = _sf.x1 - 12;
		if (_b < _a) { _a = (_sf.x0 + _sf.x1) / 2; _b = _a; }
		var _n = max(1, round((_b - _a) / BOT_NAV_STEP));
		for (var i = 0; i <= _n; i++) {
			var _nx = _a + (_b - _a) * i / _n;
			if (collision_rectangle(_nx - 9, _sf.top - 50, _nx + 10, _sf.top - 1, obj_wall, false, true) != noone) continue;
			var _end = 0;
			if (i == 0) _end = -1;
			if (i == _n) _end = 1;
			array_push(_nodes, { px: _nx, py: _sf.top, s: s, pas: _sf.pas, fin: _end, belt: _sf.belt, e: [] });
		}
	}

	// 3. Conexiones: caminar, saltar, dejarse caer
	var _count = array_length(_nodes);
	for (var i = 0; i < _count; i++) {
		var _A = _nodes[i];
		for (var j = 0; j < _count; j++) {
			if (i == j) continue;
			var _B = _nodes[j];
			var _dx = _B.px - _A.px;
			var _adx = abs(_dx);

			// Caminar: en la misma superficie, o a la de al lado si esta a la misma altura
			// Cada paso guarda h (que tan alto necesita saltar) y v (que tan rapido necesita correr)
			var _misma = (_A.s == _B.s);
			if (!_misma && _A.py == _B.py && _adx <= BOT_NAV_STEP + 8
			&& collision_rectangle(min(_A.px, _B.px), _A.py - 50, max(_A.px, _B.px), _A.py - 1, obj_wall, false, true) == noone) _misma = true;
			if (_misma) {
				if (_adx <= BOT_NAV_STEP + 8) {
					var _cw = _adx;
					if (_A.belt != 0 && sign(_dx) != 0 && sign(_A.belt) != sign(_dx)) _cw = _adx * 3;   // contra la banda cuesta mas
					array_push(_A.e, { to: j, t: "walk", c: _cw, h: 0, v: 0 });
				}
				continue;
			}

			var _dh = _A.py - _B.py;
			var _n_antes = array_length(_A.e);
			if (_dh > 0 && _dh <= BOT_NAV_JUMP_H && _adx <= BOT_NAV_JUMP_W) {
				if (collision_rectangle(_A.px - 9, _B.py - 50, _A.px + 10, _A.py - 1, obj_wall, false, true) == noone) {
					array_push(_A.e, { to: j, t: "jump", c: _adx + _dh + 40, h: _dh + 8, v: 0 });
				}
			}
			if (_dh < 0) {
				var _fall = -_dh;
				var _reach = 3 * sqrt(2 * _fall / 0.5);
				var _clear = (collision_rectangle(_B.px - 9, _A.py, _B.px + 10, _B.py - 1, obj_wall, false, true) == noone);
				if (_clear && _A.pas && _adx <= 20) {
					array_push(_A.e, { to: j, t: "drop", c: _fall * 0.5 + 20, h: 0, v: 0 });
				} else if (_clear && _A.fin != 0 && sign(_dx) == _A.fin && _adx <= _reach + 16) {
					array_push(_A.e, { to: j, t: "fall", c: _adx + _fall * 0.5, h: 0, v: max(0, _adx - 10) / (0.9 * 2 * sqrt(_fall)) });
				}
			}

			// Hueco: salta corriendo desde la orilla. A una plataforma casi a la misma altura,
			// o a una mas baja que esta separada (con el salto llega mas lejos que dejandose caer)
			if (array_length(_A.e) == _n_antes && _A.fin != 0 && sign(_dx) == _A.fin && _B.fin == -_A.fin
			&& _dh <= 40 && _dh >= -200) {
				// Cuanto puede subir antes de pegar con el techo (con el salto mas bajito, 169)
				var _libre = 0;
				while (_libre < 169 && collision_rectangle(_A.px - 9, _A.py - 51 - _libre - 4, _A.px + 10, _A.py - 51 - _libre - 1, obj_wall, false, true) == noone) _libre += 4;
				var _t = sqrt(_libre) / 0.5 + 2 * sqrt(_libre + max(0, -_dh));   // frames: sube y luego cae a la otra
				if (_dh > 0) _t = max(8, _t - 2 * sqrt(_libre) + 2 * sqrt(max(0, _libre - _dh)));
				var _vel = (_t > 0) ? max(0, _adx - 10) / (0.9 * _t) : 99;      // que tan rapido tiene que correr
				var _top = min(_A.py, _B.py);
				if (_adx <= 220 && _vel <= 4.5 && collision_rectangle(min(_A.px, _B.px), _top - 80, max(_A.px, _B.px), max(_A.py, _B.py) - 1, obj_wall, false, true) == noone) {
					array_push(_A.e, { to: j, t: "gap", c: _adx + 60, h: max(0, _dh) + 8, v: _vel });
				}
			}
		}
	}

	// 4. Plataformas de salto: desde el punto encima de la plataforma, a lo que queda arriba
	with (oSalto) {
		for (var _pi = 0; _pi < _count; _pi++) {
			var _PA = _nodes[_pi];
			if (abs(_PA.px - x) > 16 || abs(_PA.py - y) > 2) continue;
			for (var _pj = 0; _pj < _count; _pj++) {
				var _PB = _nodes[_pj];
				var _pdh = _PA.py - _PB.py;
				if (_pdh <= BOT_NAV_JUMP_H || _pdh > SALTO_ALTO - 24) continue;
				var _padx = abs(_PB.px - _PA.px);
				if (_padx > 150) continue;
				if (collision_rectangle(_PA.px - 9, _PB.py - 50, _PA.px + 10, _PA.py - 40, obj_wall, false, true) != noone) continue;
				array_push(_PA.e, { to: _pj, t: "pad", c: _padx + 80, h: 0, v: 0 });
			}
		}
	}

	global.bot_nav = { rm: room, nodes: _nodes };
}

/// El punto más cercano. Con _below = true busca el que está debajo de (x, y): el piso del objetivo.
function scr_bot_nav_nearest(_x, _y, _below) {
	var _nodes = global.bot_nav.nodes;
	var _best = -1;
	var _bd = 999999;
	for (var i = 0; i < array_length(_nodes); i++) {
		var _n = _nodes[i];
		if (_below && _n.py < _y - 12) continue;
		var _d = abs(_n.px - _x) + abs(_n.py - _y) * (_below ? 1 : 3);
		if (_d < _bd) { _bd = _d; _best = i; }
	}
	return _best;
}

/// Ruta más corta de un punto a otro (devuelve un array de índices, o [] si no hay).
/// _alto: lo que sube su salto. _vel: lo que corre. Se salta los pasos que su personaje no puede hacer.
/// _ban: pasos que ya le fallaron (los evita mientras haya otro camino).
function scr_bot_nav_path(_from, _to, _alto = 999, _vel = 99, _ban = undefined) {
	if (_from < 0 || _to < 0) return [];
	var _nodes = global.bot_nav.nodes;
	var _N = array_length(_nodes);
	var _dist = array_create(_N, 999999);
	var _prev = array_create(_N, -1);
	var _done = array_create(_N, false);
	_dist[_from] = 0;

	while (true) {
		var _u = -1;
		var _ud = 999999;
		for (var i = 0; i < _N; i++) {
			if (!_done[i] && _dist[i] < _ud) { _ud = _dist[i]; _u = i; }
		}
		if (_u < 0 || _u == _to) break;
		_done[_u] = true;
		var _edges = _nodes[_u].e;
		for (var k = 0; k < array_length(_edges); k++) {
			var _ed = _edges[k];
			if (_ed.h > _alto || _ed.v > _vel) continue;
			var _nd = _ud + _ed.c;
			if (!is_undefined(_ban) && variable_struct_exists(_ban, string(_u) + "_" + string(_ed.to))) _nd += 100000;
			if (_nd < _dist[_ed.to]) { _dist[_ed.to] = _nd; _prev[_ed.to] = _u; }
		}
	}

	if (_dist[_to] >= 999999) return [];
	var _path = [];
	var _v = _to;
	while (_v != -1) {
		array_insert(_path, 0, _v);
		_v = _prev[_v];
	}
	return _path;
}

/// Qué tipo de paso hay entre dos puntos: "walk", "jump", "drop", "fall", "gap" o "pad".
function scr_bot_nav_edge(_a, _b) {
	var _edges = global.bot_nav.nodes[_a].e;
	for (var k = 0; k < array_length(_edges); k++) {
		if (_edges[k].to == _b) return _edges[k].t;
	}
	return "walk";
}

/// Un paso le fallo: no lo vuelve a intentar en un rato (_frames)
function scr_bot_nav_banear(_frames) {
	if (nav_i < 1 || nav_i >= array_length(nav_path)) return;
	variable_struct_set(nav_ban, string(nav_path[nav_i - 1]) + "_" + string(nav_path[nav_i]), nav_f + _frames);
}

/// Mueve al bot hacia (_tx, _ty) siguiendo la red. Pone key_left, key_right, key_jump y drop_timer.
/// Se llama desde el Step de oPlayer2_local y de los bots de sala (scr_botnet_step), con el bot como instancia.
function scr_bot_nav_move(_tx, _ty) {
	if (!variable_global_exists("bot_nav") || !is_struct(global.bot_nav) || global.bot_nav.rm != room) scr_bot_nav_build();
	var _nodes = global.bot_nav.nodes;

	// Memoria de lo que le ha fallado (se crea sola la primera vez)
	if (!variable_instance_exists(id, "nav_ban")) {
		nav_ban = {};
		nav_f = 0;
		nav_tries = 0;
		nav_fails = 0;
		nav_escape = 0;
		nav_esc_dir = 1;
	}
	nav_f += 1;
	if (nav_f mod 60 == 0) {   // borra los fallos viejos
		var _ks = variable_struct_get_names(nav_ban);
		for (var k = 0; k < array_length(_ks); k++) {
			if (nav_ban[$ _ks[k]] <= nav_f) variable_struct_remove(nav_ban, _ks[k]);
		}
	}

	var _onplat = place_meeting(x, y + 1, oPlataformaPasable) && !place_meeting(x, y, oPlataformaPasable) && vsp >= 0;
	var _grounded = (place_meeting(x, y + 1, obj_wall) && vsp >= 0) || (_onplat && drop_timer <= 0);
	var _feet = bbox_bottom + 1;

	// Se atoro varias veces seguidas: un rato a lo loco (corre a un lado y brinca) para zafarse
	if (nav_escape > 0) {
		nav_escape -= 1;
		if (nav_esc_dir > 0) key_right = true;
		else key_left = true;
		if (_grounded && nav_escape mod 20 == 0) key_jump = true;
		return;
	}

	// Lo que puede SU personaje: que tan alto salta y que tan rapido corre (mas lento con la bandera)
	var _alto = sqr(jumpsp);
	var _vel = walksp;
	if (has_flag) {
		if (variable_instance_exists(id, "bot_datos")) _vel *= bot_datos.bandera;
		else _vel *= scr_pj_mult_bandera();
	}

	if (nav_replan > 0) nav_replan -= 1;
	if (_grounded && (array_length(nav_path) == 0 || nav_replan <= 0)) {
		var _a = scr_bot_nav_nearest(x, _feet, false);
		var _b = scr_bot_nav_nearest(_tx, _ty, true);
		nav_path = scr_bot_nav_path(_a, _b, _alto, _vel, nav_ban);
		nav_i = 1;
		nav_replan = BOT_NAV_REPLAN;
		nav_best = 999999;
		nav_stuck = 0;
	}

	var _gx = _tx;
	var _type = "walk";
	var _n = undefined;
	if (nav_i < array_length(nav_path)) {
		_n = _nodes[nav_path[nav_i]];
		_gx = _n.px;
		_type = scr_bot_nav_edge(nav_path[nav_i - 1], nav_path[nav_i]);
		if (_grounded && abs(x - _n.px) < 10 && abs(_feet - _n.py) < 4) {
			nav_i += 1;
			nav_best = 999999;
			nav_fails = 0;
			nav_tries = 0;
		}
	}

	var _dx = _gx - x;
	if (abs(_dx) > 4) {
		if (_dx > 0) key_right = true;
		else key_left = true;
	}

	// Subiendo a una plataforma SOLIDA: primero sube y luego se mete encima.
	// (Antes se metia de lado desde que saltaba, chocaba con la cabeza abajo y se quedaba brincando)
	if (!is_undefined(_n) && !_grounded && _type == "jump" && _feet > _n.py && (key_left || key_right)) {
		var _st = key_right ? 4 : -4;
		if (bbox_top >= _n.py && collision_rectangle(bbox_left + _st, _n.py, bbox_right + _st, bbox_top, obj_wall, false, true) != noone) {
			key_left = false;
			key_right = false;
		}
	}

	// Dejarse caer de una orilla: sigue caminando hacia ese lado hasta caer
	// (si el siguiente punto quedaba a 4 px se quedaba parado en la orilla)
	if (!is_undefined(_n) && _grounded && _type == "fall" && _feet < _n.py - 4) {
		var _de = _nodes[nav_path[nav_i - 1]];
		if (_n.px > _de.px) { key_right = true; key_left = false; }
		else { key_left = true; key_right = false; }
	}

	// Sin camino (destino fuera de la red): se porta como antes y salta si el objetivo está arriba
	if (is_undefined(_n) && _grounded && _ty < _feet - 60 && abs(_tx - x) < BOT_NAV_JUMP_W) key_jump = true;

	if (!is_undefined(_n) && _grounded) {
		// Salto hacia arriba: primero se para justo en el punto de despegue y salta derechito
		// (antes saltaba desde lejos y se quedaba debajo del techo brincando)
		if (_type == "jump") {
			var _sal = _nodes[nav_path[nav_i - 1]];
			if (abs(x - _sal.px) > 4) {
				key_left = false;
				key_right = false;
				if (_sal.px > x) key_right = true;
				else key_left = true;
			}
			else {
				key_jump = true;
				key_left = false;
				key_right = false;
				nav_tries += 1;
				if (nav_tries > 3) {   // ya lo intento 3 veces y no sube: busca otro camino
					scr_bot_nav_banear(900);
					nav_path = [];
					nav_tries = 0;
				}
			}
		}
		if (_type == "drop" && abs(x - _n.px) < 16 && _onplat) drop_timer = 14;
		// Plataforma de salto: parado encima, salta (oSalto lo lanza alto) y en el aire va hacia el destino
		if (_type == "pad") {
			var _desde = _nodes[nav_path[nav_i - 1]];
			if (abs(x - _desde.px) < 12 && abs(_feet - _desde.py) < 6) { key_jump = true; nav_quiere_pad = true; }
		}
		// Hueco: salta ya en la orilla, corriendo hacia el otro lado
		if (_type == "gap") {
			var _from = _nodes[nav_path[nav_i - 1]];
			if (abs(x - _from.px) < 14 && abs(_feet - _from.py) < 6) key_jump = true;
		}
	}

	// Banda en contra: caminando casi no avanza, brinca (en el aire no lo empuja)
	if (_grounded && (key_left || key_right)) {
		var _cv = instance_place(x, y + 1, oConveyor);
		if (_cv != noone && _cv.push_speed != 0 && ((_cv.push_speed > 0) != key_right)) key_jump = true;
	}

	// Atascado: si no se acerca a su siguiente punto, ese paso no sirve. Lo evita y busca otro camino
	var _d = abs(_dx);
	if (!is_undefined(_n)) _d += abs(_feet - _n.py);
	if (_d < nav_best - 2) {
		nav_best = _d;
		nav_stuck = 0;
	} else {
		nav_stuck += 1;
		if (nav_stuck > BOT_NAV_STUCK) {
			if (!is_undefined(_n)) {
				scr_bot_nav_banear(600);
				nav_fails += 1;
				if (nav_fails >= 2) {
					nav_escape = 45;
					nav_esc_dir = choose(-1, 1);
					nav_fails = 0;
				}
			}
			nav_path = [];
			nav_stuck = 0;
		}
	}
}
