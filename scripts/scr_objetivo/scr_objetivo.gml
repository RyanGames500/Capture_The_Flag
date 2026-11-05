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

	// --- Pastilla bajo el marcador ---
	draw_set_font(fnt_menu);
	draw_set_halign(fa_center);
	draw_set_valign(fa_middle);
	var _s  = 1;
	var _tw = string_width(_o.txt) * _s + 60;
	var _cx = _gw / 2;
	var _cy = scr_reloj_visible() ? 196 : 160;   // si hay reloj bajo el marcador, la pastilla baja un poco
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
