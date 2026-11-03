// ======================================================
// RED DE CAMINOS DEL BOT (modo local)
// Se arma sola con las plataformas (oPlataformaPasable) y los muros (obj_wall)
// del nivel. El bot busca la ruta más corta y la sigue punto por punto.
// ======================================================
#macro BOT_NAV_STEP      32    // cada cuántos píxeles hay un punto sobre una plataforma
#macro BOT_NAV_JUMP_H    150   // lo más alto que sube con un salto (salto 13, gravedad 0.5 = 169)
#macro BOT_NAV_JUMP_W    64    // lo más lejos que llega de lado en un salto hacia arriba
#macro BOT_NAV_REPLAN    60    // frames entre recalcular el camino
#macro BOT_NAV_STUCK     120   // frames sin avanzar antes de rehacer el camino

/// Arma la red una sola vez por nivel. La guarda en global.bot_nav.
function scr_bot_nav_build() {
	if (variable_global_exists("bot_nav") && is_struct(global.bot_nav) && global.bot_nav.rm == room) return;

	// 1. Superficies donde se puede parar
	var _surf = [];
	with (oPlataformaPasable) {
		array_push(_surf, { x0: bbox_left, x1: bbox_right + 1, top: bbox_top, pas: true });
	}
	with (obj_wall) {
		if (bbox_top > 0 && bbox_top < room_height) {
			array_push(_surf, { x0: bbox_left, x1: bbox_right + 1, top: bbox_top, pas: false });
		}
	}

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
			array_push(_nodes, { px: _nx, py: _sf.top, s: s, pas: _sf.pas, fin: _end, e: [] });
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

			if (_A.s == _B.s) {
				if (_adx <= BOT_NAV_STEP + 8) array_push(_A.e, { to: j, t: "walk", c: _adx });
				continue;
			}

			var _dh = _A.py - _B.py;
			if (_dh > 0 && _dh <= BOT_NAV_JUMP_H && _adx <= BOT_NAV_JUMP_W) {
				if (collision_rectangle(_A.px - 9, _B.py - 50, _A.px + 10, _A.py - 1, obj_wall, false, true) == noone) {
					array_push(_A.e, { to: j, t: "jump", c: _adx + _dh + 40 });
				}
			}
			if (_dh < 0) {
				var _fall = -_dh;
				var _reach = 3 * sqrt(2 * _fall / 0.5);
				var _clear = (collision_rectangle(_B.px - 9, _A.py, _B.px + 10, _B.py - 1, obj_wall, false, true) == noone);
				if (_clear && _A.pas && _adx <= 20) {
					array_push(_A.e, { to: j, t: "drop", c: _fall * 0.5 + 20 });
				} else if (_clear && _A.fin != 0 && sign(_dx) == _A.fin && _adx <= _reach + 16) {
					array_push(_A.e, { to: j, t: "fall", c: _adx + _fall * 0.5 });
				}
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
function scr_bot_nav_path(_from, _to) {
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
			var _nd = _ud + _ed.c;
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

/// Qué tipo de paso hay entre dos puntos: "walk", "jump", "drop" o "fall".
function scr_bot_nav_edge(_a, _b) {
	var _edges = global.bot_nav.nodes[_a].e;
	for (var k = 0; k < array_length(_edges); k++) {
		if (_edges[k].to == _b) return _edges[k].t;
	}
	return "walk";
}

/// Mueve al bot hacia (_tx, _ty) siguiendo la red. Pone key_left, key_right, key_jump y drop_timer.
/// Se llama desde el Step de oPlayer2_local, con el bot como instancia.
function scr_bot_nav_move(_tx, _ty) {
	if (!variable_global_exists("bot_nav") || !is_struct(global.bot_nav) || global.bot_nav.rm != room) scr_bot_nav_build();
	var _nodes = global.bot_nav.nodes;

	var _onplat = place_meeting(x, y + 1, oPlataformaPasable) && !place_meeting(x, y, oPlataformaPasable) && vsp >= 0;
	var _grounded = (place_meeting(x, y + 1, obj_wall) && vsp >= 0) || (_onplat && drop_timer <= 0);
	var _feet = bbox_bottom + 1;

	if (nav_replan > 0) nav_replan -= 1;
	if (_grounded && (array_length(nav_path) == 0 || nav_replan <= 0)) {
		var _a = scr_bot_nav_nearest(x, _feet, false);
		var _b = scr_bot_nav_nearest(_tx, _ty, true);
		nav_path = scr_bot_nav_path(_a, _b);
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
		}
	}

	var _dx = _gx - x;
	if (abs(_dx) > 4) {
		if (_dx > 0) key_right = true;
		else key_left = true;
	}

	// Sin camino (destino fuera de la red): se porta como antes y salta si el objetivo está arriba
	if (is_undefined(_n) && _grounded && _ty < _feet - 60 && abs(_tx - x) < BOT_NAV_JUMP_W) key_jump = true;

	if (!is_undefined(_n) && _grounded) {
		if (_type == "jump" && abs(x - _n.px) <= BOT_NAV_JUMP_W) key_jump = true;
		if (_type == "drop" && abs(x - _n.px) < 16 && _onplat) drop_timer = 14;
	}

	// Atascado: si no se acerca a su siguiente punto, rehace el camino
	var _d = abs(_dx);
	if (!is_undefined(_n)) _d += abs(_feet - _n.py);
	if (_d < nav_best - 2) {
		nav_best = _d;
		nav_stuck = 0;
	} else {
		nav_stuck += 1;
		if (nav_stuck > BOT_NAV_STUCK) {
			nav_path = [];
			nav_stuck = 0;
		}
	}
}
