// ======================================================
// EQUIPO Y OBJETIVO (selección, intro y ayudas en la partida)
// ======================================================

/// Mi equipo, aunque todavía no haya nacido mi personaje.
/// En línea manda el equipo que dio el servidor al entrar a la sala (global.myTeam puede venir de la partida anterior).
/// En local, el de global.myTeam. Si no hay ninguno, por mi id (como antes).
function scr_my_team() {
	var _online = variable_global_exists("ONLINE") && global.ONLINE;
	if (_online && variable_global_exists("serverTeam") && global.serverTeam != "") return global.serverTeam;
	if (variable_global_exists("myTeam") && global.myTeam != "") return global.myTeam;
	if (variable_global_exists("clientId")) return (global.clientId % 2 == 0) ? "AZUL" : "ROJO";
	return "AZUL";
}

/// Pone a tu jugador en la base de SU equipo (al nacer y al reaparecer en línea).
/// Si la base lo deja metido en el piso, lo sube hasta que quede libre.
function scr_spawn_en_base() {
	var _team = scr_my_team();
	var _base = (_team == "AZUL") ? obj_base_blue : obj_base_red;
	if (instance_exists(_base)) {
		x = _base.x;
		y = _base.y;
	} else {
		x = (_team == "AZUL") ? 100 : room_width - 100;
		y = 400;
	}
	var _n = 0;
	while (place_meeting(x, y, obj_wall) && _n < 300) { y -= 1; _n++; }
	if (variable_instance_exists(id, "hsp")) hsp = 0;
	if (variable_instance_exists(id, "vsp")) vsp = 0;
	if (variable_instance_exists(id, "push_h")) push_h = 0;
	if (variable_instance_exists(id, "latest_x")) latest_x = x;
	if (variable_instance_exists(id, "latest_y")) latest_y = y;
}

function scr_team_color(_team) {
	return (_team == "AZUL") ? make_color_rgb(31, 155, 255) : make_color_rgb(255, 42, 58);
}

/// ¿Qué tengo que hacer ahora? Devuelve { txt, tx, ty, col, label, tip_key, tip }
function scr_objetivo(_me) {
	var _team   = scr_my_team();
	var _enemy  = (_team == "AZUL") ? "ROJO" : "AZUL";
	var _fEnemy = (_team == "AZUL") ? oFlag  : oFlag2;   // la que tengo que robar
	var _fMine  = (_team == "AZUL") ? oFlag2 : oFlag;    // la mía
	var _base   = (_team == "AZUL") ? obj_base_blue : obj_base_red;
	var _o = { txt: "", tx: undefined, ty: undefined, col: c_white, label: "", tip_key: "", tip: "", state: "n" };

	// 1. Llevo la bandera: a mi base
	if (instance_exists(_me) && variable_instance_exists(_me, "has_flag") && _me.has_flag) {
		_o.state = "c";
		_o.txt = "LA TIENES! LLEVALA A TU BASE";
		_o.col = scr_team_color(_team);
		_o.label = "TU BASE";
		_o.tip_key = "carry";
		_o.tip = "Vas mas lento con la bandera";
		if (instance_exists(_base)) { var _b = instance_find(_base, 0); _o.tx = _b.x; _o.ty = _b.y; }
		return _o;
	}

	// 2. Se robaron la mía: atrapar al que la lleva
	if (instance_exists(_fMine)) {
		var _f = instance_find(_fMine, 0);
		if (_f.has_flag && variable_instance_exists(_f, "portador_instancia") && instance_exists(_f.portador_instancia) && _f.portador_instancia != _me) {
			var _c = _f.portador_instancia;
			var _nm = "AL LADRON";
			if (variable_instance_exists(_c, "Name") && is_string(_c.Name) && _c.Name != "") _nm = string_upper(_c.Name);
			_o.state = "s";
			_o.txt = "TE ROBARON LA BANDERA! ATRAPA A " + _nm;
			_o.col = make_color_rgb(200, 20, 30);
			_o.label = _nm;
			_o.tx = _c.x; _o.ty = _c.y;
			_o.tip_key = "stolen";
			_o.tip = "Si lo eliminas, la suelta: tocala para devolverla";
			return _o;
		}
	}

	// 3. Normal: ir por la bandera rival
	_o.txt = "VE POR LA BANDERA " + _enemy;
	_o.col = c_black;
	_o.label = "BANDERA";
	_o.tip_key = "flag";
	_o.tip = "Toca la bandera para agarrarla";
	if (instance_exists(_fEnemy)) { var _e = instance_find(_fEnemy, 0); _o.tx = _e.x; _o.ty = _e.y; }
	return _o;
}

/// Pastilla de objetivo + flecha en el borde + globito de ayuda la primera vez.
/// Va en el Draw GUI del jugador.
function scr_draw_objetivo(_me) {
	if (variable_global_exists("game_over") && global.game_over) return;
	var _o = scr_objetivo(_me);
	var _gw = display_get_gui_width();
	var _gh = display_get_gui_height();
	// En línea la pastilla y la flecha las reemplazan el marcador vivo, los banners y las flechas de scr_feedback.
	// Aquí solo queda el globito de ayuda. En local todo sigue igual.
	var _solo_ayuda = variable_global_exists("ONLINE") && global.ONLINE;
	var _cy = scr_reloj_visible() ? 196 : 160;
	if (!_solo_ayuda) {

	// --- Pastilla bajo el marcador ---
	draw_set_font(fnt_menu);
	draw_set_halign(fa_center);
	draw_set_valign(fa_middle);
	var _s  = 1;
	var _tw = string_width(_o.txt) * _s + 60;
	var _cx = _gw / 2;
	_cy = scr_reloj_visible() ? 196 : 160;   // si hay reloj bajo el marcador, la pastilla baja un poco
	var _a  = 0.75;
	if (_o.state == "s") _a = (current_time div 300) mod 2 == 0 ? 0.9 : 0.6;   // parpadea si te robaron
	draw_set_alpha(_a);
	draw_roundrect_color_ext(_cx - _tw/2, _cy - 24, _cx + _tw/2, _cy + 24, 40, 40, _o.col, _o.col, false);
	draw_set_alpha(1);
	draw_set_colour(c_white);
	draw_roundrect_ext(_cx - _tw/2, _cy - 24, _cx + _tw/2, _cy + 24, 40, 40, true);
	draw_text_transformed_color(_cx + 2, _cy + 2, _o.txt, _s, _s, 0, c_black, c_black, c_black, c_black, 1);
	draw_text_transformed(_cx, _cy, _o.txt, _s, _s, 0);

	// --- Flecha en el borde cuando el objetivo no se ve ---
	if (!is_undefined(_o.tx)) {
		var _vx = camera_get_view_x(view_camera[0]);
		var _vy = camera_get_view_y(view_camera[0]);
		var _vw = camera_get_view_width(view_camera[0]);
		var _vh = camera_get_view_height(view_camera[0]);
		if (_o.tx < _vx || _o.tx > _vx + _vw || _o.ty < _vy || _o.ty > _vy + _vh) {
			var _kx = _gw / _vw;
			var _ky = _gh / _vh;
			var _dir = point_direction(_vx + _vw/2, _vy + _vh/2, _o.tx, _o.ty);
			// La flecha se queda entre la franja de arriba (vida, marcador, reloj, pastilla, arma)
			// y lo de abajo (ping; en el celular, los joysticks). Así nunca queda tapada ni en una esquina.
			var _m = 60;
			var _ymin = _cy + 60;
			var _ymax = touch_mode() ? _gh - 320 : _gh - 80;
			if (_ymax < _ymin) _ymax = _ymin;
			var _px = clamp((_o.tx - _vx) * _kx, _m, _gw - _m);
			var _py = clamp((_o.ty - _vy) * _ky, _ymin, _ymax);
			var _col = (_o.state == "n") ? scr_team_color((scr_my_team() == "AZUL") ? "ROJO" : "AZUL") : ((_o.state == "c") ? scr_team_color(scr_my_team()) : c_yellow);
			draw_sprite_ext(sTroangle, 0, _px + lengthdir_x(25, _dir), _py + lengthdir_y(25, _dir), 1, 1, _dir, _col, 1);
			draw_text_transformed_color(_px - lengthdir_x(30, _dir) + 2, _py - lengthdir_y(30, _dir) + 2, _o.label, 0.8, 0.8, 0, c_black, c_black, c_black, c_black, 1);
			draw_text_transformed_color(_px - lengthdir_x(30, _dir), _py - lengthdir_y(30, _dir), _o.label, 0.8, 0.8, 0, _col, _col, c_white, c_white, 1);
		}
	}

	} // fin pastilla y flecha (solo en local)

	// --- Globito de ayuda (solo la primera vez que pasa cada cosa) ---
	if (!variable_global_exists("tips_vistos")) {
		global.tips_vistos = {};
		ini_open("ctf_ayudas.ini");
		global.tips_vistos.flag   = ini_read_real("ayudas", "flag", 0);
		global.tips_vistos.carry  = ini_read_real("ayudas", "carry", 0);
		global.tips_vistos.stolen = ini_read_real("ayudas", "stolen", 0);
		ini_close();
		global.tip_actual = "";
		global.tip_timer = 0;
	}
	if (global.tip_timer <= 0 && _o.tip_key != "" && global.tips_vistos[$ _o.tip_key] == 0) {
		global.tip_actual = _o.tip;
		global.tip_timer = 60 * 5;
		global.tips_vistos[$ _o.tip_key] = 1;
		ini_open("ctf_ayudas.ini");
		ini_write_real("ayudas", _o.tip_key, 1);
		ini_close();
	}
	if (global.tip_timer > 0 && instance_exists(_me)) {
		global.tip_timer -= 1;
		var _vx2 = camera_get_view_x(view_camera[0]);
		var _vy2 = camera_get_view_y(view_camera[0]);
		var _bx = (_me.x - _vx2) * (_gw / camera_get_view_width(view_camera[0]));
		var _by = (_me.y - _vy2) * (_gh / camera_get_view_height(view_camera[0])) - 120;
		var _w2 = string_width(global.tip_actual) * 0.8 + 30;
		draw_set_alpha(min(1, global.tip_timer / 20));
		draw_set_colour(c_black);
		draw_roundrect_ext(_bx - _w2/2 + 4, _by - 22 + 4, _bx + _w2/2 + 4, _by + 22 + 4, 12, 12, false);
		draw_set_colour(c_white);
		draw_roundrect_ext(_bx - _w2/2, _by - 22, _bx + _w2/2, _by + 22, 12, 12, false);
		draw_triangle(_bx - 12, _by + 21, _bx + 12, _by + 21, _bx, _by + 36, false);
		draw_text_transformed_color(_bx, _by, global.tip_actual, 0.8, 0.8, 0, c_black, c_black, c_black, c_black, draw_get_alpha());
		draw_set_alpha(1);
	}

	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	draw_set_colour(c_white);
}

// ======================================================
// BOTS EN LA SALA PRIVADA (en linea)
// Los espacios vacios de la sala se llenan con bots (salen con la etiqueta BOT).
// - El lider los maneja: cada bot es un oOtherPlayer con bot_local = true que se mueve
//   solo (scr_botnet_step) y le manda a los demas como va (evento "bots_sp").
// - En las otras pantallas el bot es un oOtherPlayer normal: se ve igual que una persona.
// - Los golpes a un bot (evento "hit" a su clientId) los cacha SendEventToClient:
//   en el lider se aplican ahi mismo y en los demas se le pasan al lider ("bot_hit").
// - Si el lider se va, el nuevo lider toma a los bots donde iban (scr_botnet_tomar).
//   Si ya no queda ninguna persona, la sala se cierra sola (asi funciona el servidor).
// ======================================================
#macro BOTNET_ID_BASE   -1000   // los bots usan clientId -1000, -1001, ... (los de verdad son 1, 2, 3...)
#macro BOTNET_SP_CADA   2       // cada cuantos frames el lider manda como van los bots
#macro BOTNET_VISTA     420     // hasta donde ve y dispara
#macro BOTNET_PERSIGUE  300     // si ve a un rival mas cerca que esto, va por el
#macro BOTNET_RESPAWN   120     // frames muerto antes de reaparecer (igual que tu)
#macro BOTNET_DANO      10      // dano de su pistola
#macro BOTNET_GOLPE     20      // dano de su golpe

/// Es el clientId de un bot?
function scr_botnet_es_id(_cid) {
	return is_numeric(_cid) && _cid <= BOTNET_ID_BASE;
}

/// Nombre del bot de la casilla _g (0-3 azul, 4-7 rojo). Sale del codigo de la sala,
/// asi todos ven el mismo nombre en la sala y en la partida.
function scr_botnet_nombre(_g) {
	var _n = ["Kira", "Zeta", "Nova", "Rex", "Luna", "Tito", "Duke", "Bruno",
	          "Lola", "Rocco", "Nina", "Yuki", "Toby", "Mia", "Pepe", "Max"];
	var _txt = variable_global_exists("myRoomCode") ? string(global.myRoomCode) : "";
	var _h = 0;
	for (var i = 1; i <= string_length(_txt); i++) _h += ord(string_char_at(_txt, i)) * i;
	return _n[(_h + _g * 5) mod array_length(_n)];
}

/// Pone al lider primero en la lista de su equipo.
function scr_sala_lider_primero(_l) {
	for (var i = 1; i < array_length(_l); i++) {
		if (_l[i].lider) {
			var _it = _l[i];
			array_delete(_l, i, 1);
			array_insert(_l, 0, _it);
			break;
		}
	}
	return _l;
}

/// Las casillas de la sala privada, por equipo: primero las personas y luego los bots.
/// Cada casilla: { tipo: "yo" | "humano" | "bot", nombre, cid, lider }
function scr_sala_slots() {
	var _max = (variable_global_exists("max_players_allowed") && global.max_players_allowed >= 2) ? global.max_players_allowed : 2;
	var _cupo = max(1, _max div 2);
	var _az = [];
	var _ro = [];
	var _lider = oBrain.AmIPseudoHost ? global.clientId : oBrain.pseudoHostClientId;

	// Yo (el equipo me lo dio el servidor al entrar)
	var _mi_eq = (variable_global_exists("serverTeam") && global.serverTeam != "") ? global.serverTeam : "AZUL";
	var _yo = { tipo: "yo", nombre: global.myName, cid: global.clientId, lider: (_lider == global.clientId), eq: _mi_eq };
	if (_mi_eq == "ROJO") array_push(_ro, _yo); else array_push(_az, _yo);

	// Las demas personas, con el equipo que nos avisaron (sync_lobby_name)
	var _otros = [];
	with (oOtherPlayer) {
		if (es_bot) continue;
		var _nm = ds_map_find_value(global.playerNames, string(clientId));
		if (is_undefined(_nm) || _nm == "") _nm = (Name != "" && Name != "Cargando...") ? Name : "Conectando...";
		array_push(_otros, { tipo: "humano", nombre: _nm, cid: clientId, lider: (clientId == _lider), eq: lobby_team });
	}
	for (var i = 0; i < array_length(_otros); i++) {
		var _o = _otros[i];
		var _eq = _o.eq;
		// Si todavia no sabemos su equipo, va al que tiene menos (igual que hace el servidor)
		if (_eq != "AZUL" && _eq != "ROJO") _eq = (array_length(_az) <= array_length(_ro)) ? "AZUL" : "ROJO";
		if (_eq == "ROJO") array_push(_ro, _o); else array_push(_az, _o);
	}
	_az = scr_sala_lider_primero(_az);
	_ro = scr_sala_lider_primero(_ro);

	// Lo que falta en cada equipo, bots
	for (var k = array_length(_az); k < _cupo; k++) array_push(_az, { tipo: "bot", nombre: scr_botnet_nombre(k), cid: BOTNET_ID_BASE - k, lider: false, eq: "AZUL" });
	for (var k = array_length(_ro); k < _cupo; k++) array_push(_ro, { tipo: "bot", nombre: scr_botnet_nombre(4 + k), cid: BOTNET_ID_BASE - 4 - k, lider: false, eq: "ROJO" });

	return { azul: _az, rojo: _ro, cupo: _cupo };
}

/// Donde va la casilla _k de un equipo (las mismas medidas de siempre: 400 x 60).
function scr_sala_slot_pos(_rojo, _k) {
	var _gw = display_get_gui_width();
	return [_rojo ? (_gw / 2) + 50 : (_gw / 2) - 450, 200 + _k * 80];
}

/// Cuantos bots van a entrar si el lider empieza ahora.
function scr_sala_cuantos_bots() {
	var _s = scr_sala_slots();
	var _n = 0;
	for (var i = 0; i < array_length(_s.azul); i++) if (_s.azul[i].tipo == "bot") _n++;
	for (var i = 0; i < array_length(_s.rojo); i++) if (_s.rojo[i].tipo == "bot") _n++;
	return _n;
}

/// Los bots que entran a la partida: [{ i: clientId, n: nombre, t: equipo, r: rol }]
function scr_sala_bots() {
	var _s = scr_sala_slots();
	var _l = [];
	for (var _t = 0; _t < 2; _t++) {
		var _lista = (_t == 0) ? _s.azul : _s.rojo;
		var _primero = true;
		for (var i = 0; i < array_length(_lista); i++) {
			var _it = _lista[i];
			if (_it.tipo != "bot") continue;
			// En 3 vs 3 y 4 vs 4 el primer bot de cada equipo cuida la base
			var _rol = (_s.cupo >= 3 && _primero) ? "defensa" : "ataque";
			_primero = false;
			array_push(_l, { i: _it.cid, n: _it.nombre, t: _it.eq, r: _rol });
		}
	}
	return _l;
}

/// El oOtherPlayer de un bot (o noone).
function scr_botnet_buscar(_bid) {
	var _r = noone;
	with (oOtherPlayer) if (clientId == _bid) _r = id;
	return _r;
}

/// Lo llama SendEventToClient cuando el destino es un bot. Solo importan los golpes.
function scr_botnet_evento(_bid, _ev, _m) {
	// Granada cegadora: el bot se queda sin ver (sin pensar ni disparar) un rato
	if (_ev == "cegar") {
		if (oBrain.AmIPseudoHost) {
			var _bc = scr_botnet_buscar(_bid);
			if (_bc != noone) with (_bc) { scr_efx_init2(); efx_ciego_t = max(efx_ciego_t, real(_m.t)); }
		} else {
			var _hc = oBrain.pseudoHostClientId;
			if (is_numeric(_hc) && _hc >= 0 && _hc != global.clientId) SendEventToClient(_hc, "bot_cegar", { b: _bid, m: _m });
		}
		return;
	}
	if (_ev != "hit") return;
	if (oBrain.AmIPseudoHost) {
		scr_botnet_dano(scr_botnet_buscar(_bid), _m, global.clientId);
	} else {
		var _h = oBrain.pseudoHostClientId;
		if (is_numeric(_h) && _h >= 0 && _h != global.clientId) SendEventToClient(_h, "bot_hit", { b: _bid, m: _m });
	}
}

/// El lider crea los bots al empezar el mapa (oBrain, Room Start).
function scr_botnet_crear_todos() {
	if (!global.ONLINE || room == rm_menu || !oBrain.AmIPseudoHost) return;
	if (!variable_global_exists("botnet_defs") || !is_array(global.botnet_defs)) return;
	for (var i = 0; i < array_length(global.botnet_defs); i++) {
		var _d = global.botnet_defs[i];
		var _b = instance_create_layer(0, 0, global.OtherPlayersLayerName, oOtherPlayer);
		_b.clientId = _d.i;
		// h = nombre de persona (partida rapida); si no, como siempre "BOT ..."
		var _nom = (variable_struct_exists(_d, "h") && _d.h) ? _d.n : "BOT " + _d.n;
		var _pj = variable_struct_exists(_d, "pj") ? _d.pj : irandom(3);
		with (_b) {
			scr_botnet_init(_d.t, _nom, _pj);
			bot_rol = _d.r;
		}
	}
	if (array_length(global.botnet_defs) > 0) global.botnet_partida = true;
}

/// Arma al bot (con el oOtherPlayer como instancia).
function scr_botnet_init(_team, _name, _pj) {
	es_bot = true;
	bot_local = true;
	team = _team;
	lobby_team = _team;
	thisPlayerTeam = _team;
	Name = _name;
	TAG = "";
	isReady = true;
	isHost = false;
	mySelectedPJ = clamp(_pj, 0, 3);
	bot_pj = mySelectedPJ;
	bot_datos = scr_pj_datos(bot_pj);
	switch (bot_pj) {
		case 1:  bot_anim = { idle: spr_miguel_idle,   walk: spr_miguel_walk,   dead: spr_miguel_dead,   hit: spr_miguel_hit };   break;
		case 2:  bot_anim = { idle: spr_marina_idle,   walk: spr_marina_walk,   dead: spr_marina_dead,   hit: spr_marina_hit };   break;
		case 3:  bot_anim = { idle: spr_sargento_idle, walk: spr_sargento_walk, dead: spr_sargento_dead, hit: spr_sargento_hit }; break;
		default: bot_anim = { idle: spr_player_idle,   walk: spr_player_walk,   dead: spr_player_dead,   hit: spr_player_hit };   break;
	}

	// Vida y movimiento del personaje (los mismos numeros que tu)
	hp = bot_datos.vida;
	max_health = hp;
	enemyHealth = hp;
	enemyHealth_net = hp;
	walksp = bot_datos.vel;
	jumpsp = bot_datos.salto;
	grv = 0.5;
	hsp = 0;
	vsp = 0;
	push_h = 0;
	drop_timer = 0;
	is_grounded = false;
	key_left = false;
	key_right = false;
	key_jump = false;

	// Camino (scr_bot_nav)
	nav_path = [];
	nav_i = 0;
	nav_replan = 0;
	nav_best = 999999;
	nav_stuck = 0;
	nav_quiere_pad = false;

	// Estado
	state = PLAYERSTATE.IDLE;
	isDead = false;
	bot_respawn = 0;
	bot_invul = 0;
	invulnerable = false;
	has_flag = false;
	has_shield = false;
	visible = true;
	image_alpha = 1;
	image_xscale = 1.5;
	image_yscale = 1.5;
	image_speed = 1;
	sprite_index = bot_anim.idle;
	hit_bloqueo_timer = 0;
	crush_cd = 0;

	// Arma: empieza con pistola (balas sin fin) y agarra armas del suelo
	weapon.angle = 0;
	weapon.frequency = 0;
	bot_reload = 0;
	bot_rafaga = 0;
	bot_rafaga_t = 0;
	scr_botnet_pistola();
	scr_botnet_equipo_azar();   // EQUIPAMIENTO: empieza con un arma al azar (scr_armas)

	// Habilidad de su personaje (scr_botnet_hab_usar)
	bot_hab_cd = irandom_range(60, 180);
	bot_dash_t = 0;
	bot_dash_vis = 0;
	bot_cor_t = 0;
	bot_sin_danio = 0;
	bot_regen_acc = 0;
	bot_cura_acc = 0;
	bot_cura_fx = 0;
	hab_co = false;
	hab_da = false;
	hab_gf = 0;
	hab_gx = x;
	hab_gy = y;
	melee_cd = 0;
	melee_active = 0;
	recoil_kick = 0;
	recoil_angle = 0;
	bot_error = 0;

	// Quien lo elimino
	kills = 0;
	last_killer = "";
	last_killer_id = -1;
	last_reason = "pvp";

	// Que hace
	bot_rol = "ataque";
	bot_patrulla_x = 0;
	bot_patrulla_t = 0;

	// Lo que usa el Draw de oOtherPlayer
	pred_dmg = 0;
	pred_timer = 0;
	pp_timer = 0;
	pp_off_x = 0;
	pp_off_y = 0;
	last_sp_time = current_time;
	afk = 0;

	scr_botnet_a_base();
	scr_botnet_sp();
}

/// Pone al bot en la base de su equipo.
function scr_botnet_a_base() {
	var _base = (team == "AZUL") ? obj_base_blue : obj_base_red;
	var _off = (((BOTNET_ID_BASE - clientId) mod 3) - 1) * 20;   // para que no salgan encimados
	if (instance_exists(_base)) {
		x = _base.x + _off;
		y = _base.y;
	} else {
		x = ((team == "AZUL") ? 100 : room_width - 100) + _off;
		y = 400;
	}
	var _n = 0;
	while (place_meeting(x, y, obj_wall) && _n < 300) { y -= 1; _n++; }
	hsp = 0;
	vsp = 0;
	push_h = 0;
	net_x = x;
	net_y = y;
}

/// Lo que los demas necesitan para verlo (las mismas claves que manda oPlayer).
function scr_botnet_sp() {
	bot_sp = {
		_x: round(x), _y: round(y), _A: 0, _H: max(0, hp), _IA: image_alpha,
		_IMYS: image_yscale, _IMXS: image_xscale, _ST: state, _SI: sprite_index,
		_II: (state == PLAYERSTATE.DEAD) ? -1 : image_index, _IS: image_speed,
		_BS: false, _KILLS: kills, _VIS: visible, _HF: has_flag, _INV: invulnerable,
		_NAME: Name, _ANG: round(weapon.angle), _WSI: WSI, _AMMO: ammo, _ATYPE: bot_w.tipo,
		_REL: reloading, _RK: recoil_kick, _RA: recoil_angle, _MELEE: melee_active,
		_TEAM: team, _SH: false, _MH: max_health, _PJ: bot_pj, _BOT: true,
		_HCO: (bot_cor_t > 0), _HDA: (bot_dash_vis > 0), _HGF: 0, _HGX: round(x), _HGY: round(y),
		_EF: scr_efx_codigo(), _WT: bot_w.tinte   // efecto encima y color del arma (scr_armas)
	};
}

/// Se ve en mi pantalla? (para no oir disparos de bots lejos)
function scr_botnet_se_ve(_x, _y) {
	var _cam = view_camera[0];
	var _vx = camera_get_view_x(_cam), _vy = camera_get_view_y(_cam);
	return (_x > _vx - 40 && _x < _vx + camera_get_view_width(_cam) + 40 && _y > _vy - 40 && _y < _vy + camera_get_view_height(_cam) + 40);
}

/// Step del bot en el lider (va al inicio del Step de oOtherPlayer).
function scr_botnet_step() {
	last_sp_time = current_time;
	afk = 0;
	isReady = true;   // un bot siempre esta listo (aunque algo lo reinicie)
	pred_dmg = 0;
	pred_timer = 0;
	pp_timer = 0;
	pp_off_x = 0;
	pp_off_y = 0;
	if (crush_cd > 0) crush_cd--;

	// Se mueve cuando ya paso la intro, como las personas
	var _activo = oBrain.intro_disparada && !instance_exists(oIntroVersus) && !global.game_over;

	// Tiempos
	if (bot_invul > 0) bot_invul--;
	scr_botnet_hab_tiempos();
	invulnerable = (bot_invul > 0) || isDead || (bot_dash_t > 0);   // en el impulso las balas no le pegan
	image_alpha = (bot_invul > 0 && !isDead) ? 0.5 : 1;
	if (melee_cd > 0) melee_cd--;
	if (melee_active > 0) melee_active--;
	if (weapon.frequency > 0) weapon.frequency--;
	recoil_kick *= 0.75;
	recoil_angle *= 0.75;
	if (reloading) {
		bot_reload--;
		if (bot_reload <= 0) {
			reloading = false;
			ammo = bot_w.max;
			if (bot_cargas > 0) bot_cargas--;
		}
	}
	// Rafaga (SCAR): una bala cada 4 frames
	if (bot_rafaga > 0) {
		bot_rafaga_t--;
		if (bot_rafaga_t <= 0) {
			bot_rafaga--;
			bot_rafaga_t = 4;
			if (ammo > 0 && !has_flag && !isDead && !reloading) scr_botnet_disparar(true);
		}
	}

	key_left = false;
	key_right = false;
	key_jump = false;
	nav_quiere_pad = false;

	// --- MUERTO: se queda en el suelo y reaparece en su base ---
	if (isDead) {
		hsp = 0;
		sprite_index = bot_anim.dead;
		if (image_index >= image_number - 1) {
			image_speed = 0;
			image_index = image_number - 1;
			visible = false;
		}
		bot_respawn--;
		if (bot_respawn <= 0 && !global.game_over) scr_botnet_revivir();
		enemyHealth = 0;
		enemyHealth_net = 0;
		scr_botnet_sp();
		return;
	}

	// --- GOLPEADO ---
	// Bala normal: se ve el golpe pero sigue moviendose y disparando (igual que tu jugador).
	// Solo pierde el control cuando lo avientan (guante, mina, caja): ahi manda el empuje.
	var _aturdido = false;
	scr_efx_step();                          // zap, hielo, red (scr_armas)
	if (scr_efx_aturdido() || scr_efx_ciego()) _aturdido = true;   // aturdido o cegado
	if (hit_bloqueo_timer > 0) {
		hit_bloqueo_timer--;
		state = PLAYERSTATE.HIT;
		if (abs(push_h) >= 1) {
			hsp *= 0.9;
			_aturdido = true;
		}
	}

	if (_activo && !_aturdido) scr_botnet_pensar();
	if (scr_efx_atrapado()) { key_left = false; key_right = false; key_jump = false; }   // en la red no camina
	if (!_activo) weapon.angle = (image_xscale > 0) ? 0 : 180;

	// --- MOVIMIENTO (igual que el bot del modo local) ---
	if (drop_timer > 0) drop_timer--;
	is_grounded = place_meeting(x, y + 1, obj_wall)
	           || (place_meeting(x, y + 1, oPlataformaPasable) && !place_meeting(x, y, oPlataformaPasable) && drop_timer <= 0);

	if (key_jump && is_grounded && nav_quiere_pad) {
		if (scr_salto_usar()) { is_grounded = false; key_jump = false; }
	}

	if (!_aturdido) {
		var _move = key_right - key_left;
		var _vel = has_flag ? walksp * bot_datos.bandera : walksp;
		if (bot_cor_t > 0) _vel *= HAB_CORAZA_VEL;   // la coraza pesa
		_vel *= scr_efx_vel_mult();                  // el congelador lo pone lento
		if (abs(push_h) < 1) hsp = _move * _vel;
		if (hsp != 0) image_xscale = sign(hsp) * 1.5;
		if (key_jump && is_grounded) { vsp = jumpsp; is_grounded = false; }
	}

	if (abs(push_h) > 0.8) {
		hsp = push_h;
		push_h = lerp(push_h, 0, 0.1);
	} else {
		push_h = 0;
	}

	vsp += grv;

	// Choque de lado
	if (place_meeting(x + hsp, y, obj_wall)) {
		while (!place_meeting(x + sign(hsp), y, obj_wall)) x += sign(hsp);
		hsp = 0;
	}
	x += hsp;

	// Plataformas que se atraviesan
	if (vsp > 0 && drop_timer <= 0) {
		var _pl = instance_place(x, y + vsp, oPlataformaPasable);
		if (_pl != noone && bbox_bottom <= _pl.bbox_top) {
			y = _pl.bbox_top - (bbox_bottom - y);
			vsp = 0;
		}
	}

	// Choque de arriba y abajo
	if (place_meeting(x, y + vsp, obj_wall)) {
		while (!place_meeting(x, y + sign(vsp), obj_wall)) y += sign(vsp);
		vsp = 0;
	}
	y += vsp;

	// Se cayo del mapa
	if (y > room_height + 120) {
		last_reason = "caida";
		last_killer = "";
		last_killer_id = -1;
		hp = 0;
	}

	// --- COMO SE VE ---
	if (!_aturdido) {
		var _suelo = place_meeting(x, y + 1, obj_wall) || place_meeting(x, y + 1, oPlataformaPasable);
		if (!_suelo) state = PLAYERSTATE.JUMP;
		else if (hsp != 0) state = PLAYERSTATE.WALK;
		else state = PLAYERSTATE.IDLE;
	}
	switch (state) {
		case PLAYERSTATE.HIT:  sprite_index = bot_anim.hit;  break;
		case PLAYERSTATE.WALK:
		case PLAYERSTATE.JUMP: sprite_index = bot_anim.walk; break;
		default:               sprite_index = bot_anim.idle; break;
	}
	image_speed = 1;

	// --- ARMA DEL SUELO: si la toca y solo trae la pistola, se la queda ---
	if (_activo && !has_flag && bot_w.tipo == "gun") {
		var _g = instance_place(x, y, oGun);
		if (_g != noone) scr_botnet_agarrar(_g);
	}

	// --- BANDERAS Y MUERTE (las decide el lider) ---
	if (_activo) scr_botnet_banderas();
	if (hp <= 0 && !isDead) scr_botnet_morir();

	enemyHealth = max(0, hp);
	enemyHealth_net = enemyHealth;
	scr_botnet_sp();
}

/// Que hace el bot: a donde va, a quien le dispara, cuando usa su habilidad.
function scr_botnet_pensar() {
	var _flag_rival = (team == "AZUL") ? oFlag : oFlag2;   // la que tiene que robar
	var _flag_mia   = (team == "AZUL") ? oFlag2 : oFlag;   // la de su equipo
	var _base       = (team == "AZUL") ? obj_base_blue : obj_base_red;
	var _yo = id;
	var _eq = team;

	// 1. El rival vivo mas cercano (tu jugador o cualquier otro, persona o bot)
	var _ene = noone;
	var _ene_d = 999999;
	with (oPlayer) {
		if (team != _eq && !isDead && visible && state != PLAYERSTATE.DEAD) {
			var _d = point_distance(x, y, _yo.x, _yo.y);
			if (_d < _ene_d) { _ene = id; _ene_d = _d; }
		}
	}
	with (oOtherPlayer) {
		if (id == _yo || team == _eq || team == "" || state == PLAYERSTATE.DEAD || !visible) continue;
		var _d2 = point_distance(x, y, _yo.x, _yo.y);
		if (_d2 < _ene_d) { _ene = id; _ene_d = _d2; }
	}
	var _veo = (_ene != noone) && (_ene_d < BOTNET_VISTA)
	        && (collision_line(x, y - 16, _ene.x, _ene.y - 16, obj_wall, false, true) == noone);

	// 2. A donde va. Lo principal es la bandera: solo se desvia a pelear si el rival esta encima
	var _tx = x;
	var _ty = y;
	var _voy_al_rival = false;

	var _ladron = noone;   // el que se llevo la bandera de mi equipo
	if (instance_exists(_flag_mia) && _flag_mia.has_flag && instance_exists(_flag_mia.portador_instancia)) _ladron = _flag_mia.portador_instancia;
	var _mia_tirada = instance_exists(_flag_mia) && !_flag_mia.has_flag && (_flag_mia.x != _flag_mia.spawnX);
	var _arma = (!has_flag && bot_w.tipo == "gun") ? scr_botnet_arma_cerca(220) : noone;   // un arma mejor cerca
	var _compa_la_lleva = instance_exists(_flag_rival) && _flag_rival.has_flag && instance_exists(_flag_rival.portador_instancia) && _flag_rival.portador_instancia != id;

	if (has_flag && instance_exists(_base)) {
		// Llevo la bandera: directo a mi base
		_tx = _base.x; _ty = _base.y;
	}
	else if (_ladron != noone) {
		// Se llevaron nuestra bandera: por el
		_tx = _ladron.x; _ty = _ladron.y;
		_voy_al_rival = true;
	}
	else if (_mia_tirada) {
		// Nuestra bandera quedo tirada: a devolverla
		_tx = _flag_mia.x; _ty = _flag_mia.y;
	}
	else if (_veo && _ene_d < 130) {
		// Rival encima: le planta cara
		_tx = _ene.x; _ty = _ene.y;
		_voy_al_rival = true;
	}
	else if (_arma != noone) {
		// Hay un arma cerca y solo trae la pistola: pasa por ella
		_tx = _arma.x; _ty = _arma.y;
	}
	else if (bot_rol == "defensa" && instance_exists(_base)) {
		// Cuida la base: da vueltas cerca y sale contra el que se acerque
		if (_veo && _ene_d < 260) {
			_tx = _ene.x; _ty = _ene.y;
			_voy_al_rival = true;
		} else {
			bot_patrulla_t--;
			if (bot_patrulla_t <= 0) { bot_patrulla_t = room_speed * 3; bot_patrulla_x = irandom_range(-140, 140); }
			_tx = _base.x + bot_patrulla_x; _ty = _base.y;
		}
	}
	else if (_compa_la_lleva) {
		// Un companero lleva la bandera: lo cuida (y se encarga de los que lo persiguen)
		var _c = _flag_rival.portador_instancia;
		if (_veo && _ene_d < 260) { _tx = _ene.x; _ty = _ene.y; _voy_al_rival = true; }
		else { _tx = _c.x; _ty = _c.y; }
	}
	else if (instance_exists(_flag_rival)) {
		// Por la bandera rival (disparando en el camino)
		_tx = _flag_rival.x; _ty = _flag_rival.y;
	}

	// Si va a pelear y ya esta cerca, se planta a disparar
	var _plantado = _voy_al_rival && _veo && _ene_d < 110 && abs(_ene.y - y) < 40;
	if (!_plantado) scr_bot_nav_move(_tx, _ty);

	// 3. Apuntar y disparar mientras camina (con la bandera no se puede disparar, igual que tu)
	var _alcance = min(BOTNET_VISTA + 120, bot_w.vel * bot_w.vida * 0.9);
	if (bot_w.cohete) _alcance = BOTNET_VISTA + 120;
	if (_veo && !has_flag) {
		bot_error = lerp(bot_error, random_range(-9, 9), 0.15);
		weapon.angle = point_direction(x, y - 18, _ene.x, _ene.y - 16) + bot_error;
		if (hsp == 0) image_xscale = (_ene.x >= x) ? 1.5 : -1.5;
		if (_ene_d <= _alcance && !reloading && ammo > 0 && weapon.frequency <= 0 && bot_rafaga <= 0 && random(100) < 35) scr_botnet_disparar();
	} else {
		weapon.angle = (image_xscale > 0) ? 0 : 180;
	}
	if (!reloading && ammo <= 0) scr_botnet_recargar();

	// 4. Golpe de cerca
	if (_ene != noone && _ene_d < 36 && abs(_ene.y - y) < 30 && melee_cd <= 0) scr_botnet_golpe(_ene);

	// 5. Habilidad de su personaje (como la usaria una persona)
	scr_botnet_hab_usar(_veo ? _ene_d : 99999);
}

/// El arma del suelo mas cercana que le sirve (o noone).
function scr_botnet_arma_cerca(_max) {
	var _r = noone;
	var _bd = _max;
	var _yo = id;
	with (oGun) {
		if (taken || no_pickup_timer > 0 || !scr_botnet_arma_sirve(weapon)) continue;
		var _d = point_distance(x, y, _yo.x, _yo.y);
		if (_d < _bd) { _bd = _d; _r = id; }
	}
	return _r;
}

/// Las armas que sabe usar el bot (todas menos el guante, el railgun y la mina).
function scr_botnet_arma_sirve(_w) {
	if (!is_struct(_w) || !variable_struct_exists(_w, "type2")) return false;
	if (scr_arma_es_generica(_w)) return !(variable_struct_exists(_w, "efecto") && _w.efecto == "machete");   // el machete no lo sabe usar
	var _t = string(_w.type2);
	return (_t == "gun" || _t == "smg" || _t == "m4" || _t == "escop" || _t == "bazooka");
}

/// Los numeros de disparo de cualquier arma (las de antes no los traen, las nuevas si).
function scr_botnet_arma_datos(_w) {
	var _d = {
		tipo: string(_w.type2), spr: _w.sprite, dano: _w.damage, cada: max(3, _w.frequency), max: max(1, _w.maxAmmo),
		vel: 16, vida: 40, disp: 1.5, balas: 1, rafaga: 0, cohete: false, acel: false, atraviesa: 0,
		mz: "gun", bala: sprBullet_gun, snd: snd_gun, tono: 1, vol: 0.7,
		efecto: "", tinte: c_white, grav: 0, escala: 1   // armas con efecto (scr_armas)
	};
	if (scr_arma_es_generica(_w)) {
		_d.vel = _w.vel; _d.vida = _w.vida; _d.disp = max(1, _w.disp); _d.balas = _w.balas; _d.rafaga = _w.rafaga;
		_d.atraviesa = _w.atraviesa; _d.mz = _w.mz; _d.snd = _w.snd; _d.tono = _w.tono; _d.vol = _w.vol * 0.7;
		_d.bala = _w.silenciada ? spr_bala_silenciada : ((_w.balas > 1) ? sprBullet_escop : sprBullet_smg);
		if (_w.cohete) { _d.cohete = true; _d.acel = true; _d.bala = sprBullet_bazooka; }
		if (variable_struct_exists(_w, "efecto")) { _d.efecto = _w.efecto; _d.tinte = _w.tinte; _d.grav = _w.grav; _d.escala = _w.escala; }
		return _d;
	}
	switch (_d.tipo) {
		case "smg":     _d.vel = 16; _d.vida = 35;  _d.disp = 3;  _d.mz = "smg";     _d.bala = sprBullet_smg;     _d.snd = snd_smg;     break;
		case "m4":      _d.vel = 19; _d.vida = 40;  _d.disp = 2;  _d.mz = "m4";      _d.bala = sprBullet_smg;     _d.snd = snd_M4;      break;
		case "escop":   _d.vel = 8;  _d.vida = 20;  _d.disp = 18; _d.balas = 7; _d.mz = "escop"; _d.bala = sprBullet_escop; _d.snd = snd_escop; break;
		case "bazooka": _d.vel = 8;  _d.vida = 500; _d.disp = 0;  _d.cohete = true; _d.mz = "bazooka"; _d.bala = sprBullet_bazooka; _d.snd = snd_bazooka; break;
	}
	return _d;
}

/// Le pone su pistola de siempre (balas sin fin, recarga).
function scr_botnet_pistola() {
	bot_w_src = noone;
	bot_w = scr_botnet_arma_datos(oBrain.weapon_struct_pistola);
	bot_cargas = -1;   // -1 = sin limite
	ammo = bot_w.max;
	reloading = false;
	bot_rafaga = 0;
	WSI = bot_w.spr;
}

/// Agarra el arma del suelo que esta tocando (el lider manda en las armas del mapa).
function scr_botnet_agarrar(_g) {
	if (!instance_exists(_g) || has_flag || bot_w.tipo != "gun") return;
	if (_g.taken || _g.no_pickup_timer > 0 || !scr_botnet_arma_sirve(_g.weapon)) return;
	bot_w_src = _g.weapon;
	bot_w = scr_botnet_arma_datos(_g.weapon);
	ammo = clamp(_g.weapon.ammo, 1, bot_w.max);
	bot_cargas = 2;    // dos cargadores de mas; al acabarse vuelve a la pistola
	reloading = false;
	bot_rafaga = 0;
	WSI = bot_w.spr;
	var _uid = _g.net_uid;
	scr_release_spawn_point(_g.x, _g.y);
	instance_destroy(_g);
	var _m = { uid: _uid };
	with (oOtherPlayer) if (!es_bot) SendEventToClient(clientId, "weapon_pickup_taken", _m);
	if (global.sfx && scr_botnet_se_ve(x, y)) audio_play_sound(snd_ammo_pickup, 10, false, 0.6);
}

/// Sin balas: recarga, y si ya no le quedan cargadores vuelve a la pistola.
function scr_botnet_recargar() {
	if (bot_cargas == 0) { scr_botnet_pistola(); return; }
	reloading = true;
	bot_reload = round(room_speed * 1.2 * ((bot_pj == 0) ? ASALTO_RECARGA : 1));
}

/// Dispara el arma que trae. Las balas son oMyEntity del lider: los demas las ven como cualquier bala.
function scr_botnet_disparar(_de_rafaga = false) {
	var _d = bot_w;
	var _ang = weapon.angle;
	var _p = scr_arma_punta(22 + sprite_get_width(_d.spr));
	for (var i = 0; i < _d.balas; i++) {
		var _dir = _ang;
		if (_d.balas > 1) _dir += lerp(-_d.disp * 0.5, _d.disp * 0.5, i / (_d.balas - 1)) + random_range(-3, 3);
		else _dir += random_range(-_d.disp, _d.disp);
		var _b = instance_create_layer(_p[0], _p[1], "Instances", oMyEntity);
		_b.owner_name = Name;
		_b.owner_team = team;
		_b.owner_id = id;
		_b.bot_team = team;   // asi sabe que es de un bot (oMyEntity)
		_b.bot_src = id;
		_b.direction = _dir;
		_b.image_angle = _dir;
		_b.speed = _d.vel * ((_d.balas > 1) ? random_range(0.9, 1.1) : 1);
		_b.life = _d.vida;
		_b.damage = _d.dano + ((bot_pj == 0 && _d.cada <= 10 && _d.balas == 1 && !_d.cohete && _d.efecto == "") ? irandom_range(2, 3) : 0);   // pasiva del Asalto
		_b.sprite_index = _d.bala;
		if (_d.atraviesa > 1) _b.atraviesa = _d.atraviesa;
		if (_d.cohete) {
			_b.is_rocket = true;
			if (_d.acel) { _b.acel = 1.06; _b.vel_max = 16; }
		}
		if (_d.efecto != "") {
			_b.efecto = _d.efecto;
			if (_d.grav > 0) { _b.gravity = _d.grav; _b.gravity_direction = 270; }
			if (_d.escala != 1) { _b.image_xscale = _d.escala; _b.image_yscale = _d.escala; }
		}
	}

	var _f = instance_create_layer(_p[0], _p[1], "Instances", oMuzzleFlash);
	_f.sprite_index = (_d.mz == "escop" || _d.mz == "bazooka") ? sprMuzzle_escop : ((_d.mz == "smg" || _d.mz == "m4") ? sprMuzzle_smg : sprMuzzle_gun);
	_f.image_angle = _ang;
	if (_d.mz == "bazooka") _f.image_xscale = 2;
	var _m = { x: _p[0], y: _p[1], ang: _ang, muzzle: _d.mz, snd: audio_get_name(_d.snd), vol: _d.vol, tono: _d.tono };
	with (oOtherPlayer) if (!es_bot) SendEventToClient(clientId, "fx_shot", _m);
	if (global.sfx && scr_botnet_se_ve(x, y)) audio_play_sound(_d.snd, 1, false, _d.vol, 0, _d.tono);

	ammo -= 1;
	weapon.frequency = round(_d.cada) + irandom(6);
	recoil_kick += 3;
	if (_d.rafaga > 1 && !_de_rafaga) { bot_rafaga = _d.rafaga - 1; bot_rafaga_t = 4; }
	if (ammo <= 0) scr_botnet_recargar();
}

/// Usa la habilidad de su personaje cuando conviene (lo mismo que el bot de partida rapida).
///   0 ASALTO impulso, 1 TANQUE coraza, 2 EXPLORADORA solo pasivas, 3 SARGENTO botiquin
function scr_botnet_hab_usar(_dist) {
	if (bot_hab_cd > 0) return;
	var _fps = game_get_speed(gamespeed_fps);
	var _usar = false;
	switch (bot_pj) {
		case 0:
			if ((has_flag && _dist < 260) || (_dist < 200 && random(1) < 0.05)) {
				var _dir = sign(hsp);
				if (_dir == 0) _dir = sign(image_xscale);
				if (_dir == 0) _dir = 1;
				push_h = _dir * HAB_DASH_FUERZA;
				if (vsp > 0) vsp = 0;
				bot_dash_t = HAB_DASH_INVUL;
				bot_dash_vis = 18;
				fx_dust(x, bbox_bottom, 8, -_dir);
				if (global.sfx && scr_botnet_se_ve(x, y)) audio_play_sound(snd_melee, 5, false, 1, 0, 1.4);
				_usar = true;
			}
		break;
		case 1:
			if (hp < max_health * 0.75 && _dist < 350) {
				bot_cor_t = HAB_CORAZA_T;
				if (global.sfx && scr_botnet_se_ve(x, y)) audio_play_sound(snd_shield_impact, 5, false, 1, 0, 0.6);
				_usar = true;
			}
		break;
		case 2:   // EXPLORADORA: la red cuando tiene al rival cerca (scr_personajes)
			if (_dist < 260 && random(1) < 0.08) {
				var _rd = weapon.angle;
				var _rb = instance_create_layer(x + lengthdir_x(14, _rd), y - 20 + lengthdir_y(14, _rd), "Instances", oMyEntity);
				_rb.owner_name = Name;
				_rb.owner_team = team;
				_rb.owner_id = id;
				_rb.bot_team = team;
				_rb.bot_src = id;
				_rb.direction = _rd;
				_rb.image_angle = _rd;
				_rb.speed = EXPLO_RED_VEL;
				_rb.life = 90;
				_rb.damage = EXPLO_RED_DANO;
				_rb.sprite_index = sprBullet_smg;
				_rb.efecto = "red_hab";
				_rb.gravity = 0.32;
				_rb.gravity_direction = 270;
				_rb.image_xscale = 1.5;
				_rb.image_yscale = 1.5;
				if (global.sfx && scr_botnet_se_ve(x, y)) audio_play_sound(snd_escop, 5, false, 0.6, 0, 1.4);
				_usar = true;
			}
		break;
		case 3:   // SARGENTO: se cura 30 al instante cuando esta herido (scr_personajes)
			if (hp < max_health * 0.5) {
				hp = min(max_health, hp + SARG_CURA);
				repeat (4) instance_create_layer(x + random_range(-14, 14), y - random_range(4, 30), "Instances", oHealFX);
				if (global.sfx && scr_botnet_se_ve(x, y)) audio_play_sound(snd_ammo_pickup, 5, false, 1, 0, 0.8);
				_usar = true;
			}
		break;
	}
	bot_hab_cd = _usar ? round(bot_datos.cd * _fps) : 10;   // si no la uso, lo vuelve a pensar en un ratito
}

/// Tiempos de la habilidad y pasiva del Sargento (cada frame).
function scr_botnet_hab_tiempos() {
	var _fps = game_get_speed(gamespeed_fps);
	if (bot_hab_cd > 0) bot_hab_cd--;
	if (bot_dash_t > 0) bot_dash_t--;
	if (bot_dash_vis > 0) bot_dash_vis--;
	if (bot_cor_t > 0) bot_cor_t--;
	bot_sin_danio++;
	// PASIVA SARGENTO: si no le pegan en 5 s, se cura solo
	if (bot_pj == 3 && !isDead && bot_sin_danio > SARG_REGEN_ESPERA && hp < max_health) {
		bot_regen_acc += SARG_REGEN / _fps;
		if (bot_regen_acc >= 1) {
			var _c = floor(bot_regen_acc);
			bot_regen_acc -= _c;
			hp = min(max_health, hp + _c);
		}
	}
	// Para que se vea (el Draw de oOtherPlayer y los demas por la red)
	hab_co = (bot_cor_t > 0);
	hab_da = (bot_dash_vis > 0);
	hab_gf = 0;
	hab_gx = x;
	hab_gy = y;
}

/// Botiquin del Sargento (Step de oBotiquin): el lider cura a sus bots del mismo equipo.
function scr_botnet_botiquin(_bq) {
	var _fps = game_get_speed(gamespeed_fps);
	with (oOtherPlayer) {
		if (!bot_local) continue;   // solo los bots que muevo yo (los demas se curan solos)
		if (isDead || team != _bq.team || hp >= max_health) continue;
		if (point_distance(_bq.x, _bq.y, x, y - 20) > HAB_BOTI_RADIO + 10) continue;
		bot_cura_acc += HAB_BOTI_CURA / _fps;
		if (bot_cura_acc >= 1) {
			var _c = floor(bot_cura_acc);
			bot_cura_acc -= _c;
			hp = min(max_health, hp + _c);
		}
		bot_cura_fx--;
		if (bot_cura_fx <= 0) {
			bot_cura_fx = 20;
			instance_create_layer(x + random_range(-14, 14), y - random_range(4, 30), "Instances", oHealFX);
		}
	}
}


/// Golpe de cerca.
function scr_botnet_golpe(_t) {
	melee_cd = room_speed div 2;
	melee_active = 6;
	var _dir = (_t.x >= x) ? 1 : -1;
	image_xscale = _dir * 1.5;
	var _fx = instance_create_layer(x + 26 * _dir, y - 10, "Instances", oMeleeFX);
	_fx.image_xscale = _dir;
	var _m = { x: x, y: y, dir: _dir };
	with (oOtherPlayer) if (!es_bot) SendEventToClient(clientId, "fx_melee", _m);
	if (global.sfx && scr_botnet_se_ve(x, y)) audio_play_sound(snd_melee, 1, false);
	scr_botnet_pegar(_t, BOTNET_GOLPE + ((bot_pj == 1) ? TANQUE_GOLPE_EXTRA : 0), point_direction(x, y, _t.x, _t.y));   // pasiva del Tanque
}

/// El bot le pega a alguien: a tu jugador, a otra persona o a otro bot.
function scr_botnet_pegar(_t, _dmg, _ang) {
	if (!instance_exists(_t)) return;
	// Con escudo no le pasa nada y el escudo sigue (igual que el golpe de una persona)
	if (variable_instance_exists(_t, "has_shield") && _t.has_shield) {
		instance_create_layer(_t.x, _t.y - 16, "Instances", oShieldSparkFX);
		if (global.sfx && scr_botnet_se_ve(_t.x, _t.y)) audio_play_sound(snd_shield_impact, 20, false, 2.0);
		var _ms = { ex: _t.x, ey: _t.y - 16 };
		with (oOtherPlayer) if (!es_bot) SendEventToClient(clientId, "fx_shield_hit", _ms);
		return;
	}
	var _m = { damage: _dmg, killer: Name, reason: "pvp", angle: _ang, bot: true };
	if (_t.object_index == oPlayer) {
		callback_ReceivedEvent("hit", _m, clientId);
	} else if (_t.es_bot) {
		scr_botnet_dano(_t, _m, clientId);
	} else {
		scr_predict_hit(_t, _dmg, 10);
		SendEventToClient(_t.clientId, "hit", _m);
	}
}

/// Le llega un golpe a un bot (solo en el lider). _from = quien le pego (clientId).
function scr_botnet_dano(_b, _m, _from) {
	if (!instance_exists(_b) || !is_struct(_m)) return;
	with (_b) {
		if (!bot_local || isDead || bot_invul > 0 || global.game_over) return;
		var _dmg = variable_struct_exists(_m, "damage") ? real(_m.damage) : 0;
		if (_dmg <= 0) return;
		var _why = (variable_struct_exists(_m, "reason") && is_string(_m.reason)) ? _m.reason : "pvp";
		if (bot_dash_t > 0) return;                              // ASALTO en pleno impulso: no le pasa nada
		if (bot_cor_t > 0) _dmg = round(_dmg * HAB_CORAZA_DANO); // TANQUE con coraza: la mitad
		bot_sin_danio = 0;

		hp -= _dmg;
		if (variable_struct_exists(_m, "killer") && is_string(_m.killer)) last_killer = _m.killer;
		last_killer_id = _from;
		last_reason = _why;

		hit_bloqueo_timer = max(hit_bloqueo_timer, 10);
		state = PLAYERSTATE.HIT;
		image_index = 0;

		// Armas con efecto: zap, hielo, red o iman (scr_armas)
		if (variable_struct_exists(_m, "ef") && is_string(_m.ef) && _m.ef != "") {
			var _ax = variable_struct_exists(_m, "ax") ? real(_m.ax) : x;
			var _ay = variable_struct_exists(_m, "ay") ? real(_m.ay) : y;
			var _r = scr_efx_aplicar(_m.ef, _ax, _ay, _from, variable_struct_exists(_m, "killer") ? string(_m.killer) : "", false);
			if (_r.soltar) scr_botnet_soltar(-6, 25, _r.x, _r.y);
		}

		// Guante: lo avienta y suelta la bandera (igual que a ti)
		if (_why == "boxeo") {
			var _ang = variable_struct_exists(_m, "angle") ? real(_m.angle) : 0;
			if (bot_cor_t <= 0) {   // con la coraza no lo mueve (la bandera si la suelta)
				push_h = lengthdir_x(22, _ang);
				vsp = -7;
			}
			hit_bloqueo_timer = 20;
			if (has_flag) scr_botnet_soltar(-6, 25);
		}
	}
}

/// Suelta la bandera donde esta.
function scr_botnet_soltar(_vy, _alto, _px = undefined, _py = undefined) {
	has_flag = false;
	var _f = (team == "AZUL") ? oFlag : oFlag2;
	var _dx = is_undefined(_px) ? x : _px;          // el iman la deja en otro lado (scr_armas)
	var _dy = is_undefined(_py) ? y - _alto : _py;
	with (_f) {
		has_flag = false;
		portador_instancia = noone;
		x = _dx;
		y = _dy;
		velocidad_caida = _vy;
		sprite_index = spr_suela;
	}
	var _m = { team: team, dropX: _dx, dropY: _dy };
	with (oOtherPlayer) if (!es_bot) SendEventToClient(clientId, "flag_dropped", _m);
	var _yo = scr_my_team();
	if (team == _yo) fb_toast("BANDERA EN EL SUELO", "Tu equipo solto la bandera rival", FB_ORO);
	else fb_toast("TU BANDERA ESTA EN EL SUELO", "Tocala para devolverla", fb_team_col(_yo));
}

/// Robar, anotar y devolver (el lider lo decide, como cuando anota el host).
function scr_botnet_banderas() {
	if (isDead || global.game_over) return;
	var _obj  = (team == "AZUL") ? oFlag : oFlag2;          // la rival
	var _mia  = (team == "AZUL") ? oFlag2 : oFlag;          // la de su equipo
	var _base = (team == "AZUL") ? obj_base_blue : obj_base_red;
	var _yo = scr_my_team();

	// Robar la bandera rival
	if (!has_flag && instance_exists(_obj) && !_obj.has_flag && place_meeting(x, y, _obj)) {
		has_flag = true;
		with (_obj) {
			has_flag = true;
			portador_instancia = other.id;
			sprite_index = spr_mano;
		}
		if (team == "AZUL") global.bandera_roja_robada = true; else global.bandera_azul_robada = true;
		var _m = { team: team, b: clientId };
		with (oOtherPlayer) if (!es_bot) SendEventToClient(clientId, "bot_flag_capture", _m);
		if (team == _yo) fb_banner_aliado(Name); else fb_banner_robada(Name);
	}

	// Anotar en su base
	if (has_flag && instance_exists(_base) && place_meeting(x, y, _base)) {
		has_flag = false;
		if (team == "AZUL") {
			global.puntos_azul++;
			global.bandera_roja_robada = false;
			with (oBrain) { marcador_escala_azul = 3; marcador_shake = 15; }
		} else {
			global.puntos_rojo++;
			global.bandera_azul_robada = false;
			with (oBrain) { marcador_escala_rojo = 3; marcador_shake = 15; }
		}
		var _scored = (team == "AZUL") ? "ROJA" : "AZUL";
		with (_obj) {
			x = spawnX;
			y = spawnY;
			velocidad_caida = 0;
			has_flag = false;
			portador_instancia = noone;
			sprite_index = spr_suela;
		}
		var _m2 = { azul: global.puntos_azul, rojo: global.puntos_rojo, resetFlag: _scored, nombre: Name };
		with (oOtherPlayer) if (!es_bot) SendEventToClient(clientId, "sync_score", _m2);
		fb_anotacion(team, Name);
	}

	// Devolver la de su equipo si esta tirada
	if (!has_flag && instance_exists(_mia) && !_mia.has_flag && _mia.x != _mia.spawnX && place_meeting(x, y, _mia)) {
		with (_mia) {
			x = spawnX;
			y = spawnY;
			velocidad_caida = 0;
			sprite_index = spr_suela;
		}
		var _m3 = { azul: global.puntos_azul, rojo: global.puntos_rojo, resetFlag: (team == "AZUL") ? "AZUL" : "ROJA", reason: "RETORNO", nombre: Name };
		with (oOtherPlayer) if (!es_bot) SendEventToClient(clientId, "sync_score", _m3);
		if (team == _yo) fb_toast("BANDERA DEVUELTA", Name + " salvo tu bandera", fb_team_col(_yo));
		else fb_toast("EL RIVAL RECUPERO SU BANDERA", Name, fb_team_col(fb_rival(_yo)));
	}
}

/// El bot cae: suelta la bandera, aviso en el feed y punto para quien lo elimino.
function scr_botnet_morir() {
	isDead = true;
	hp = 0;
	state = PLAYERSTATE.DEAD;
	image_index = 0;
	image_speed = 1;
	hsp = 0;
	vsp = 0;
	push_h = 0;
	bot_respawn = BOTNET_RESPAWN;
	reloading = false;
	hit_bloqueo_timer = 0;
	bot_rafaga = 0;
	bot_cor_t = 0;
	bot_dash_t = 0;
	bot_dash_vis = 0;
	if (has_flag) scr_botnet_soltar(-2, 0);
	// Suelta el arma que traia (igual que tu)
	if (bot_w.tipo != "gun" && is_struct(bot_w_src)) scr_drop_on_death(bot_w_src, x, y);
	scr_botnet_pistola();

	var _msg;
	if (last_reason == "crush") _msg = Name + " murio aplastado";
	else if (last_reason == "caida") _msg = Name + " se cayo del mapa";
	else _msg = ((last_killer != "") ? last_killer : "Alguien") + " elimino a " + Name;
	scrAddKillFeed(_msg);
	var _m = { msg: _msg };
	with (oOtherPlayer) if (!es_bot) SendEventToClient(clientId, "kill_feed", _m);

	// Cuenta como baja para quien lo elimino (igual que cuando eliminas a una persona)
	if (last_reason == "pvp" || last_reason == "boxeo" || last_reason == "granada") {
		if (last_killer_id == global.clientId) {
			if (instance_exists(oPlayer)) callback_ReceivedMessage("point", global.clientId);
		} else if (is_numeric(last_killer_id) && last_killer_id >= 0) {
			SendMessageToClient(last_killer_id, "point");
		}
	}
}

/// Reaparece en su base con vida llena y un rato sin que le peguen.
function scr_botnet_revivir() {
	isDead = false;
	scr_efx_init(); efx_stun = 0; efx_red = 0; efx_hielo_n = 0; efx_hielo_t = 0;   // sin efectos al revivir (scr_armas)
	hp = max_health;
	state = PLAYERSTATE.IDLE;
	visible = true;
	image_speed = 1;
	sprite_index = bot_anim.idle;
	bot_invul = 120;
	scr_botnet_pistola();
	scr_botnet_equipo_azar();   // EQUIPAMIENTO (scr_armas)
	bot_hab_cd = irandom_range(30, 90);
	nav_path = [];
	nav_escape = 0;
	nav_tries = 0;
	hit_bloqueo_timer = 0;
	last_killer = "";
	last_killer_id = -1;
	last_reason = "pvp";
	scr_botnet_a_base();
}

/// El lider anterior se fue y ahora yo soy el lider: muevo a este bot desde donde iba.
function scr_botnet_tomar() {
	var _hp   = enemyHealth_net;
	var _mh   = max_health;
	var _flag = has_flag;
	var _dead = (state == PLAYERSTATE.DEAD) || (_hp <= 0);
	var _x    = net_x;
	var _y    = net_y;
	var _xs   = image_xscale;
	scr_botnet_init(team, Name, mySelectedPJ);
	x = _x;
	y = _y;
	net_x = _x;
	net_y = _y;
	image_xscale = (_xs < 0) ? -1.5 : 1.5;
	max_health = max(1, _mh);
	hp = clamp(_hp, 1, max_health);
	if (_flag) {
		has_flag = true;
		var _f = (team == "AZUL") ? oFlag : oFlag2;
		with (_f) { has_flag = true; portador_instancia = other.id; sprite_index = spr_mano; }
	}
	if (_dead) {
		isDead = true;
		hp = 0;
		state = PLAYERSTATE.DEAD;
		visible = false;
		bot_respawn = 60;
	}
	scr_botnet_sp();
}

/// En las otras pantallas: llega como van los bots (evento "bots_sp").
function scr_botnet_recibir(_s) {
	if (room == rm_menu || oBrain.AmIPseudoHost) return;
	if (!is_struct(_s) || !variable_struct_exists(_s, "l") || !is_array(_s.l)) return;
	global.botnet_partida = true;
	for (var i = 0; i < array_length(_s.l); i++) {
		var _e = _s.l[i];
		if (!is_struct(_e) || !variable_struct_exists(_e, "i") || !variable_struct_exists(_e, "s") || !is_struct(_e.s)) continue;
		var _b = scr_botnet_buscar(_e.i);
		if (_b == noone) {
			_b = instance_create_layer(0, 0, global.OtherPlayersLayerName, oOtherPlayer);
			_b.clientId = _e.i;
		}
		if (_b.bot_local) continue;
		with (_b) {
			var _sp = _e.s;
			es_bot = true;
			isReady = true;
			sharedProperties = json_stringify(_sp);
			last_sp_time = current_time;
			afk = 0;
			if (variable_struct_exists(_sp, "_PJ"))   mySelectedPJ = clamp(real(_sp._PJ), 0, 3);
			if (variable_struct_exists(_sp, "_TEAM")) { team = string(_sp._TEAM); lobby_team = team; }
			if (variable_struct_exists(_sp, "_NAME")) Name = string(_sp._NAME);
			if (variable_struct_exists(_sp, "_MH"))   max_health = real(_sp._MH);
		}
	}
}

/// El lider manda como van todos sus bots en un solo mensaje (oBrain Step).
function scr_botnet_enviar() {
	botnet_cd -= 1;
	if (botnet_cd > 0) return;
	botnet_cd = BOTNET_SP_CADA;
	var _l = [];
	with (oOtherPlayer) if (bot_local) array_push(_l, { i: clientId, s: bot_sp });
	if (array_length(_l) == 0) return;
	var _m = { l: _l };
	with (oOtherPlayer) if (!es_bot) SendEventToClient(clientId, "bots_sp", _m);
}

/// Copas y XP: si en la partida hubo bots, cuenta como partida contra bots (menos premio).
/// En sala privada no cuenta nada.
function scr_botnet_premio(_gane) {
	if (scr_fin_es_privada()) return;   // en sala privada no se gana ni se pierde nada
	if (variable_global_exists("botnet_partida") && global.botnet_partida) scr_bot_premio(_gane);
	else if (_gane) scr_add_victory();
	else scr_add_loss();
}

// ======================================================
// FIN DE PARTIDA: botones segun el modo (oBrain Step y Draw GUI)
// ======================================================

/// Estoy en una sala privada? (sus codigos empiezan con MAX)
function scr_fin_es_privada() {
	return variable_global_exists("roomId") && string_copy(string(global.roomId), 1, 3) == "MAX";
}

/// Los botones de la pantalla de fin de partida.
function scr_fin_opciones() {
	if (variable_global_exists("bot_partida") && global.bot_partida) return ["BUSCAR RIVAL", "SALIR"];
	if (scr_botq_activa()) return ["BUSCAR RIVAL", "SALIR"];   // partida rapida contra el bot nuevo
	if (!global.ONLINE) return ["REINTENTAR", "SALIR"];
	if (scr_fin_es_privada()) return ["SALIR"];
	return ["ENVIAR SOLICITUD", "SALIR"];
}

// ======================================================
// SALA PRIVADA: EQUIPOS PAREJOS Y NADIE ENTRA A MEDIA PARTIDA
// El lider reparte los equipos (ya no se juntan 3 en uno) y los manda junto con los ajustes.
// Al empezar, se guarda quienes estan (la lista). Si alguien entra con el codigo a media
// partida, el lider le avisa "SALA_EN_PARTIDA" y se sale solo.
// ======================================================

/// El lider reparte los equipos. Devuelve [[clientId, "AZUL"/"ROJO"], ...]
function scr_sala_equipos_calc() {
	if (!variable_global_exists("sala_eq") || !is_struct(global.sala_eq)) global.sala_eq = {};
	var _max = (variable_global_exists("max_players_allowed") && global.max_players_allowed >= 2) ? global.max_players_allowed : 2;
	var _cupo = max(1, _max div 2);

	// Personas: el lider primero, luego en el orden en que entraron (clientId)
	var _otros = [];
	var _pref = {};
	_pref[$ string(global.clientId)] = (variable_global_exists("serverTeam") && global.serverTeam != "") ? global.serverTeam : "AZUL";
	with (oOtherPlayer) {
		if (es_bot || clientId < 0) continue;
		array_push(_otros, clientId);
		_pref[$ string(clientId)] = lobby_team;
	}
	array_sort(_otros, true);
	var _ids = [global.clientId];
	for (var i = 0; i < array_length(_otros); i++) array_push(_ids, _otros[i]);

	var _nuevo = {};
	var _cuenta = { AZUL: 0, ROJO: 0 };
	// 1) Cada quien se queda en su equipo si cabe (el que ya tenia, o el que le dio el servidor)
	for (var i = 0; i < array_length(_ids); i++) {
		var _k = string(_ids[i]);
		var _t = variable_struct_exists(global.sala_eq, _k) ? global.sala_eq[$ _k] : _pref[$ _k];
		if ((_t == "AZUL" || _t == "ROJO") && _cuenta[$ _t] < _cupo) {
			_nuevo[$ _k] = _t;
			_cuenta[$ _t] += 1;
		}
	}
	// 2) Los que no cupieron van al equipo con menos gente
	for (var i = 0; i < array_length(_ids); i++) {
		var _k = string(_ids[i]);
		if (variable_struct_exists(_nuevo, _k)) continue;
		var _t = (_cuenta.ROJO < _cuenta.AZUL) ? "ROJO" : "AZUL";
		_nuevo[$ _k] = _t;
		_cuenta[$ _t] += 1;
	}
	global.sala_eq = _nuevo;
	global.serverTeam = _nuevo[$ string(global.clientId)];
	global.myTeam = global.serverTeam;
	// En mi pantalla los demas quedan de una vez en su equipo (para la sala y los bots)
	with (oOtherPlayer) {
		if (es_bot || clientId < 0) continue;
		var _kk = string(clientId);
		if (variable_struct_exists(_nuevo, _kk)) lobby_team = _nuevo[$ _kk];
	}

	var _lista = [];
	for (var i = 0; i < array_length(_ids); i++) array_push(_lista, [_ids[i], _nuevo[$ string(_ids[i])]]);
	return _lista;
}

/// Pone los equipos que mando el lider (en todos los demas)
function scr_sala_equipos_aplicar(_eq) {
	if (!is_array(_eq)) return;
	for (var i = 0; i < array_length(_eq); i++) {
		var _p = _eq[i];
		if (!is_array(_p) || array_length(_p) < 2) continue;
		var _cid = real(_p[0]);
		var _t = string(_p[1]);
		if (_t != "AZUL" && _t != "ROJO") continue;
		if (!variable_global_exists("sala_eq") || !is_struct(global.sala_eq)) global.sala_eq = {};
		global.sala_eq[$ string(_cid)] = _t;   // asi todos saben el equipo de cada quien (scr_sala_equipo_de)
		if (_cid == global.clientId) { global.serverTeam = _t; global.myTeam = _t; }
		else with (oOtherPlayer) if (clientId == _cid) lobby_team = _t;
	}
}

/// Al empezar la partida: quienes juegan (los que entren despues no pueden)
function scr_sala_roster_fijar(_aj) {
	global.sala_roster = [];
	global.sala_rechazados = {};
	if (!is_struct(_aj) || !variable_struct_exists(_aj, "eq") || !is_array(_aj.eq)) return;
	for (var i = 0; i < array_length(_aj.eq); i++) {
		var _p = _aj.eq[i];
		if (is_array(_p) && array_length(_p) >= 1) array_push(global.sala_roster, real(_p[0]));
	}
}

/// Se borra la lista al cambiar de sala del servidor
function scr_sala_roster_limpiar() {
	scr_chat_reset();   // el chat es de cada sala
	scr_voz_apagar();   // y la voz tambien (scr_objetivo, CHAT DE VOZ)
	global.voz.abierto_on = false;   // en cada sala el micro empieza APAGADO
	global.sala_roster = [];
	global.sala_rechazados = {};
	global.sala_eq = {};
	global.sala_listo = false;   // en la sala nueva hay que volver a dar LISTO
}

/// Un jugador nuevo aparece en plena partida y no estaba en la lista: no se crea,
/// y el lider le dice que se salga (una sola vez). Devuelve true si hay que ignorarlo.
function scr_sala_bloqueado(_cid) {
	if (room == rm_menu) return false;
	if (!variable_global_exists("sala_roster") || !is_array(global.sala_roster) || array_length(global.sala_roster) == 0) return false;
	for (var i = 0; i < array_length(global.sala_roster); i++) if (global.sala_roster[i] == _cid) return false;
	if (oBrain.AmIPseudoHost) {
		if (!variable_global_exists("sala_rechazados") || !is_struct(global.sala_rechazados)) global.sala_rechazados = {};
		var _k = string(_cid);
		if (!variable_struct_exists(global.sala_rechazados, _k)) {
			global.sala_rechazados[$ _k] = true;
			SendEventToClient(_cid, "SALA_EN_PARTIDA", {});
		}
	}
	return true;
}

// ======================================================
// CHAT DE LA SALA PRIVADA (opcion B): boton CHAT abajo a la derecha con contador,
// y un panel al lado con los mensajes, la caja para escribir y frases rapidas.
// PC: T o clic en CHAT para abrir, ENTER manda, ESC cierra.
// Celular: tocar CHAT abre el teclado; OK manda; ATRAS o la X cierra.
// Todo el texto queda en ASCII (las tildes se quitan).
// ======================================================
#macro CHAT_MAX_LETRAS 60
#macro CHAT_MAX_MSGS   30

function scr_chat_init() {
	if (!variable_global_exists("chat") || !is_struct(global.chat)) {
		global.chat = { lista: [], abierto: false, nuevos: 0, cd: 0, gente: {} };
	}
}

/// Se vacia al cambiar de sala del servidor
function scr_chat_reset() {
	global.chat = { lista: [], abierto: false, nuevos: 0, cd: 0, gente: {} };
}

/// Solo ASCII: quita tildes y lo que no se puede dibujar
function scr_chat_limpiar(_t) {
	_t = string(_t);
	var _de = "áéíóúÁÉÍÓÚñÑüÜ¿¡";
	var _a  = "aeiouAEIOUnNuU?!";
	var _r = "";
	for (var i = 1; i <= string_length(_t); i++) {
		var _c = string_char_at(_t, i);
		var _o = ord(_c);
		if (_o >= 32 && _o < 127) { _r += _c; continue; }
		var _p = string_pos(_c, _de);
		if (_p > 0) _r += string_char_at(_a, _p);
	}
	return string_copy(_r, 1, CHAT_MAX_LETRAS);
}

function __chat_push(_n, _t, _eq) {
	scr_chat_init();
	array_push(global.chat.lista, { n: _n, t: _t, eq: _eq });
	if (array_length(global.chat.lista) > CHAT_MAX_MSGS) array_delete(global.chat.lista, 0, 1);
}

/// Manda un mensaje a todos los de la sala (los bots no)
function scr_chat_enviar(_t) {
	scr_chat_init();
	_t = scr_chat_limpiar(_t);
	if (string_length(string_trim(_t)) == 0) return;
	if (global.chat.cd > 0) return;          // que no hagan spam
	global.chat.cd = 20;
	var _n = scr_chat_limpiar(global.myName);
	var _eq = scr_my_team();
	__chat_push(_n, _t, _eq);
	var _m = { n: _n, t: _t, eq: _eq };
	with (oOtherPlayer) if (!es_bot) SendEventToClient(clientId, "chat_sala", _m);
}

/// Llega un mensaje (callback_ReceivedEvent, "chat_sala")
function scr_chat_recibir(_m) {
	if (!is_struct(_m) || !variable_struct_exists(_m, "t")) return;
	scr_chat_init();
	var _n = variable_struct_exists(_m, "n") ? scr_chat_limpiar(_m.n) : "?";
	var _eq = variable_struct_exists(_m, "eq") ? string(_m.eq) : "";
	__chat_push(_n, scr_chat_limpiar(_m.t), _eq);
	if (!global.chat.abierto) global.chat.nuevos++;
	if (global.sfx) audio_play_sound(snd_ammo_pickup, 1, false, 0.35, 0, 1.4);
}

function scr_chat_frases() { return ["LISTO!", "ESPEREN", "YA VOY", "GG", "QUE MAPA?", "EMPIEZA YA"]; }

/// Medidas del boton y del panel (las mismas en el Step y en el Draw)
/// En PC la caja de texto va abajo. En el celular va arriba (el teclado tapa la mitad de abajo)
/// y el boton CHAT queda arriba a la derecha (abajo estan los botones OK y ATRAS).
function scr_chat_geo() {
	var _gw = display_get_gui_width(), _gh = display_get_gui_height();
	var _u = clamp(min(_gw / 1280, _gh / 720), 0.6, 1.6);
	var _tm = touch_mode();
	var _pw = 470 * _u;
	var _px = _gw - _pw;
	var _g = { u: _u, gw: _gw, gh: _gh, tactil: _tm,
		bw: 150 * _u, bh: 44 * _u, bx: _gw - 170 * _u, by: _tm ? 130 * _u : _gh - 64 * _u,
		px: _px, pw: _pw,
		xx: _gw - 44 * _u, xy: 14 * _u, xs: 30 * _u,           // la X
		ix: _px + 16 * _u, iw: _pw - 32 * _u, ih: 46 * _u,     // caja de texto
		chips: []
	};
	var _cw = (_pw - 32 * _u - 16 * _u) / 3, _ch = 40 * _u;
	var _cy0;
	if (_tm) {
		_g.iy = 130 * _u;                                  // caja arriba
		_cy0 = _g.iy + _g.ih + 10 * _u;                   // frases debajo de la caja
		_g.mt = _cy0 + _ch * 2 + 8 * _u + 14 * _u;        // mensajes debajo (el mas nuevo arriba)
		_g.mb = _gh - 16 * _u;
	} else {
		_cy0 = _gh - 16 * _u - _ch * 2 - 8 * _u;          // frases abajo del todo
		_g.iy = _cy0 - 12 * _u - _g.ih;                   // caja arriba de las frases
		_g.mt = 60 * _u;
		_g.mb = _g.iy - 10 * _u;                          // mensajes arriba (el mas nuevo abajo)
	}
	for (var i = 0; i < 6; i++) {
		var _cx = _px + 16 * _u + (i mod 3) * (_cw + 8 * _u);
		var _cy = _cy0 + (i div 3) * (_ch + 8 * _u);
		array_push(_g.chips, [_cx, _cy, _cw, _ch]);
	}
	return _g;
}

/// Va en el Step de oMenu (sala de espera). Devuelve true si el chat uso las teclas este frame
/// (asi ENTER no empieza la partida y ESC no abre "SALIR DE LA SALA?").
function scr_chat_step() {
	scr_chat_init();
	var _c = global.chat;
	if (_c.cd > 0) _c.cd--;
	var _en_sala = (instance_exists(oMenu) && oMenu.menu_state == "lobby_espera");
	if (!_en_sala) {
		if (_c.abierto) { _c.abierto = false; if (touch_mode()) keyboard_virtual_hide(); }
		return false;
	}

	// Avisos: quien entro y quien salio
	var _ahora = {};
	with (oOtherPlayer) {
		if (es_bot || clientId < 0) continue;
		if (Name == "" || Name == "Cargando...") continue;
		_ahora[$ string(clientId)] = Name;
	}
	var _k = variable_struct_get_names(_ahora);
	for (var i = 0; i < array_length(_k); i++) if (!variable_struct_exists(_c.gente, _k[i])) __chat_push("", scr_chat_limpiar(_ahora[$ _k[i]]) + " ENTRO A LA SALA", "");
	var _k2 = variable_struct_get_names(_c.gente);
	for (var i = 0; i < array_length(_k2); i++) if (!variable_struct_exists(_ahora, _k2[i])) __chat_push("", scr_chat_limpiar(_c.gente[$ _k2[i]]) + " SALIO DE LA SALA", "");
	_c.gente = _ahora;

	if (oMenu.confirmar_salida) return false;
	var _g = scr_chat_geo();
	var _mx = device_mouse_x_to_gui(0), _my = device_mouse_y_to_gui(0);
	var _tap = device_mouse_check_button_pressed(0, mb_left);

	if (!_c.abierto) {
		var _abrir = keyboard_check_pressed(ord("T"));
		if (_tap && point_in_rectangle(_mx, _my, _g.bx, _g.by, _g.bx + _g.bw, _g.by + _g.bh)) _abrir = true;
		if (_abrir) {
			_c.abierto = true;
			_c.nuevos = 0;
			keyboard_string = "";
			if (touch_mode()) keyboard_virtual_show(kbv_type_default, kbv_returnkey_send, kbv_autocapitalize_none, false);
			return true;
		}
		return false;
	}

	// --- Abierto ---
	_c.nuevos = 0;
	if (string_length(keyboard_string) > CHAT_MAX_LETRAS) keyboard_string = string_copy(keyboard_string, 1, CHAT_MAX_LETRAS);

	var _cerrar = vkey_pressed(vk_escape);
	if (_tap && point_in_rectangle(_mx, _my, _g.xx - 6 * _g.u, _g.xy - 6 * _g.u, _g.xx + _g.xs, _g.xy + _g.xs)) _cerrar = true;
	if (_tap && point_in_rectangle(_mx, _my, _g.bx, _g.by, _g.bx + _g.bw, _g.by + _g.bh) && _mx < _g.px) _cerrar = true;
	if (_cerrar) {
		_c.abierto = false;
		keyboard_string = "";
		if (touch_mode()) keyboard_virtual_hide();
		return true;
	}

	if (vkey_pressed(vk_enter)) {
		scr_chat_enviar(keyboard_string);
		keyboard_string = "";
	}
	if (_tap) {
		if (touch_mode() && point_in_rectangle(_mx, _my, _g.ix, _g.iy, _g.ix + _g.iw, _g.iy + _g.ih)) {
			keyboard_virtual_show(kbv_type_default, kbv_returnkey_send, kbv_autocapitalize_none, false);
		}
		var _fr = scr_chat_frases();
		for (var i = 0; i < array_length(_g.chips); i++) {
			var _r = _g.chips[i];
			if (point_in_rectangle(_mx, _my, _r[0], _r[1], _r[0] + _r[2], _r[1] + _r[3])) scr_chat_enviar(_fr[i]);
		}
	}
	return true;
}

/// Va en el Draw GUI de oMenu (sala de espera), antes de la ventanita de SALIR
function scr_chat_draw() {
	scr_chat_init();
	var _c = global.chat;
	var _g = scr_chat_geo();
	var _u = _g.u;
	var _tinta = make_color_rgb(11, 15, 26);
	var _oro   = make_color_rgb(255, 212, 71);
	var _gris  = make_color_rgb(169, 180, 208);
	var _azul  = make_color_rgb(79, 176, 255);
	var _rojo  = make_color_rgb(255, 107, 122);
	draw_set_font(fnt_menu);
	draw_set_valign(fa_middle);

	if (!_c.abierto) {
		// Boton CHAT con contador de mensajes nuevos
		ctf_ui_para(_g.bx, _g.by, _g.bw, _g.bh, 10 * _u, _tinta, 0.92, false);
		ctf_ui_para(_g.bx, _g.by, _g.bw, _g.bh, 10 * _u, _oro, 0.9, true);
		draw_set_halign(fa_center);
		draw_set_color(_oro);
		draw_text_transformed(_g.bx + _g.bw / 2 - ((_c.nuevos > 0) ? 14 * _u : 0), _g.by + _g.bh / 2 - 2 * _u, "CHAT", 0.7 * _u, 0.7 * _u, 0);
		if (_c.nuevos > 0) {
			var _bx = _g.bx + _g.bw / 2 + 38 * _u, _by = _g.by + _g.bh / 2;
			draw_set_color(make_color_rgb(255, 75, 92));
			draw_circle(_bx, _by, 13 * _u, false);
			draw_set_color(c_white);
			draw_set_font(fnt_small);
			draw_text_transformed(_bx, _by, string(min(_c.nuevos, 99)), 0.6 * _u, 0.6 * _u, 0);
		}
		if (!touch_mode()) {
			draw_set_font(fnt_small);
			draw_set_color(_gris); draw_set_alpha(0.5);
			draw_text_transformed(_g.bx + _g.bw / 2, _g.by - 12 * _u, "[T]", 0.55 * _u, 0.55 * _u, 0);
			draw_set_alpha(1);
		}
		draw_set_halign(fa_left);
		draw_set_valign(fa_top);
		draw_set_color(c_white);
		return;
	}

	// --- Panel ---
	draw_set_alpha(0.97);
	draw_set_color(make_color_rgb(14, 20, 36));
	draw_rectangle(_g.px, 0, _g.gw, _g.gh, false);
	draw_set_alpha(1);
	draw_set_color(_oro);
	draw_rectangle(_g.px, 0, _g.px + 2 * _u, _g.gh, false);

	// Titulo y X
	draw_set_halign(fa_left);
	draw_set_color(_oro);
	draw_text_transformed(_g.px + 16 * _u, 30 * _u, "CHAT DE LA SALA", 0.9 * _u, 0.9 * _u, 0);
	draw_set_halign(fa_center);
	draw_text_transformed(_g.xx + _g.xs / 2 - 3 * _u, _g.xy + _g.xs / 2, "X", 0.75 * _u, 0.75 * _u, 0);

	// Mensajes: en PC el mas nuevo abajo (junto a la caja); en el celular el mas nuevo arriba
	// (letra grande: fnt_menu, la chica casi no se leia)
	draw_set_font(fnt_menu);
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	var _s = 0.85 * _u;
	var _w = _g.pw - 32 * _u;
	var _yy = _g.tactil ? _g.mt : _g.mb;
	for (var i = array_length(_c.lista) - 1; i >= 0; i--) {
		var _m = _c.lista[i];
		var _sis = (_m.n == "");
		var _hn = _sis ? 0 : string_height("A") * _s;
		var _ht = string_height_ext(_sis ? "* " + _m.t : _m.t, -1, _w / _s) * _s;
		var _h = _hn + _ht + 8 * _u;
		var _y0;
		if (_g.tactil) {
			if (_yy + _h > _g.mb) break;
			_y0 = _yy;
			_yy += _h;
		} else {
			if (_yy - _h < _g.mt) break;
			_yy -= _h;
			_y0 = _yy;
		}
		if (_sis) {
			draw_set_color(_gris); draw_set_alpha(0.7);
			draw_text_ext_transformed(_g.px + 16 * _u, _y0, "* " + _m.t, -1, _w / _s, _s, _s, 0);
			draw_set_alpha(1);
		} else {
			draw_set_color((_m.eq == "ROJO") ? _rojo : _azul);
			draw_text_transformed(_g.px + 16 * _u, _y0, _m.n + ":", _s, _s, 0);
			draw_set_color(c_white);
			draw_text_ext_transformed(_g.px + 16 * _u, _y0 + _hn, _m.t, -1, _w / _s, _s, _s, 0);
		}
	}
	if (array_length(_c.lista) == 0) {
		draw_set_color(_gris); draw_set_alpha(0.5);
		draw_text_transformed(_g.px + 16 * _u, _g.tactil ? _g.mt : _g.mb - 20 * _u, "Todavia no hay mensajes", _s, _s, 0);
		draw_set_alpha(1);
	}

	// Caja de texto con el cursor parpadeando
	ctf_ui_para(_g.ix, _g.iy, _g.iw, _g.ih, 6 * _u, make_color_rgb(20, 28, 48), 1, false);
	ctf_ui_para(_g.ix, _g.iy, _g.iw, _g.ih, 6 * _u, _gris, 0.5, true);
	draw_set_valign(fa_middle);
	var _txt = scr_chat_limpiar(keyboard_string);
	var _cur = ((current_time div 500) mod 2 == 0) ? "_" : "";
	if (_txt == "") {
		draw_set_color(_gris); draw_set_alpha(0.5);
		draw_text_transformed(_g.ix + 10 * _u, _g.iy + _g.ih / 2, touch_mode() ? "Toca para escribir..." : "Escribe y presiona ENTER...", _s, _s, 0);
		draw_set_alpha(1);
	} else {
		// Si es largo, se ve el final
		var _ver = _txt;
		while (string_length(_ver) > 1 && string_width(_ver + "_") * _s > _g.iw - 20 * _u) _ver = string_delete(_ver, 1, 1);
		draw_set_color(c_white);
		draw_text_transformed(_g.ix + 10 * _u, _g.iy + _g.ih / 2, _ver + _cur, _s, _s, 0);
	}

	// Frases rapidas
	var _fr = scr_chat_frases();
	draw_set_halign(fa_center);
	for (var i = 0; i < array_length(_g.chips); i++) {
		var _r = _g.chips[i];
		ctf_ui_para(_r[0], _r[1], _r[2], _r[3], 6 * _u, make_color_rgb(26, 36, 64), 1, false);
		ctf_ui_para(_r[0], _r[1], _r[2], _r[3], 6 * _u, _oro, 0.35, true);
		draw_set_color(_oro);
		draw_text_transformed(_r[0] + _r[2] / 2, _r[1] + _r[3] / 2, _fr[i], 0.75 * _u, 0.75 * _u, 0);
	}

	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	draw_set_color(c_white);
	draw_set_alpha(1);
}

/// Partida nueva desde cero: que no se quede nada de la anterior (fin de partida, festejo,
/// "listo", intro...). Si algo quedaba pegado, a algunos no les salia la seleccion de personaje.
function scr_partida_estado_nuevo() {
	global.sala_listo  = false;   // al volver a la sala hay que dar LISTO otra vez
	global.game_over   = false;
	global.pausa       = false;
	global.puntos_azul = 0;
	global.puntos_rojo = 0;
	global.winner_team = 0;
	global.mi_listo    = false;
	global.sel_tarde   = false;
	if (variable_global_exists("fest") && is_struct(global.fest)) global.fest.t = 0;
	if (instance_exists(oBrain)) with (oBrain) {
		intro_disparada   = false;
		timer_intro       = 60 * 60;
		victory_alpha     = 0;
		victory_index     = 0;
		puntos_procesados = false;
		abandono_activo   = false;
		abandono_check    = -1;
	}
	if (instance_exists(oIntroVersus)) instance_destroy(oIntroVersus);
}

// ======================================================
// SEGURO DE SELECCION: nadie se queda sin personaje
// Si la partida en linea ya arranco (paso la intro) y yo no tengo personaje, a los 0.75 s
// me sale otra vez la seleccion ("LA PARTIDA YA EMPEZO: ELIGE Y ENTRAS"). Al darle ENTER
// aparezco en mi base como siempre.
// ======================================================
function scr_sel_tarde() {
	return variable_global_exists("sel_tarde") && global.sel_tarde;
}

/// Va en el Step de oBrain
function scr_sel_tarde_step() {
	if (!variable_global_exists("sel_tarde")) global.sel_tarde = false;
	if (!variable_instance_exists(id, "sel_tarde_t")) sel_tarde_t = 0;
	var _sin_pj = global.ONLINE && room != rm_menu && intro_disparada && !instance_exists(oIntroVersus)
		&& !global.game_over && !instance_exists(oPlayer);
	if (global.sel_tarde) {
		if (!_sin_pj) global.sel_tarde = false;   // ya tengo personaje (o se acabo la partida)
		return;
	}
	if (_sin_pj) {
		sel_tarde_t++;
		if (sel_tarde_t >= 45) {
			sel_tarde_t = 0;
			global.sel_tarde = true;
			global.mi_listo = false;   // para que ENTER me cree el personaje
			show_debug_message(">>> SELECCION: estaba en la partida sin personaje, vuelvo a elegir");
		}
	} else {
		sel_tarde_t = 0;
	}
}

/// Crea mi personaje en mi base y avisa a los demas (igual que al darle ENTER en la seleccion)
function scr_sel_crear_jugador() {
	global.myTeam = scr_my_team();
	var _base = (global.myTeam == "AZUL") ? obj_base_blue : obj_base_red;
	var _sx = instance_exists(_base) ? _base.x : ((global.myTeam == "AZUL") ? 100 : room_width - 100);
	var _sy = instance_exists(_base) ? _base.y : 400;
	instance_create_layer(_sx, _sy, "Instances", oPlayer);
	effect_create_above(ef_ring, _sx, _sy, 1, (global.myTeam == "AZUL") ? c_aqua : c_red);
	with (oOtherPlayer) {
		if (es_bot) continue;
		SendEventToClient(clientId, "pj_listo", { pj: global.pj_selected, fromId: global.clientId });
	}
	if (global.sfx) audio_play_sound(snd_ready, 1, false);
}

// ======================================================
// CHAT DE VOZ (SOLO SALAS PRIVADAS)
// - Sala de espera: hablan todos. Partida: solo te escucha tu equipo.
// - El microfono empieza APAGADO (al abrir el juego y al entrar a cada sala).
//   Un toque lo prende y otro lo apaga (boton del micro o la V). Ya no hay "mantener para hablar".
//   Solo se manda cuando de verdad hablas (si hay silencio no se gasta internet).
// - Si lo dejaste prendido en la sala, en la partida sigue prendido pero solo te oye tu equipo.
//   Si no tienes companeros (1 vs 1 o puros bots) no se graba nada.
// - Bocina: deja de oir a todos (en la sala, en la pausa o con la B).
// - Se graba con el microfono, se baja a 8000 Hz 16 bits mono y se manda cada ~0.2 s en base64
//   a cada jugador que debe oirte (este servidor manda de uno en uno, por eso es un envio por persona).
// - Cada jugador que habla tiene su propia cola de audio en mi aparato.
// - HTML5 no puede grabar (manual de GameMaker: "Most platforms except HTML5 support recording audio"),
//   ahi solo se intenta escuchar.
// - Todo va dentro de try/catch: si algo falla, el juego sigue y el error sale en el contador.
// Eventos: oBrain Async Grabacion (Other_73) -> scr_voz_async_grabacion
//          oBrain Async Reproduccion (Other_74) -> scr_voz_async_play
// ======================================================
#macro VOZ_DEBUG    false    // contador de prueba (enviados / recibidos / volumen). Ponlo en false cuando ya funcione
#macro VOZ_HZ       8000
#macro VOZ_TROZO    3200    // bytes por envio (0.2 s a 8000 Hz 16 bits)
#macro VOZ_UMBRAL   1200    // en ABIERTO: volumen minimo para mandar (de 32768). Sube si se manda ruido
#macro VOZ_COLGAR   20      // en ABIERTO: frames que sigue mandando despues de que dejas de hablar
#macro VOZ_PERMISO  "android.permission.RECORD_AUDIO"

function scr_voz_init() {
	if (variable_global_exists("voz") && is_struct(global.voz)) return;
	global.voz = {
		on: false, canal: -1, rate: 16000, fmt: buffer_s16, fijo: -1, fijo_tam: 0, pend: -1,
		env: 0, rec: 0, vol: 0, pico_t: 0, err: "",
		colas: {}, hablan: {}, mute: {},
		abierto_on: false, oir: true, perm_pedido: false,   // el micro empieza APAGADO
		panel: false, toque: false
	};
}

function scr_voz_err(_donde, _e) {
	scr_voz_init();
	var _m = is_struct(_e) && variable_struct_exists(_e, "message") ? _e.message : string(_e);
	global.voz.err = _donde + ": " + string_copy(_m, 1, 80);
	show_debug_message("[Voz] ERROR en " + _donde + ": " + string(_m));
}

/// ¿Estoy en una sala privada (esperando o jugando)?
function scr_voz_activa() {
	if (!variable_global_exists("ONLINE") || !global.ONLINE) return false;
	if (!scr_fin_es_privada()) return false;
	if (room == rm_menu) return instance_exists(oMenu) && oMenu.menu_state == "lobby_espera";
	return true;
}

/// ¿Este aparato puede grabar? (HTML5 no; Android necesita el permiso)
function scr_voz_puede_grabar() {
	if (os_browser != browser_not_a_browser) return false;
	if (os_type == os_android && !os_check_permission(VOZ_PERMISO)) return false;
	return audio_get_recorder_count() > 0;
}

/// Por que no puedo hablar (texto para el panel), o "" si si puedo
function scr_voz_motivo() {
	if (os_browser != browser_not_a_browser) return "VOZ NO DISPONIBLE EN NAVEGADOR (SOLO ESCUCHAS)";
	if (os_type == os_android && !os_check_permission(VOZ_PERMISO)) return "FALTA PERMISO DE MICROFONO";
	if (audio_get_recorder_count() <= 0) return "NO SE ENCONTRO MICROFONO";
	return "";
}

/// A quien le mando mi voz: en la sala de espera a todos; en la partida solo a mi equipo
function scr_voz_destinos() {
	var _l = [];
	var _sala = (room == rm_menu);
	var _yo = scr_my_team();
	with (oOtherPlayer) {
		if (es_bot || clientId < 0) continue;
		if (!_sala && team != _yo) continue;
		array_push(_l, clientId);
	}
	return _l;
}

function scr_voz_hablando(_cid) {
	scr_voz_init();
	var _k = string(_cid);
	return variable_struct_exists(global.voz.hablan, _k) && global.voz.hablan[$ _k] > 0;
}

/// ¿Yo estoy hablando ahorita? (para mi propio microfonito)
function scr_voz_yo_hablo() {
	scr_voz_init();
	opt_init();
	if (!global.voz.on) return false;
	return (global.voz.pico_t > 0);
}

function scr_voz_empezar() {
	var _v = global.voz;
	if (!scr_voz_puede_grabar()) {
		if (os_type == os_android && !os_check_permission(VOZ_PERMISO) && !_v.perm_pedido) {
			_v.perm_pedido = true;
			os_request_permission(VOZ_PERMISO);
			show_debug_message("[Voz] pidiendo permiso de microfono");
		}
		return;
	}
	_v.canal = audio_start_recording(0);
	var _info = audio_get_recorder_info(0);
	if (ds_exists(_info, ds_type_map)) {
		if (!is_undefined(_info[? "sample_rate"])) _v.rate = _info[? "sample_rate"];
		if (!is_undefined(_info[? "data_format"])) _v.fmt = _info[? "data_format"];
		ds_map_destroy(_info);
	}
	if (_v.pend == -1) _v.pend = buffer_create(VOZ_TROZO * 2, buffer_grow, 1);
	buffer_seek(_v.pend, buffer_seek_start, 0);
	_v.on = true;
	show_debug_message("[Voz] grabando: canal " + string(_v.canal) + ", " + string(_v.rate) + " Hz, formato " + string(_v.fmt));
}

function scr_voz_parar() {
	var _v = global.voz;
	if (_v.canal != -1) audio_stop_recording(_v.canal);
	_v.canal = -1;
	_v.on = false;
	// Lo que quedo sin mandar (si es mas de 0.05 s)
	if (_v.pend != -1 && buffer_tell(_v.pend) >= 800) scr_voz_mandar();
	if (_v.pend != -1) buffer_seek(_v.pend, buffer_seek_start, 0);
	_v.vol = 0;
	show_debug_message("[Voz] dejo de grabar");
}

/// Manda lo que hay en el buffer de envio
function scr_voz_mandar() {
	var _v = global.voz;
	var _len = buffer_tell(_v.pend);
	buffer_seek(_v.pend, buffer_seek_start, 0);
	if (_len <= 0) return;
	opt_init();
	if (_v.pico_t <= 0) return;   // en silencio: no se manda
	var _d = buffer_base64_encode(_v.pend, 0, _len);
	var _m = { a: global.clientId, d: _d };
	var _l = scr_voz_destinos();
	for (var i = 0; i < array_length(_l); i++) SendEventToClient(_l[i], "voz", _m);
	_v.env++;
	_v.hablan[$ string(global.clientId)] = 15;
}

/// oBrain, Async - Grabacion de audio (Other_73)
function scr_voz_async_grabacion() {
	try {
		scr_voz_init();
		var _v = global.voz;
		if (!_v.on || async_load[? "channel_index"] != _v.canal) return;
		var _len = async_load[? "data_len"];
		if (is_undefined(_len) || _len <= 0) return;
		// 1) COPIAR primero a mi buffer fijo (leer directo del de GameMaker daba silencio)
		if (_v.fijo == -1 || _v.fijo_tam < _len) {
			if (_v.fijo != -1) buffer_delete(_v.fijo);
			_v.fijo = buffer_create(_len, buffer_fixed, 1);
			_v.fijo_tam = _len;
		}
		buffer_copy(async_load[? "buffer_id"], 0, _len, _v.fijo, 0);

		// 2) Bajar a 8000 Hz, 16 bits, mono
		var _bps = (_v.fmt == buffer_u8) ? 1 : ((_v.fmt == buffer_f32) ? 4 : 2);
		var _n = _len div _bps;
		var _paso = max(1, _v.rate / VOZ_HZ);
		var _pico = 0;
		for (var p = 0; p < _n; p += _paso) {
			var _off = floor(p) * _bps;
			if (_off + _bps > _len) break;
			var _s;
			if (_bps == 1) _s = (buffer_peek(_v.fijo, _off, buffer_u8) - 128) * 256;
			else if (_bps == 4) _s = buffer_peek(_v.fijo, _off, buffer_f32) * 32767;
			else _s = buffer_peek(_v.fijo, _off, buffer_s16);
			_s = clamp(round(_s), -32768, 32767);
			buffer_write(_v.pend, buffer_s16, _s);
			_pico = max(_pico, abs(_s));
		}
		_v.vol = round(_pico / 32768 * 100);
		if (_pico >= VOZ_UMBRAL) _v.pico_t = VOZ_COLGAR;

		// 3) Cada ~0.2 s se manda un pedacito
		if (buffer_tell(_v.pend) >= VOZ_TROZO) scr_voz_mandar();
	} catch (_e) { scr_voz_err("grabar", _e); }
}

/// Llega voz de alguien (callback_ReceivedEvent, "voz")
function scr_voz_recibir(_m, _de) {
	try {
		scr_voz_init();
		if (!scr_voz_activa()) return;
		if (!is_struct(_m) || !variable_struct_exists(_m, "d") || !is_string(_m.d)) return;
		var _k = string(_de);
		if (variable_struct_exists(global.voz.mute, _k) && global.voz.mute[$ _k]) return;   // lo silencie
		if (!scr_voz_oir()) return;                                                           // bocina apagada
		// base64 -> buffer "grow"; la cola solo acepta buffers FIJOS: se copia
		var _b = buffer_base64_decode(_m.d);
		var _sz = buffer_get_size(_b);
		if (_sz < 2) { buffer_delete(_b); return; }
		_sz -= _sz mod 2;
		var _fx = buffer_create(_sz, buffer_fixed, 1);
		buffer_copy(_b, 0, _sz, _fx, 0);
		buffer_delete(_b);

		var _c = global.voz.colas[$ _k];
		if (is_undefined(_c)) {
			_c = { q: audio_create_play_queue(buffer_s16, VOZ_HZ, audio_mono), snd: -1, n: 0 };
			global.voz.colas[$ _k] = _c;
		}
		audio_queue_sound(_c.q, _fx, 0, _sz);
		_c.n++;
		var _suena = (_c.snd >= 0) && audio_is_playing(_c.snd);
		if (!_suena) {
			if (_c.snd >= 0) { _c.snd = -1; _c.n = 1; }   // termino lo anterior: este es el primero
			if (_c.n >= 2) {                                // juntar 2 pedacitos antes de sonar
				_c.snd = audio_play_sound(_c.q, 10, false);
				opt_init();
				if (_c.snd >= 0) audio_sound_gain(_c.snd, global.opt.vol_voz / 100, 0);
				_c.n = 0;
			}
		}
		global.voz.rec++;
		global.voz.hablan[$ _k] = 15;
		global.voz.duck_t = VOZ_BAJA_T;   // la musica baja mientras se oye a alguien
	} catch (_e) { scr_voz_err("recibir", _e); }
}

/// oBrain, Async - Reproduccion de audio (Other_74): borra el buffer que ya sono
function scr_voz_async_play() {
	try {
		var _b = async_load[? "buffer_id"];
		if (!is_undefined(_b) && buffer_exists(_b)) buffer_delete(_b);
	} catch (_e) { scr_voz_err("play", _e); }
}

/// Apaga todo (al salir de la sala)
function scr_voz_apagar() {
	try {
		scr_voz_init();
		var _v = global.voz;
		if (_v.on) scr_voz_parar();
		var _k = variable_struct_get_names(_v.colas);
		for (var i = 0; i < array_length(_k); i++) {
			var _c = _v.colas[$ _k[i]];
			if (_c.snd >= 0) audio_stop_sound(_c.snd);
			audio_free_play_queue(_c.q);
		}
		_v.colas = {};
		_v.hablan = {};
		_v.panel = false;
	} catch (_e) { scr_voz_err("apagar", _e); }
}

/// Silenciar / quitar silencio a alguien (solo en mi aparato)
function scr_voz_mute_cambiar(_cid) {
	var _v = global.voz;
	var _k = string(_cid);
	var _m = !(variable_struct_exists(_v.mute, _k) && _v.mute[$ _k]);
	_v.mute[$ _k] = _m;
	if (_m) {
		var _c = _v.colas[$ _k];
		if (!is_undefined(_c) && _c.snd >= 0) { audio_stop_sound(_c.snd); _c.snd = -1; _c.n = 0; }
	}
}

function scr_voz_muted(_cid) {
	scr_voz_init();
	var _k = string(_cid);
	return variable_struct_exists(global.voz.mute, _k) && global.voz.mute[$ _k];
}

/// Medidas del panel (sala de espera a la izquierda; en pausa tambien a la izquierda)
function scr_voz_geo() {
	var _gw = display_get_gui_width(), _gh = display_get_gui_height();
	var _u = clamp(min(_gw / 1280, _gh / 720), 0.6, 1.6);
	return { u: _u, x: 20 * _u, y: 80 * _u, w: 170 * _u, h: 32 * _u,
		hx: 20 * _u, hy: 120 * _u, hw: 170 * _u, hh: 48 * _u,       // boton HABLAR (sala de espera)
		pw: 300 * _u, fila: 34 * _u };
}

/// Quienes salen en el panel: yo y las personas (en la partida, solo mi equipo)
function scr_voz_lista() {
	var _l = [{ cid: global.clientId, n: global.myName, yo: true, eq: scr_my_team() }];
	var _sala = (room == rm_menu);
	var _yo = scr_my_team();
	with (oOtherPlayer) {
		if (es_bot || clientId < 0) continue;
		var _eq = (team != "") ? team : lobby_team;
		if (!_sala && team != _yo) continue;
		array_push(_l, { cid: clientId, n: (Name != "") ? Name : "...", yo: false, eq: _eq });
	}
	return _l;
}

/// ¿Algun dedo (o el mouse) aprieta este rectangulo?
function __voz_toca(_x1, _y1, _x2, _y2, _solo_nuevo) {
	for (var d = 0; d < 5; d++) {
		var _on = _solo_nuevo ? device_mouse_check_button_pressed(d, mb_left) : device_mouse_check_button(d, mb_left);
		if (!_on) continue;
		var _mx = device_mouse_x_to_gui(d), _my = device_mouse_y_to_gui(d);
		if (point_in_rectangle(_mx, _my, _x1, _y1, _x2, _y2)) return true;
	}
	return false;
}

/// Va en el Step de oBrain (siempre). Decide cuando grabar y maneja el panel.
function scr_voz_step() {
	try {
		scr_voz_init();
		opt_init();
		var _v = global.voz;
		_v.toque = false;
		// Bajan los tiempos de "esta hablando"
		var _hk = variable_struct_get_names(_v.hablan);
		for (var i = 0; i < array_length(_hk); i++) if (_v.hablan[$ _hk[i]] > 0) _v.hablan[$ _hk[i]] -= 1;
		if (_v.pico_t > 0) _v.pico_t--;
		if (!variable_struct_exists(_v, "duck_t")) _v.duck_t = 0;
		if (_v.duck_t > 0) _v.duck_t--;

		if (!scr_voz_activa()) {
			if (_v.on || array_length(variable_struct_get_names(_v.colas)) > 0) scr_voz_apagar();
			return;
		}
		// Volumen de voz de los que ya suenan
		var _ck = variable_struct_get_names(_v.colas);
		for (var i = 0; i < array_length(_ck); i++) {
			var _c = _v.colas[$ _ck[i]];
			if (_c.snd >= 0 && audio_is_playing(_c.snd)) audio_sound_gain(_c.snd, global.opt.vol_voz / 100, 0);
		}

		var _sala = (room == rm_menu);
		var _chat = _sala && variable_global_exists("chat") && is_struct(global.chat) && global.chat.abierto;
		var _g = scr_voz_geo();

		// --- Que quiere el jugador: V o el boton del micro (tocar = prender/apagar), B o la bocina ---
		var _tap = false, _tap_b = false;
		if (!_chat) {
			_tap   = keyboard_check_pressed(ord("V"));
			_tap_b = keyboard_check_pressed(ord("B"));
		}
		if (!_sala) {
			_tap   = _tap   || __touch_pressed(string(ord("V")));
			_tap_b = _tap_b || __touch_pressed(string(ord("B")));
		} else if (!_chat && !(instance_exists(oMenu) && oMenu.confirmar_salida)) {
			var _ic = scr_voz_iconos_geo(_g);
			if (__voz_toca(_ic.mx1, _ic.y1, _ic.mx2, _ic.y2, true)) { _tap = true; _v.toque = true; }
			if (__voz_toca(_ic.bx1, _ic.y1, _ic.bx2, _ic.y2, true)) { _tap_b = true; _v.toque = true; }
		}
		if (_tap) _v.abierto_on = !_v.abierto_on;
		if (_tap_b) scr_voz_oir_cambiar();
		// Sin companeros (1 vs 1 o puros bots) no se graba: no hay a quien hablarle
		var _quiere = _v.abierto_on && scr_voz_hay_quien();
		if (_quiere && !_v.on) scr_voz_empezar();
		if (!_quiere && _v.on) scr_voz_parar();

		// --- Panel: abrir/cerrar y SILENCIAR (sala de espera o pausa) ---
		var _ver_panel = _sala || global.pausa;
		if (_ver_panel && !_chat && !(instance_exists(oMenu) && oMenu.confirmar_salida)) {
			var _abierto = _sala ? _v.panel : true;
			if (_sala && __voz_toca(_g.x, _g.y, _g.x + _g.w, _g.y + _g.h, true)) { _v.panel = !_v.panel; _v.toque = true; }
			else if (!_sala && __voz_toca(_g.x + _g.pw - 130 * _g.u, 120 * _g.u, _g.x + _g.pw - 6 * _g.u, 120 * _g.u + 30 * _g.u, true)) {
				// En la pausa: bocina para dejar de oir a todos
				scr_voz_oir_cambiar(); _v.toque = true;
			}
			else if (_abierto) {
				var _l = scr_voz_lista();
				var _y0 = _sala ? _g.y + _g.h + _g.hh + 18 * _g.u : 120 * _g.u;
				for (var i = 0; i < array_length(_l); i++) {
					if (_l[i].yo) continue;
					var _ry = _y0 + 30 * _g.u + i * _g.fila;
					if (__voz_toca(_g.x + _g.pw - 110 * _g.u, _ry, _g.x + _g.pw - 6 * _g.u, _ry + _g.fila - 4 * _g.u, true)) {
						scr_voz_mute_cambiar(_l[i].cid);
						_v.toque = true;
					}
				}
			}
		}
	} catch (_e) { scr_voz_err("step", _e); }
}

/// ¿La voz uso el toque este frame? (para que en la sala no se tome como otra cosa)
function scr_voz_toque() {
	return variable_global_exists("voz") && is_struct(global.voz) && global.voz.toque;
}

// ------------------------------------------------------
// DIBUJOS
// ------------------------------------------------------

/// Microfonito (blanco) centrado en x, y
function __voz_mic(_x, _y, _s, _col, _a) {
	draw_set_alpha(_a);
	draw_set_colour(_col);
	draw_roundrect_ext(_x - 3 * _s, _y - 7 * _s, _x + 3 * _s, _y + 3 * _s, 6 * _s, 6 * _s, false);
	draw_line_width(_x - 6 * _s, _y, _x - 5 * _s, _y + 4 * _s, 1.5 * _s);
	draw_line_width(_x + 6 * _s, _y, _x + 5 * _s, _y + 4 * _s, 1.5 * _s);
	draw_line_width(_x - 5 * _s, _y + 4 * _s, _x + 5 * _s, _y + 4 * _s, 1.5 * _s);
	draw_line_width(_x, _y + 4 * _s, _x, _y + 8 * _s, 1.5 * _s);
	draw_set_alpha(1);
}

/// Ondas animadas a la derecha del microfono
function __voz_ondas(_x, _y, _s) {
	var _t = (current_time / 1000) * 3;
	for (var k = 0; k < 3; k++) {
		var _r = (7 + k * 4 + frac(_t) * 4) * _s;
		draw_set_alpha(0.85 - k * 0.25);
		draw_set_colour(make_color_rgb(120, 220, 140));
		for (var a = -35; a <= 35; a += 10) {
			draw_line(_x + lengthdir_x(_r, a), _y + lengthdir_y(_r, a), _x + lengthdir_x(_r, a + 10), _y + lengthdir_y(_r, a + 10));
		}
	}
	draw_set_alpha(1);
}

/// OPCION A: burbuja con microfono sobre la cabeza (Draw de oPlayer y oOtherPlayer)
function scr_voz_draw_cabeza(_x, _y) {
	draw_set_alpha(0.6);
	draw_set_colour(c_black);
	draw_roundrect_ext(_x - 13, _y - 9, _x + 13, _y + 9, 8, 8, false);
	draw_set_alpha(1);
	__voz_mic(_x - 4, _y, 0.8, c_white, 1);
	__voz_ondas(_x - 2, _y, 0.6);
	draw_set_colour(c_white);
}

/// Badge en la burbujita del borde (fb_indicadores): x, y = centro de la burbuja
function scr_voz_draw_borde(_bx, _by) {
	draw_set_colour(make_color_rgb(11, 15, 26));
	draw_circle(_bx + 21, _by - 21, 12, false);
	draw_set_colour(make_color_rgb(78, 200, 120));
	draw_circle(_bx + 21, _by - 21, 10, false);
	__voz_mic(_bx + 21, _by - 21, 0.75, c_white, 1);
}

/// Una fila del panel
function __voz_fila(_x, _y, _w, _h, _it, _u) {
	var _habla = _it.yo ? scr_voz_yo_hablo() : scr_voz_hablando(_it.cid);
	var _mute = !_it.yo && scr_voz_muted(_it.cid);
	if (_habla) { draw_set_alpha(0.18); draw_set_colour(make_color_rgb(120, 220, 140)); draw_rectangle(_x, _y, _x + _w, _y + _h, false); draw_set_alpha(1); }
	draw_set_colour((_it.eq == "ROJO") ? make_color_rgb(255, 90, 100) : make_color_rgb(79, 156, 255));
	draw_rectangle(_x, _y, _x + 3 * _u, _y + _h, false);
	__voz_mic(_x + 18 * _u, _y + _h / 2, 0.9 * _u, c_white, _mute ? 0.3 : 1);
	if (_habla) __voz_ondas(_x + 20 * _u, _y + _h / 2, 0.6 * _u);
	draw_set_font(fnt_menu);
	draw_set_halign(fa_left);
	draw_set_valign(fa_middle);
	draw_set_colour(c_white);
	var _nom = string(_it.n) + (_it.yo ? " (TU)" : "");
	draw_text_transformed(_x + 40 * _u, _y + _h / 2, string_copy(_nom, 1, 14), 0.6 * _u, 0.6 * _u, 0);
	if (!_it.yo) {
		draw_set_halign(fa_center);
		draw_set_colour(_mute ? make_color_rgb(255, 107, 122) : make_color_rgb(169, 180, 208));
		draw_text_transformed(_x + _w - 58 * _u, _y + _h / 2, _mute ? "SILENCIADO" : "SILENCIAR", 0.5 * _u, 0.5 * _u, 0);
	}
	draw_set_halign(fa_left);
}

/// OPCION C: panel de la sala de espera (Draw GUI de oMenu) y de la pausa (Draw GUI de oBrain)
function scr_voz_draw_panel() {
	if (!scr_voz_activa()) return;
	scr_voz_init();
	opt_init();
	var _v = global.voz;
	var _g = scr_voz_geo();
	var _u = _g.u;
	var _sala = (room == rm_menu);
	var _tinta = make_color_rgb(11, 15, 26);
	var _oro = make_color_rgb(255, 212, 71);
	var _l = scr_voz_lista();

	if (_sala) {
		// Barrita plegada: quien habla
		var _quien = "";
		for (var i = 0; i < array_length(_l); i++) {
			var _h = _l[i].yo ? scr_voz_yo_hablo() : scr_voz_hablando(_l[i].cid);
			if (_h) _quien += ((_quien == "") ? "" : ", ") + string(_l[i].n);
		}
		draw_set_alpha(0.85); draw_set_colour(_tinta);
		draw_roundrect_ext(_g.x, _g.y, _g.x + _g.w, _g.y + _g.h, 8, 8, false);
		draw_set_alpha(1);
		__voz_mic(_g.x + 16 * _u, _g.y + _g.h / 2, 0.9 * _u, c_white, 1);
		draw_set_font(fnt_menu);
		draw_set_halign(fa_left); draw_set_valign(fa_middle);
		draw_set_colour((_quien != "") ? make_color_rgb(123, 224, 143) : make_color_rgb(169, 180, 208));
		var _txt = (_quien != "") ? string_copy(_quien, 1, 14) + " HABLA" : (_v.panel ? "VOZ (CERRAR)" : "VOZ (ABRIR)");
		draw_text_transformed(_g.x + 32 * _u, _g.y + _g.h / 2, _txt, 0.55 * _u, 0.55 * _u, 0);

		// Iconos redondos: MICRO (tocar = prender / apagar) y BOCINA (oir / no oir a nadie)
		var _motivo = scr_voz_motivo();
		var _ic = scr_voz_iconos_geo(_g);
		var _verde = make_color_rgb(78, 200, 120), _gris = make_color_rgb(136, 135, 128);
		var _mon = _v.abierto_on && _motivo == "";
		__voz_icono(_ic.mcx, _ic.cy, _ic.r, (_motivo != "") ? make_color_rgb(90, 90, 100) : (_mon ? _verde : _gris), _mon, "mic", _u);
		__voz_icono(_ic.bcx, _ic.cy, _ic.r, scr_voz_oir() ? _verde : _gris, scr_voz_oir(), "bocina", _u);
		draw_set_font(fnt_small);
		draw_set_halign(fa_center); draw_set_valign(fa_top);
		draw_set_colour(_mon ? make_color_rgb(123, 224, 143) : make_color_rgb(207, 211, 224));
		var _bt = (_motivo != "") ? "SIN VOZ" : (_mon ? "MIC ENCENDIDO" : "MIC APAGADO");
		if (!touch_mode() && _motivo == "") _bt += " [V]";
		draw_text_transformed(_ic.mcx, _ic.cy + _ic.r + 4 * _u, _bt, 0.5 * _u, 0.5 * _u, 0);
		draw_set_colour(scr_voz_oir() ? make_color_rgb(123, 224, 143) : make_color_rgb(207, 211, 224));
		draw_text_transformed(_ic.bcx, _ic.cy + _ic.r + 4 * _u, scr_voz_oir() ? "ESCUCHAR" : "SILENCIO", 0.5 * _u, 0.5 * _u, 0);
		draw_set_halign(fa_left); draw_set_valign(fa_middle);
		var _col = make_color_rgb(169, 180, 208);
		if (_motivo != "") {
			draw_set_colour(make_color_rgb(169, 180, 208)); draw_set_alpha(0.7);
			draw_set_font(fnt_small);
			draw_text_ext_transformed(_g.hx, _g.hy + _g.hh + 12 * _u, _motivo, -1, _g.hw / (0.6 * _u), 0.6 * _u, 0.6 * _u, 0);
			draw_set_alpha(1);
		}
		if (!_v.panel) { scr_voz_draw_debug(_g.x, _g.hy + _g.hh + 40 * _u); return; }
	}

	// Lista con SILENCIAR
	var _y0 = _sala ? _g.y + _g.h + _g.hh + 18 * _u : 120 * _u;
	var _ph = 30 * _u + array_length(_l) * _g.fila + 6 * _u;
	draw_set_alpha(0.9); draw_set_colour(_tinta);
	draw_roundrect_ext(_g.x, _y0, _g.x + _g.pw, _y0 + _ph, 10, 10, false);
	draw_set_alpha(1); draw_set_colour(_oro);
	draw_set_font(fnt_menu);
	draw_set_halign(fa_left); draw_set_valign(fa_middle);
	draw_text_transformed(_g.x + 10 * _u, _y0 + 15 * _u, _sala ? "VOZ DE LA SALA" : "VOZ DE TU EQUIPO", 0.6 * _u, 0.6 * _u, 0);
	if (!_sala) {
		// Bocina en la pausa: dejar de oir a todos
		var _oi = scr_voz_oir();
		__voz_bocina(_g.x + _g.pw - 116 * _u, _y0 + 15 * _u, 0.9 * _u, _oi ? make_color_rgb(123, 224, 143) : make_color_rgb(255, 107, 122), _oi);
		draw_set_halign(fa_left);
		draw_set_colour(_oi ? make_color_rgb(169, 180, 208) : make_color_rgb(255, 107, 122));
		draw_text_transformed(_g.x + _g.pw - 100 * _u, _y0 + 15 * _u, _oi ? "SILENCIAR TODO" : "SILENCIADOS", 0.5 * _u, 0.5 * _u, 0);
	}
	for (var i = 0; i < array_length(_l); i++) {
		__voz_fila(_g.x + 4 * _u, _y0 + 30 * _u + i * _g.fila, _g.pw - 8 * _u, _g.fila - 4 * _u, _l[i], _u);
	}
	scr_voz_draw_debug(_g.x, _y0 + _ph + 14 * _u);
	draw_set_halign(fa_left); draw_set_valign(fa_top);
	draw_set_colour(c_white); draw_set_alpha(1);
}

/// Contador de prueba (VOZ_DEBUG)
function scr_voz_draw_debug(_x, _y) {
	if (!VOZ_DEBUG || !scr_voz_activa()) return;
	scr_voz_init();
	var _v = global.voz;
	draw_set_font(fnt_small);
	draw_set_halign(fa_left); draw_set_valign(fa_top);
	draw_set_colour(c_black); draw_set_alpha(0.6);
	var _t = "[VOZ] env " + string(_v.env) + "  rec " + string(_v.rec) + "  vol " + string(_v.vol) + "%";
	draw_text(_x + 1, _y + 1, _t);
	draw_set_alpha(1); draw_set_colour(c_yellow);
	draw_text(_x, _y, _t);
	if (_v.err != "") { draw_set_colour(c_red); draw_text(_x, _y + 14, _v.err); }
	draw_set_colour(c_white);
}

/// ¿Ese punto cae en la barrita, el boton HABLAR o el panel abierto de la sala? (oMenu, para no tomar el toque como otra cosa)
function scr_voz_en_zona(_mx, _my) {
	if (!scr_voz_activa() || room != rm_menu) return false;
	scr_voz_init();
	var _g = scr_voz_geo();
	if (point_in_rectangle(_mx, _my, _g.x, _g.y, _g.x + _g.w, _g.y + _g.h)) return true;
	if (point_in_rectangle(_mx, _my, _g.hx, _g.hy, _g.hx + _g.hw, _g.hy + _g.hh + 16 * _g.u)) return true;
	if (global.voz.panel) {
		var _y0 = _g.y + _g.h + _g.hh + 18 * _g.u;
		var _ph = 30 * _g.u + array_length(scr_voz_lista()) * _g.fila + 6 * _g.u;
		if (point_in_rectangle(_mx, _my, _g.x, _y0, _g.x + _g.pw, _y0 + _ph)) return true;
	}
	return false;
}

// ------------------------------------------------------
// MUSICA MAS BAJITA MIENTRAS ALGUIEN HABLA (como Discord / Free Fire)
// Mientras se oye la voz de alguien la musica baja a VOZ_MUSICA; cuando se calla, a los
// VOZ_BAJA_T frames vuelve sola a su volumen (scr_musica_step la sube y baja suave).
// Tu propia voz no la baja (tu no te escuchas).
// ------------------------------------------------------
#macro VOZ_MUSICA  0.3   // a cuanto baja la musica (0.3 = 30%)
#macro VOZ_BAJA_T  60    // cuanto se queda bajita despues de la ultima voz (60 = 1 segundo)

function scr_voz_baja_musica() {
	if (!variable_global_exists("voz") || !is_struct(global.voz)) return 1;
	if (!variable_struct_exists(global.voz, "duck_t") || global.voz.duck_t <= 0) return 1;
	if (!scr_voz_activa()) return 1;
	return VOZ_MUSICA;
}

/// Equipo de un jugador que acaba de aparecer: el que trae en sus datos (_TEAM),
/// o el que repartio el lider en la sala. "" si todavia no se sabe.
function scr_sala_equipo_de(_cid, _sp_txt) {
	try {
		if (is_string(_sp_txt) && _sp_txt != "") {
			var _sp = json_parse(_sp_txt);
			if (is_struct(_sp) && variable_struct_exists(_sp, "_TEAM")) {
				var _t = string(_sp._TEAM);
				if (_t == "AZUL" || _t == "ROJO") return _t;
			}
		}
	} catch (_e) {}
	if (variable_global_exists("sala_eq") && is_struct(global.sala_eq)) {
		var _k = string(_cid);
		if (variable_struct_exists(global.sala_eq, _k)) return global.sala_eq[$ _k];
	}
	return "";
}

// ======================================================
// SALA PRIVADA: CAMBIAR DE EQUIPO (opcion B: tocar un lugar con BOT del otro equipo)
// El lider decide: si en ese equipo hay lugar, te pasa y manda los equipos a todos.
// ======================================================
function scr_sala_cambiar_equipo(_cid, _t) {
	if (_t != "AZUL" && _t != "ROJO") return false;
	var _s = scr_sala_slots();
	var _lista = (_t == "AZUL") ? _s.azul : _s.rojo;
	var _humanos = 0;
	for (var i = 0; i < array_length(_lista); i++) if (_lista[i].tipo != "bot") _humanos++;
	if (_humanos >= _s.cupo) return false;   // ya esta lleno de personas
	if (!variable_global_exists("sala_eq") || !is_struct(global.sala_eq)) global.sala_eq = {};
	global.sala_eq[$ string(_cid)] = _t;
	if (_cid == global.clientId) { global.serverTeam = _t; global.myTeam = _t; }
	else with (oOtherPlayer) if (clientId == _cid) lobby_team = _t;
	scr_ajustes_enviar();   // lleva los equipos nuevos a todos
	return true;
}

/// En la sala: ¿toco un lugar con BOT del otro equipo? Pide el cambio. Devuelve true si lo toco.
function scr_sala_toque_cambio(_mx, _my) {
	if (!scr_fin_es_privada()) return false;
	var _yo = scr_my_team();
	var _otro = (_yo == "AZUL") ? "ROJO" : "AZUL";
	var _s = scr_sala_slots();
	var _lista = (_otro == "AZUL") ? _s.azul : _s.rojo;
	for (var k = 0; k < array_length(_lista); k++) {
		if (_lista[k].tipo != "bot") continue;
		var _pos = scr_sala_slot_pos(_otro == "ROJO", k);
		if (point_in_rectangle(_mx, _my, _pos[0], _pos[1], _pos[0] + 400, _pos[1] + 60)) {
			if (oBrain.AmIPseudoHost) scr_sala_cambiar_equipo(global.clientId, _otro);
			else SendEventToClient(oBrain.pseudoHostClientId, "pedir_equipo", { t: _otro });
			if (global.sfx) audio_play_sound(snd_scroll, 1, false);
			return true;
		}
	}
	return false;
}

// ======================================================
// SELECCION SINCRONIZADA: que nadie se quede pegado en "ELIGE TU PERSONAJE"
// 1) En sala privada el lider no arranca hasta que esten todos los de la lista (o se acabe el tiempo).
// 2) El lider manda cada segundo "estado_partida". Si a alguien se le perdio el aviso de que
//    empezo (cargo lento el mapa), lo recibe aqui y entra: si no eligio, le sale la seleccion
//    tarde (scr_sel_tarde) y aparece en su base.
// ======================================================

/// Ya estan en el mapa todos los que empezaron en la sala? (fuera de sala privada siempre true)
function scr_sala_roster_presentes() {
	if (!variable_global_exists("sala_roster") || !is_array(global.sala_roster)) return true;
	for (var i = 0; i < array_length(global.sala_roster); i++) {
		var _cid = global.sala_roster[i];
		if (_cid == global.clientId || scr_botnet_es_id(_cid)) continue;
		var _esta = false;
		with (oOtherPlayer) if (clientId == _cid) _esta = true;
		if (!_esta) return false;
	}
	return true;
}

/// Va en el Step de oBrain: el lider avisa cada segundo
function scr_sala_estado_step() {
	if (!global.ONLINE || room == rm_menu || !oBrain.AmIPseudoHost) return;
	if (!variable_instance_exists(id, "estado_cd")) estado_cd = 0;
	estado_cd--;
	if (estado_cd > 0) return;
	estado_cd = room_speed;
	var _m = { intro: intro_disparada, t: timer_intro };
	with (oOtherPlayer) if (!es_bot) SendEventToClient(clientId, "estado_partida", _m);
}

/// Lo que recibe cada jugador
function scr_sala_estado_recibir(_m) {
	if (!is_struct(_m) || room == rm_menu || oBrain.AmIPseudoHost) return;
	if (!variable_struct_exists(_m, "intro")) return;
	if (_m.intro && !oBrain.intro_disparada && !(variable_global_exists("game_over") && global.game_over)) {
		// Ya empezo y yo no me entere: entro (si no tengo personaje, me sale la seleccion tarde)
		show_debug_message(">>> SELECCION: el lider ya empezo y no me llego el aviso, entro");
		global.fase_seleccion = false;
		oBrain.intro_disparada = true;
		oBrain.timer_intro = -1;
		scr_trigger_intro("", "");
	}
	else if (!_m.intro && !oBrain.intro_disparada && variable_struct_exists(_m, "t") && is_numeric(_m.t) && _m.t > 0) {
		oBrain.timer_intro = _m.t;   // mismo reloj de seleccion que el lider
	}
}

// ======================================================
// BOTON LISTO EN LA SALA PRIVADA (como Free Fire)
// Cada persona (menos el lider) da LISTO. El lider solo puede EMPEZAR cuando todos estan listos.
// Los bots siempre cuentan como listos. Si cambias de equipo, se te quita el LISTO.
// Cada uno manda su LISTO a todos (al tocarlo y cada 2 segundos, por si alguien entro despues
// o cambio el lider). Va en oMenu Step / Draw_64 y en callback_ReceivedEvent ("sala_listo").
// ======================================================

function scr_sala_listo_init() {
	if (!variable_global_exists("sala_listo")) global.sala_listo = false;
	if (!variable_global_exists("sala_listo_eq")) global.sala_listo_eq = "";
}

/// Le digo a todos si estoy listo
function scr_sala_listo_mandar() {
	scr_sala_listo_init();
	var _m = { l: global.sala_listo };
	with (oOtherPlayer) if (!es_bot) SendEventToClient(clientId, "sala_listo", _m);
}

function scr_sala_listo_poner(_v) {
	scr_sala_listo_init();
	global.sala_listo = _v;
	scr_sala_listo_mandar();
	show_debug_message(">>> SALA: estoy listo = " + string(_v));
}

/// Esta listo otro jugador de la sala?
function scr_sala_listo_de(_cid) {
	var _ok = false;
	with (oOtherPlayer) if (clientId == _cid && variable_instance_exists(id, "sala_listo") && sala_listo) _ok = true;
	return _ok;
}

/// Cuantas personas faltan por dar LISTO (para el lider; sin contar bots ni al lider)
function scr_sala_faltan_listos() {
	var _n = 0;
	with (oOtherPlayer) {
		if (es_bot) continue;
		if (!variable_instance_exists(id, "sala_listo") || !sala_listo) _n++;
	}
	return _n;
}

/// Lo recibe cada uno cuando otro cambia su LISTO
function scr_sala_listo_recibir(_cid, _m) {
	if (room != rm_menu || !is_struct(_m) || !variable_struct_exists(_m, "l")) return;
	var _v = (_m.l == true);
	with (oOtherPlayer) if (clientId == _cid) sala_listo = _v;
}

/// Cada step en la sala (lo llama oMenu)
function scr_sala_listo_step() {
	scr_sala_listo_init();
	if (!variable_instance_exists(id, "listo_cd")) listo_cd = 0;
	if (!variable_instance_exists(id, "listo_aviso_t")) listo_aviso_t = 0;
	if (listo_aviso_t > 0) listo_aviso_t--;

	// Si me cambiaron de equipo, se me quita el LISTO
	var _eq = (variable_global_exists("serverTeam")) ? string(global.serverTeam) : "";
	if (_eq != global.sala_listo_eq) {
		global.sala_listo_eq = _eq;
		if (global.sala_listo) scr_sala_listo_poner(false);
	}

	// El lider no necesita LISTO (el es el que le da a EMPEZAR)
	if (oBrain.AmIPseudoHost) { global.sala_listo = false; return; }

	// Lo repito cada 2 segundos por si alguien entro despues o cambio el lider
	listo_cd--;
	if (listo_cd <= 0) {
		listo_cd = room_speed * 2;
		scr_sala_listo_mandar();
	}
}

/// EMPATE: no se ganan ni se pierden trofeos, solo +10 XP por jugar (en sala privada nada)
function scr_empate_premio() {
	if (scr_fin_es_privada()) return;
	scr_eq_premio(25);   // monedas por jugar (scr_armas, EQUIPAMIENTO)
	global.xp += 10;
	while (global.xp >= 100) { global.lvl += 1; global.xp -= 100; }
	scr_save_to_local();
	scr_save_to_cloud();
	show_debug_message(">>> FIN: EMPATE, +10 XP");
}

/// Borde del panel mitad azul (izquierda) y mitad roja (derecha) para el EMPATE (oBrain Draw_64)
function scr_borde_mitades(_x1, _y1, _x2, _y2, _r, _cl, _cr, _ancho) {
	var _mx = (_x1 + _x2) / 2;
	// Puntos de la mitad derecha: arriba al centro -> esquina -> lado -> esquina -> abajo al centro
	var _p = [[_mx, _y1], [_x2 - _r, _y1]];
	for (var a = 90; a >= 0; a -= 15) array_push(_p, [_x2 - _r + lengthdir_x(_r, a), _y1 + _r + lengthdir_y(_r, a)]);
	array_push(_p, [_x2, _y2 - _r]);
	for (var a = 0; a >= -90; a -= 15) array_push(_p, [_x2 - _r + lengthdir_x(_r, a), _y2 - _r + lengthdir_y(_r, a)]);
	array_push(_p, [_mx, _y2]);
	for (var i = 0; i < array_length(_p) - 1; i++) {
		var _a = _p[i], _b = _p[i + 1];
		draw_set_color(_cr);
		draw_line_width(_a[0], _a[1], _b[0], _b[1], _ancho);
		draw_set_color(_cl);   // espejo a la izquierda
		draw_line_width(2 * _mx - _a[0], _a[1], 2 * _mx - _b[0], _b[1], _ancho);
	}
}

// ------------------------------------------------------
// VOZ: micro de tocar (prender / apagar), bocina y 1 vs 1
// ------------------------------------------------------

/// ¿Hay alguien que me pueda oir? En la sala si; en la partida solo si tengo companeros humanos
function scr_voz_hay_quien() {
	if (room == rm_menu) return true;
	return array_length(scr_voz_destinos()) > 0;
}

/// ¿Estoy oyendo a los demas? (bocina)
function scr_voz_oir() {
	scr_voz_init();
	return !variable_struct_exists(global.voz, "oir") || global.voz.oir;
}

/// Prender / apagar la bocina (al apagarla se callan todos de una)
function scr_voz_oir_cambiar() {
	scr_voz_init();
	var _v = global.voz;
	_v.oir = !scr_voz_oir();
	if (!_v.oir) {
		var _k = variable_struct_get_names(_v.colas);
		for (var i = 0; i < array_length(_k); i++) {
			var _c = _v.colas[$ _k[i]];
			if (_c.snd >= 0) { audio_stop_sound(_c.snd); _c.snd = -1; _c.n = 0; }
		}
		_v.hablan = {};
	}
}

/// Donde van los 2 iconos redondos de la sala (en el lugar del boton HABLAR de antes)
function scr_voz_iconos_geo(_g) {
	var _u = _g.u;
	var _r = 20 * _u;
	var _cy = _g.hy + _r + 2 * _u;
	var _mcx = _g.hx + _r + 4 * _u;
	var _bcx = _mcx + _r * 2 + 40 * _u;
	return { r: _r, cy: _cy, mcx: _mcx, bcx: _bcx, y1: _cy - _r - 4 * _u, y2: _cy + _r + 16 * _u,
		mx1: _mcx - _r - 6 * _u, mx2: _mcx + _r + 6 * _u, bx1: _bcx - _r - 6 * _u, bx2: _bcx + _r + 6 * _u };
}

/// Bocina chiquita (con ondas si se oye, con X si no)
function __voz_bocina(_x, _y, _s, _col, _on) {
	draw_set_colour(_col);
	draw_rectangle(_x - 7 * _s, _y - 3 * _s, _x - 3 * _s, _y + 3 * _s, false);
	draw_triangle(_x - 3 * _s, _y - 3 * _s, _x + 3 * _s, _y - 8 * _s, _x - 3 * _s, _y + 3 * _s, false);
	draw_triangle(_x - 3 * _s, _y + 3 * _s, _x + 3 * _s, _y - 8 * _s, _x + 3 * _s, _y + 8 * _s, false);
	if (_on) {
		for (var a = -40; a < 40; a += 10) {
			draw_line_width(_x + 5 * _s + lengthdir_x(4 * _s, a), _y + lengthdir_y(4 * _s, a), _x + 5 * _s + lengthdir_x(4 * _s, a + 10), _y + lengthdir_y(4 * _s, a + 10), 1.5 * _s);
			draw_line_width(_x + 5 * _s + lengthdir_x(8 * _s, a), _y + lengthdir_y(8 * _s, a), _x + 5 * _s + lengthdir_x(8 * _s, a + 10), _y + lengthdir_y(8 * _s, a + 10), 1.5 * _s);
		}
	} else {
		draw_set_colour(make_color_rgb(255, 107, 122));
		draw_line_width(_x + 6 * _s, _y - 5 * _s, _x + 14 * _s, _y + 5 * _s, 2 * _s);
		draw_line_width(_x + 14 * _s, _y - 5 * _s, _x + 6 * _s, _y + 5 * _s, 2 * _s);
	}
}

/// Icono redondo de la sala: circulo oscuro con borde de color, y micro o bocina adentro
function __voz_icono(_x, _y, _r, _col, _on, _tipo, _u) {
	draw_set_alpha(0.9);
	draw_set_colour(make_color_rgb(11, 15, 26));
	draw_circle(_x, _y, _r, false);
	draw_set_alpha(1);
	draw_set_colour(_col);
	draw_circle(_x, _y, _r, true);
	draw_circle(_x, _y, _r - 1, true);
	if (_tipo == "mic") {
		__voz_mic(_x, _y, 1.3 * _u, _col, 1);
		if (!_on) {   // micro tachado
			draw_set_colour(make_color_rgb(255, 107, 122));
			draw_line_width(_x - 9 * _u, _y - 10 * _u, _x + 9 * _u, _y + 10 * _u, 2.5 * _u);
		}
	} else {
		__voz_bocina(_x - 3 * _u, _y, 1.2 * _u, _col, _on);
	}
	draw_set_colour(c_white);
}

/// Donde van el micro y la bocina chiquitos en la partida: debajo de tus barras, a la izquierda.
/// Si te sale otra barra (escudo, velocidad...) bajan solos (oPlayer Draw_64 guarda voz_hud_y).
function scr_voz_hud_pos() {
	var _r = 20;
	var _y = 104 + 8 + _r;   // debajo de la barra de vida
	if (instance_exists(oPlayer) && variable_instance_exists(oPlayer, "voz_hud_y")) _y = oPlayer.voz_hud_y - 8 + _r;
	return { r: _r, y: _y, mx: 40 + _r, bx: 40 + _r * 3 + 12 };
}

/// En la PC (sin botones de pantalla) se dibujan igual, con la tecla abajo (oPlayer Draw_64)
function scr_voz_hud() {
	if (touch_mode() || !scr_voz_activa()) return;
	scr_voz_init();
	var _p = scr_voz_hud_pos();
	var _verde = make_color_rgb(78, 200, 120), _gris = make_color_rgb(136, 135, 128);
	var _mok = global.voz.abierto_on && scr_voz_hay_quien() && scr_voz_motivo() == "";
	__voz_icono(_p.mx, _p.y, _p.r, _mok ? _verde : _gris, _mok, "mic", 0.8);
	__voz_icono(_p.bx, _p.y, _p.r, scr_voz_oir() ? _verde : _gris, scr_voz_oir(), "bocina", 0.8);
	draw_set_font(fnt_small);
	draw_set_halign(fa_center); draw_set_valign(fa_top);
	draw_set_colour(c_white);
	draw_text_transformed(_p.mx, _p.y + _p.r + 2, "V", 0.5, 0.5, 0);
	draw_text_transformed(_p.bx, _p.y + _p.r + 2, "B", 0.5, 0.5, 0);
	draw_set_halign(fa_left);
}

