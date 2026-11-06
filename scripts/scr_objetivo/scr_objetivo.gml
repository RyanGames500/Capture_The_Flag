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
		with (_b) {
			scr_botnet_init(_d.t, "BOT " + _d.n, irandom(3));
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
		_HCO: (bot_cor_t > 0), _HDA: (bot_dash_vis > 0), _HGF: 0, _HGX: round(x), _HGY: round(y)
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

	// --- GOLPEADO: unos frames sin control ---
	var _aturdido = false;
	if (hit_bloqueo_timer > 0) {
		hit_bloqueo_timer--;
		hsp *= 0.9;
		state = PLAYERSTATE.HIT;
		_aturdido = true;
	}

	if (_activo && !_aturdido) scr_botnet_pensar();
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
	if (scr_arma_es_generica(_w)) return true;
	var _t = string(_w.type2);
	return (_t == "gun" || _t == "smg" || _t == "m4" || _t == "escop" || _t == "bazooka");
}

/// Los numeros de disparo de cualquier arma (las de antes no los traen, las nuevas si).
function scr_botnet_arma_datos(_w) {
	var _d = {
		tipo: string(_w.type2), spr: _w.sprite, dano: _w.damage, cada: max(3, _w.frequency), max: max(1, _w.maxAmmo),
		vel: 16, vida: 40, disp: 1.5, balas: 1, rafaga: 0, cohete: false, acel: false, atraviesa: 0,
		mz: "gun", bala: sprBullet_gun, snd: snd_gun, tono: 1, vol: 0.7
	};
	if (scr_arma_es_generica(_w)) {
		_d.vel = _w.vel; _d.vida = _w.vida; _d.disp = max(1, _w.disp); _d.balas = _w.balas; _d.rafaga = _w.rafaga;
		_d.atraviesa = _w.atraviesa; _d.mz = _w.mz; _d.snd = _w.snd; _d.tono = _w.tono; _d.vol = _w.vol * 0.7;
		_d.bala = _w.silenciada ? spr_bala_silenciada : ((_w.balas > 1) ? sprBullet_escop : sprBullet_smg);
		if (_w.cohete) { _d.cohete = true; _d.acel = true; _d.bala = sprBullet_bazooka; }
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
		_b.damage = _d.dano;
		_b.sprite_index = _d.bala;
		if (_d.atraviesa > 1) _b.atraviesa = _d.atraviesa;
		if (_d.cohete) {
			_b.is_rocket = true;
			if (_d.acel) { _b.acel = 1.06; _b.vel_max = 16; }
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
		case 3:
			if (hp < max_health * 0.5) {
				var _bq = instance_create_layer(x, bbox_bottom - 6, "Instances", oBotiquin);
				_bq.team = team;
				var _m = { x: _bq.x, y: _bq.y, team: team };
				with (oOtherPlayer) if (!es_bot) SendEventToClient(clientId, "hab_botiquin", _m);
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
	scr_botnet_pegar(_t, BOTNET_GOLPE, point_direction(x, y, _t.x, _t.y));
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
function scr_botnet_soltar(_vy, _alto) {
	has_flag = false;
	var _f = (team == "AZUL") ? oFlag : oFlag2;
	var _dx = x;
	var _dy = y - _alto;
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
	hp = max_health;
	state = PLAYERSTATE.IDLE;
	visible = true;
	image_speed = 1;
	sprite_index = bot_anim.idle;
	bot_invul = 120;
	scr_botnet_pistola();
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
	if (!global.ONLINE) return ["REINTENTAR", "SALIR"];
	if (scr_fin_es_privada()) return ["SALIR"];
	return ["ENVIAR SOLICITUD", "SALIR"];
}
