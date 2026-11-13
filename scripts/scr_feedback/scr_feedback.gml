
#macro FB_AZUL  make_color_rgb(31, 155, 255)
#macro FB_ROJO  make_color_rgb(255, 42, 58)
#macro FB_ORO   make_color_rgb(255, 212, 71)
#macro FB_TINTA make_color_rgb(11, 15, 26)
#macro FB_GRIS  make_color_rgb(169, 180, 208)

/// Limpia todo (al empezar cada mapa).
function fb_init() {
	global.fb_banner   = undefined;
	global.fb_score    = undefined;
	global.fb_toasts   = [];
	global.fb_toast_cola = [];   // los que esperan turno (se ven maximo 2)
	global.fb_edge     = 0;
	global.fb_edge_max = 1;
	global.fb_edge_col = FB_ROJO;
}

function fb_ok() {
	if (!variable_global_exists("fb_toasts")) fb_init();
	if (!variable_global_exists("fb_toast_cola")) global.fb_toast_cola = [];
	return true;
}

function fb_fps() { return game_get_speed(gamespeed_fps); }
function fb_team_col(_team) { return (_team == "AZUL") ? FB_AZUL : FB_ROJO; }
function fb_rival(_team) { return (_team == "AZUL") ? "ROJO" : "AZUL"; }
function fb_corto(_n) {
	_n = string(_n);
	if (string_length(_n) > 12) _n = string_copy(_n, 1, 11) + ".";
	return _n;
}

// ------------------------------------------------------
// B · BANNERS DE BANDERA
// ------------------------------------------------------
function fb_banner(_titulo, _sub, _col, _spr, _alarma) {
	fb_ok();
	global.fb_banner = { titulo: _titulo, sub: _sub, col: _col, spr: _spr, t: 0, dur: round(fb_fps() * 2.2), alarma: _alarma };
	if (_alarma) {
		global.fb_edge = round(fb_fps() * 1.4);
		global.fb_edge_max = global.fb_edge;
		global.fb_edge_col = _col;
		scrCamShake(6);
	}
}

/// Te robaron TU bandera (alarma: bordes que laten y un temblor corto).
function fb_banner_robada(_nombre) {
	var _mio = scr_my_team();
	var _spr = (_mio == "AZUL") ? spr_flag_blue : spr_flag_red;
	fb_banner("ROBARON TU BANDERA!", fb_corto(_nombre) + " la lleva - detenlo!", fb_team_col(fb_rival(_mio)), _spr, true);
}

/// Alguien de tu equipo tomó la bandera rival.
function fb_banner_aliado(_nombre) {
	var _mio = scr_my_team();
	var _spr = (_mio == "AZUL") ? spr_flag_red : spr_flag_blue;
	fb_banner("TU EQUIPO LA TIENE!", fb_corto(_nombre) + " lleva la bandera - escoltalo", fb_team_col(_mio), _spr, false);
}

/// La agarraste tú.
function fb_banner_tienes() {
	var _mio = scr_my_team();
	var _spr = (_mio == "AZUL") ? spr_flag_red : spr_flag_blue;
	fb_banner("LA TIENES!", "Llevala a tu base", FB_ORO, _spr, false);
}

// ------------------------------------------------------
// C2 · ANOTACIÓN
// ------------------------------------------------------
/// Llamar DESPUÉS de sumar el punto. Si con ese punto ganan no muestra nada (sale la pantalla de victoria).
function fb_anotacion(_team, _nombre) {
	fb_ok();
	var _pts = (_team == "AZUL") ? global.puntos_azul : global.puntos_rojo;
	var _lim = scr_banderas_para_ganar();
	if (_lim > 0 && _pts >= _lim) return;
	var _grande = (_lim > 1 && _pts == _lim - 1);
	var _nom = string(_nombre);
	if (_grande) {
		global.fb_score = { titulo: "PUNTO DE PARTIDO!", sub: _team + " esta a 1 bandera de ganar", col: fb_team_col(_team), t: 0, dur: round(fb_fps() * 1.7), grande: true };
	} else {
		global.fb_score = { titulo: _team + " ANOTA!", sub: (_nom == "") ? "" : fb_corto(_nom), col: fb_team_col(_team), t: 0, dur: round(fb_fps() * 1.4), grande: false };
	}
}

// ------------------------------------------------------
// D · AVISOS CHICOS: abajo al centro, suben desde abajo. Maximo 2 a la vez; los demas esperan en fila.
// ------------------------------------------------------
/// _icono: "flag", "kill", "trap", "arma", "star", "info"
function fb_toast(_titulo, _sub, _col, _icono = "flag") {
	fb_ok();
	array_push(global.fb_toast_cola, { titulo: string(_titulo), sub: string(_sub), col: _col, icono: _icono, t: 0, dur: round(fb_fps() * FB_AVISO_SEG) });
	// Si se juntan muchos, se tiran los mas viejos de la fila
	while (array_length(global.fb_toast_cola) > FB_AVISO_COLA) array_delete(global.fb_toast_cola, 0, 1);
}

/// Los textos del kill feed (bajas, trampas, abandonos) como tarjeta. Lo llama scrAddKillFeed en línea.
function fb_toast_muerte(_text) {
	var _t = string(_text);
	var _me = variable_global_exists("myName") ? string(global.myName) : "";
	var _trampa = (string_pos("aplastado", _t) > 0);
	if (string_pos("abandon", _t) > 0 || string_pos("Abandon", _t) > 0) {
		fb_toast(_t, "Salio de la partida", FB_GRIS, "info");
	} else if (string_pos("te elimino", _t) > 0 || string_pos("Moriste", _t) > 0) {
		fb_toast(_t, _trampa ? "Trampa" : "Te eliminaron", FB_ROJO, _trampa ? "trap" : "kill");
	} else if (_me != "" && string_pos(_me + " elimin", _t) == 1) {
		fb_toast(_t, "Eliminaste a un rival", FB_ORO, "kill");
	} else {
		fb_toast(_t, _trampa ? "Trampa" : "Eliminacion", FB_GRIS, _trampa ? "trap" : "kill");
	}
}

// ------------------------------------------------------
// STEP (oBrain)
// ------------------------------------------------------
function fb_step() {
	fb_ok();
	if (is_struct(global.fb_banner)) { global.fb_banner.t++; if (global.fb_banner.t >= global.fb_banner.dur) global.fb_banner = undefined; }
	if (is_struct(global.fb_score))  { global.fb_score.t++;  if (global.fb_score.t >= global.fb_score.dur) global.fb_score = undefined; }
	if (global.fb_edge > 0) global.fb_edge--;
	for (var i = array_length(global.fb_toasts) - 1; i >= 0; i--) {
		var _it = global.fb_toasts[i];
		_it.t++;
		if (_it.t >= _it.dur) array_delete(global.fb_toasts, i, 1);
	}
	// Entra el siguiente de la fila cuando hay lugar (maximo 2 a la vez)
	while (array_length(global.fb_toasts) < FB_AVISO_MAX && array_length(global.fb_toast_cola) > 0) {
		array_push(global.fb_toasts, global.fb_toast_cola[0]);
		array_delete(global.fb_toast_cola, 0, 1);
	}
}

// ------------------------------------------------------
// AYUDAS DE DIBUJO
// ------------------------------------------------------
function fb_ease_out(_p) { _p = clamp(_p, 0, 1); return 1 - (1 - _p) * (1 - _p) * (1 - _p); }
function fb_ease_in(_p)  { _p = clamp(_p, 0, 1); return _p * _p * _p; }

/// Paralelogramo (lados inclinados) relleno.
function fb_paralelo(_x1, _y1, _x2, _y2, _skew, _col, _a) {
	draw_set_alpha(_a);
	draw_set_color(_col);
	draw_triangle(_x1 + _skew, _y1, _x2 + _skew, _y1, _x1, _y2, false);
	draw_triangle(_x2 + _skew, _y1, _x2, _y2, _x1, _y2, false);
	draw_set_alpha(1);
}

/// Texto con contorno oscuro grueso (como las letras de Brawl).
function fb_texto(_x, _y, _s, _sc, _col, _a, _grosor = 3) {
	draw_set_alpha(_a);
	draw_set_color(FB_TINTA);
	for (var _i = 0; _i < 8; _i++) {
		var _ang = _i * 45;
		draw_text_transformed(_x + lengthdir_x(_grosor, _ang), _y + lengthdir_y(_grosor, _ang), _s, _sc, _sc, 0);
	}
	draw_text_transformed(_x, _y + _grosor + 2, _s, _sc, _sc, 0);
	draw_set_color(_col);
	draw_text_transformed(_x, _y, _s, _sc, _sc, 0);
	draw_set_alpha(1);
}

/// Dibuja un sprite centrado en (x, y) con el alto que le pidas.
function fb_sprite_centro(_spr, _x, _y, _alto, _a) {
	if (!sprite_exists(_spr)) return;
	var _sc = _alto / max(1, sprite_get_height(_spr));
	var _dx = (sprite_get_xoffset(_spr) - sprite_get_width(_spr) * 0.5) * _sc;
	var _dy = (sprite_get_yoffset(_spr) - sprite_get_height(_spr) * 0.5) * _sc;
	draw_sprite_ext(_spr, 0, _x + _dx, _y + _dy, _sc, _sc, 0, c_white, _a);
}

/// Flecha en el borde de la pantalla hacia un punto del mapa (solo si está fuera de la vista).
/// Se queda entre el marcador de arriba y lo de abajo (ping; en el celular, los joysticks).
function fb_flecha_borde(_wx, _wy, _col, _label) {
	var _cam = view_camera[0];
	var _vx = camera_get_view_x(_cam), _vy = camera_get_view_y(_cam);
	var _vw = camera_get_view_width(_cam), _vh = camera_get_view_height(_cam);
	if (_wx >= _vx && _wx <= _vx + _vw && _wy >= _vy && _wy <= _vy + _vh) return;
	var _gw = display_get_gui_width(), _gh = display_get_gui_height();
	var _tx = (_wx - _vx) * (_gw / _vw);
	var _ty = (_wy - _vy) * (_gh / _vh);
	var _cx = _gw * 0.5, _cy = _gh * 0.5;
	var _dx = _tx - _cx, _dy = _ty - _cy;
	if (_dx == 0 && _dy == 0) return;
	var _pad = 40;
	var _k = 1000000000;
	if (_dx != 0) _k = min(_k, ((_dx > 0 ? _gw - _pad : _pad) - _cx) / _dx);
	if (_dy != 0) _k = min(_k, ((_dy > 0 ? _gh - _pad : _pad) - _cy) / _dy);
	var _ymin = 150;
	var _ymax = touch_mode() ? _gh - 320 : _gh - 80;
	if (_ymax < _ymin) _ymax = _ymin;
	var _ax = clamp(_cx + _dx * _k, _pad, _gw - _pad);
	var _ay = clamp(_cy + _dy * _k, _ymin, _ymax);
	var _ang = point_direction(_cx, _cy, _tx, _ty);
	var _r = 16 + 2 * sin(current_time * 0.012);
	draw_set_color(FB_TINTA);
	draw_triangle(_ax + lengthdir_x(_r * 1.6, _ang), _ay + lengthdir_y(_r * 1.6, _ang),
	              _ax + lengthdir_x(_r * 1.2, _ang + 140), _ay + lengthdir_y(_r * 1.2, _ang + 140),
	              _ax + lengthdir_x(_r * 1.2, _ang - 140), _ay + lengthdir_y(_r * 1.2, _ang - 140), false);
	draw_set_color(_col);
	draw_triangle(_ax + lengthdir_x(_r * 1.3, _ang), _ay + lengthdir_y(_r * 1.3, _ang),
	              _ax + lengthdir_x(_r, _ang + 140), _ay + lengthdir_y(_r, _ang + 140),
	              _ax + lengthdir_x(_r, _ang - 140), _ay + lengthdir_y(_r, _ang - 140), false);
	// Etiqueta del lado de adentro de la pantalla
	draw_set_font(fnt_small);
	draw_set_halign(fa_center);
	draw_set_valign(fa_middle);
	var _lx = _ax - lengthdir_x(50, _ang), _ly = _ay - lengthdir_y(32, _ang);
	var _w = string_width(_label) + 16;
	draw_set_alpha(0.9);
	draw_set_color(FB_TINTA);
	draw_roundrect_ext(_lx - _w / 2, _ly - 12, _lx + _w / 2, _ly + 12, 8, 8, false);
	draw_set_alpha(1);
	draw_set_color(_col);
	draw_roundrect_ext(_lx - _w / 2, _ly - 12, _lx + _w / 2, _ly + 12, 8, 8, true);
	draw_text(_lx, _ly, _label);
}

/// Burbuja de bandera en el borde (mismo estilo que la burbuja con cara de los jugadores).
/// Solo sale si el punto no se ve en pantalla. _late = el anillo late (tu bandera en el suelo).
function fb_burbuja_bandera(_wx, _wy, _spr, _col, _label, _late) {
	var _cam = view_camera[0];
	var _vx = camera_get_view_x(_cam), _vy = camera_get_view_y(_cam);
	var _vw = camera_get_view_width(_cam), _vh = camera_get_view_height(_cam);
	if (_wx >= _vx && _wx <= _vx + _vw && _wy >= _vy && _wy <= _vy + _vh) return;
	var _gw = display_get_gui_width(), _gh = display_get_gui_height();
	var _cx = _gw * 0.5, _cy = _gh * 0.5;
	var _tx = (_wx - _vx) * (_gw / _vw);
	var _ty = (_wy - _vy) * (_gh / _vh);
	var _dx = _tx - _cx, _dy = _ty - _cy;
	if (_dx == 0 && _dy == 0) return;
	var _pad = 56;
	var _k = 1000000000;
	if (_dx != 0) _k = min(_k, ((_dx > 0 ? _gw - _pad : _pad) - _cx) / _dx);
	if (_dy != 0) _k = min(_k, ((_dy > 0 ? _gh - _pad : _pad) - _cy) / _dy);
	var _ymin = 160;
	var _ymax = touch_mode() ? _gh - 330 : _gh - 90;
	if (_ymax < _ymin) _ymax = _ymin;
	var _bx = clamp(_cx + _dx * _k, _pad, _gw - _pad);
	var _by = clamp(_cy + _dy * _k, _ymin, _ymax);
	var _ang = point_direction(_cx, _cy, _tx, _ty);

	// Anillo que late (urgente) o que gira suave
	var _pp = (current_time mod (_late ? 700 : 1400)) / (_late ? 700 : 1400);
	draw_set_alpha((_late ? 0.95 : 0.5) * (1 - _pp));
	draw_set_color(_col);
	draw_circle(_bx, _by, 30 + 16 * _pp, true);
	draw_circle(_bx, _by, 31 + 16 * _pp, true);
	if (_late) draw_circle(_bx, _by, 32 + 16 * _pp, true);
	draw_set_alpha(1);

	// Puntita
	draw_set_color(FB_TINTA);
	draw_triangle(_bx + lengthdir_x(44, _ang), _by + lengthdir_y(44, _ang),
	              _bx + lengthdir_x(26, _ang + 32), _by + lengthdir_y(26, _ang + 32),
	              _bx + lengthdir_x(26, _ang - 32), _by + lengthdir_y(26, _ang - 32), false);
	draw_set_color(_col);
	draw_triangle(_bx + lengthdir_x(40, _ang), _by + lengthdir_y(40, _ang),
	              _bx + lengthdir_x(27, _ang + 24), _by + lengthdir_y(27, _ang + 24),
	              _bx + lengthdir_x(27, _ang - 24), _by + lengthdir_y(27, _ang - 24), false);

	// Círculo con la bandera (aro punteado alrededor, como de "objetivo")
	draw_set_color(FB_TINTA);
	draw_circle(_bx, _by, 31, false);
	var _giro = (current_time * 0.06) mod 360;
	for (var s = 0; s < 8; s++) fb_aro_parte(_bx, _by, 26, 30, _giro + s * 45, 28, _col);
	draw_set_color(_col);
	draw_circle(_bx, _by, 25, false);
	draw_set_color(FB_TINTA);
	draw_circle(_bx, _by, 22, false);
	var _s = _late ? 1 + 0.1 * abs(sin(current_time * 0.01)) : 1;
	fb_sprite_centro(_spr, _bx, _by, 28 * _s, 1);

	// Etiqueta + metros
	var _m = _label;
	var _yo = noone;
	if (instance_exists(oPlayer))              _yo = instance_find(oPlayer, 0);
	else if (instance_exists(oPlayer_offline)) _yo = instance_find(oPlayer_offline, 0);
	if (_yo != noone) {
		_m += "  " + string(max(1, round(point_distance(_yo.x, _yo.y, _wx, _wy) / FB_METRO))) + " m";
	}
	draw_set_font(fnt_small);
	draw_set_halign(fa_center);
	draw_set_valign(fa_middle);
	var _mw = string_width(_m) + 14;
	draw_set_color(FB_TINTA);
	draw_roundrect_ext(_bx - _mw / 2, _by + 31, _bx + _mw / 2, _by + 49, 7, 7, false);
	draw_set_color(_col);
	draw_roundrect_ext(_bx - _mw / 2, _by + 31, _bx + _mw / 2, _by + 49, 7, 7, true);
	draw_set_color(c_white);
	draw_text(_bx, _by + 40, _m);
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
}

/// Un pedacito de anillo (para el aro punteado). _desde y _largo en grados.
function fb_aro_parte(_x, _y, _r1, _r2, _desde, _largo, _col) {
	draw_set_color(_col);
	draw_primitive_begin(pr_trianglestrip);
	for (var i = 0; i <= 6; i++) {
		var _a = _desde + _largo * (i / 6);
		draw_vertex(_x + lengthdir_x(_r1, _a), _y + lengthdir_y(_r1, _a));
		draw_vertex(_x + lengthdir_x(_r2, _a), _y + lengthdir_y(_r2, _a));
	}
	draw_primitive_end();
}

/// Objetivos de bandera fuera de pantalla. A quien LLEVA una bandera no se le pone otra:
/// su burbuja con cara (fb_indicadores) ya sale dorada y dice ATRAPALO / ESCOLTALO.
function fb_flechas() {
	// Soporte online (oPlayer) y offline (oPlayer_offline)
	var _me = noone;
	if (instance_exists(oPlayer))              _me = instance_find(oPlayer, 0);
	else if (instance_exists(oPlayer_offline)) _me = instance_find(oPlayer_offline, 0);
	if (_me == noone) return;
	var _online = variable_global_exists("ONLINE") && global.ONLINE;
	if (_online  && _me.state == PLAYERSTATE.DEAD)  return;
	if (!_online && _me.state == PLAYERSTATE2.DEAD) return;
	var _mio = scr_my_team();
	// REY DE LA BANDERA: solo la flechita hacia la zona (scr_reloj)
	if (scr_modo_rey()) {
		if (variable_global_exists("rey_x")) fb_burbuja_bandera(global.rey_x, global.rey_y - 40, (global.rey_c == 2) ? spr_flag_red : spr_flag_blue, FB_ORO, "ZONA", false);
		return;
	}
	if (scr_modo_sin_banderas()) return;   // DUELO POR PUNTOS: sin flechitas de banderas
	var _rival = fb_rival(_mio);
	var _fEnemy = (_mio == "AZUL") ? oFlag : oFlag2;   // la que tengo que robar
	var _fMine  = (_mio == "AZUL") ? oFlag2 : oFlag;   // la mía
	var _sprEnemy = (_rival == "AZUL") ? spr_flag_blue : spr_flag_red;
	var _sprMine  = (_mio == "AZUL") ? spr_flag_blue : spr_flag_red;

	// 1) La llevo yo: a mi base
	if (_me.has_flag) {
		var _base = (_mio == "AZUL") ? obj_base_blue : obj_base_red;
		if (instance_exists(_base)) { var _b = instance_find(_base, 0); fb_burbuja_bandera(_b.x, _b.y, _sprEnemy, FB_ORO, "TU BASE", false); }
	}
	// 2) La bandera rival, si nadie la lleva
	else if (instance_exists(_fEnemy)) {
		var _fe = instance_find(_fEnemy, 0);
		if (!_fe.has_flag) fb_burbuja_bandera(_fe.x, _fe.y - 10, _sprEnemy, FB_ROJO, "BANDERA", false);
	}

	// 3) Mi bandera en el suelo: hay que ir a tocarla
	if (instance_exists(_fMine)) {
		var _fm = instance_find(_fMine, 0);
		if (!_fm.has_flag && abs(_fm.x - _fm.spawnX) > 4) fb_burbuja_bandera(_fm.x, _fm.y - 10, _sprMine, FB_AZUL, "TU BANDERA", true);
	}
}

/// ¿Dónde está la bandera? { e: 0 en base / 1 la llevan / 2 en el suelo, n: nombre de quien la lleva }
function fb_estado_bandera(_obj) {
	if (!instance_exists(_obj)) return { e: 0, n: "" };
	var _f = instance_find(_obj, 0);
	if (_f.has_flag) {
		var _p = _f.portador_instancia;
		var _n = "ALGUIEN";
		if (_p != noone && instance_exists(_p)) {
			if (_p.object_index == oPlayer || _p.object_index == oPlayer_offline) _n = global.myName;
			else if (variable_instance_exists(_p, "Name")) _n = _p.Name;
		}
		return { e: 1, n: fb_corto(_n) };
	}
	if (abs(_f.x - _f.spawnX) > 4) return { e: 2, n: "" };
	return { e: 0, n: "" };
}

// ------------------------------------------------------
// A · MARCADOR VIVO (reemplaza al marcador viejo en línea)
// ------------------------------------------------------
/// Texto del chip de estado de una bandera: { txt, bg, fg, a, sc }
function fb_chip_datos(_obj) {
	var _st = fb_estado_bandera(_obj);
	var _c = { txt: "EN BASE", bg: FB_TINTA, fg: c_white, a: 0.4, sc: 1, blink: 1 };
	if (_st.e == 1) { _c.txt = "LA LLEVA " + _st.n; _c.bg = FB_ORO; _c.fg = FB_TINTA; _c.a = 1; _c.sc = 1 + 0.1 * abs(sin(current_time * 0.008)); }
	if (_st.e == 2) { _c.txt = "EN EL SUELO"; _c.a = 1; _c.blink = (sin(current_time * 0.012) > 0) ? 1 : 0.35; }
	_c.e = _st.e;
	return _c;
}

/// _mx = centro de la pantalla, _y = arriba del marcador.
function fb_draw_marcador(_mx, _y) {
	var _h = 64;
	var _cy = _y + _h / 2;
	var _cA = fb_chip_datos(oFlag2);   // bandera azul
	var _cR = fb_chip_datos(oFlag);    // bandera roja

	// Anchos: lo que diga el chip más largo manda, así queda centrado
	draw_set_font(fnt_small);
	var _chipW = max(string_width(_cA.txt), string_width(_cR.txt), string_width("BANDERA AZUL")) + 18;
	var _panelW = 14 + _chipW + 10 + 44 + 10 + 54 + 12;
	var _centroW = 118;
	var _total = 6 + _panelW + _centroW + _panelW + 6;
	var _x0 = _mx - _total / 2;

	// Fondo
	draw_set_alpha(0.35);
	draw_set_color(c_black);
	draw_roundrect_ext(_x0, _y + 6, _x0 + _total, _y + _h + 6, 20, 20, false);
	draw_set_alpha(1);
	draw_set_color(FB_TINTA);
	draw_roundrect_ext(_x0, _y, _x0 + _total, _y + _h, 20, 20, false);

	var _bx1 = _x0 + 6, _bx2 = _bx1 + _panelW;
	var _rx1 = _bx2 + _centroW, _rx2 = _rx1 + _panelW;
	draw_set_color(FB_AZUL);
	draw_roundrect_ext(_bx1, _y + 6, _bx2, _y + _h - 6, 14, 14, false);
	draw_set_color(FB_ROJO);
	draw_roundrect_ext(_rx1, _y + 6, _rx2, _y + _h - 6, 14, 14, false);
	if (MN_NUEVO) {
		// Bordes oscuros y brillo arriba (estetica nueva)
		draw_set_color(merge_colour(FB_AZUL, c_white, 0.25));
		draw_roundrect_ext(_bx1 + 5, _y + 9, _bx2 - 5, _y + _h * 0.42, 10, 10, false);
		draw_set_color(merge_colour(FB_ROJO, c_white, 0.25));
		draw_roundrect_ext(_rx1 + 5, _y + 9, _rx2 - 5, _y + _h * 0.42, 10, 10, false);
		draw_set_color(c_black);
		draw_roundrect_ext(_bx1, _y + 6, _bx2, _y + _h - 6, 14, 14, true);
		draw_roundrect_ext(_rx1, _y + 6, _rx2, _y + _h - 6, 14, 14, true);
		draw_roundrect_ext(_x0, _y, _x0 + _total, _y + _h, 20, 20, true);
		draw_roundrect_ext(_x0 + 1, _y + 1, _x0 + _total - 1, _y + _h - 1, 19, 19, true);
	}

	// Pop del número al anotar (usa el rebote que ya tenía oBrain)
	var _popA = 1, _popR = 1;
	if (instance_exists(oBrain)) {
		_popA = 1 + max(0, oBrain.marcador_escala_azul - 1.6) * 0.6;
		_popR = 1 + max(0, oBrain.marcador_escala_rojo - 1.6) * 0.6;
	}

	// --- Lado azul: [estado] [bandera] [puntos] ---
	var _numXA = _bx2 - 12 - 27;
	var _icXA = _numXA - 27 - 10 - 22;
	fb_bandera_circulo(_icXA, _cy, spr_flag_blue, _cA.e == 1);
	draw_set_font(fnt_large);
	draw_set_halign(fa_center);
	draw_set_valign(fa_middle);
	fb_texto(_numXA, _cy, string(global.puntos_azul), 2.2 * _popA, c_white, 1, 3);
	fb_chip_estado(_icXA - 22 - 10, _cy, _cA, "BANDERA AZUL", -1);

	// --- Lado rojo (espejo) ---
	var _numXR = _rx1 + 12 + 27;
	var _icXR = _numXR + 27 + 10 + 22;
	fb_bandera_circulo(_icXR, _cy, spr_flag_red, _cR.e == 1);
	draw_set_font(fnt_large);
	draw_set_halign(fa_center);
	draw_set_valign(fa_middle);
	fb_texto(_numXR, _cy, string(global.puntos_rojo), 2.2 * _popR, c_white, 1, 3);
	fb_chip_estado(_icXR + 22 + 10, _cy, _cR, "BANDERA ROJA", 1);

	// --- Centro: reloj (o VS) y a cuántas banderas ---
	var _ccx = _bx2 + _centroW / 2;
	var _txt = "VS", _col = FB_ORO, _sc = 1.4;
	if (scr_reloj_visible()) {
		if (oBrain.reloj_fin && global.puntos_azul == global.puntos_rojo) {
			_txt = "MUERTE SUBITA " + scr_muerte_subita_txt(); _sc = 0.6;
			_col = ((current_time div 300) mod 2 == 0) ? FB_ROJO : FB_ORO;
		} else {
			var _m = oBrain.reloj_seg div 60, _s = oBrain.reloj_seg mod 60;
			_txt = string(_m) + ":" + ((_s < 10) ? "0" : "") + string(_s);
			if (oBrain.reloj_seg <= RELOJ_ROJO) { _col = FB_ROJO; _sc = 1.4 + 0.12 * max(0, 1 - (current_time mod 1000) / 200); }
		}
	}
	draw_set_font(fnt_large);
	draw_set_halign(fa_center);
	draw_set_valign(fa_middle);
	draw_set_color(_col);
	draw_text_transformed(_ccx, _cy - 8, _txt, _sc, _sc, 0);
	draw_set_font(fnt_small);
	draw_set_color(FB_GRIS);
	draw_text(_ccx, _cy + 16, "A " + string(scr_banderas_para_ganar()) + " BANDERAS");

	// --- Tu equipo: una flechita dorada encima de tu lado ---
	var _miX = (scr_my_team() == "AZUL") ? (_bx1 + _bx2) / 2 : (_rx1 + _rx2) / 2;
	var _bo = abs(sin(current_time * 0.008)) * 4;
	draw_set_color(FB_TINTA);
	draw_triangle(_miX - 10, _y + _h + 4 + _bo + 12, _miX + 10, _y + _h + 4 + _bo + 12, _miX, _y + _h + 4 + _bo, false);
	draw_set_color(FB_ORO);
	draw_triangle(_miX - 7, _y + _h + 6 + _bo + 9, _miX + 7, _y + _h + 6 + _bo + 9, _miX, _y + _h + 6 + _bo, false);

	draw_set_alpha(1);
	draw_set_color(c_white);
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
}

/// Círculo oscuro con la bandera; si la robaron, late y sale un anillo dorado.
function fb_bandera_circulo(_x, _y, _spr, _robada) {
	var _s = _robada ? 1 + 0.12 * abs(sin(current_time * 0.01)) : 1;
	if (_robada) {
		var _p = (current_time mod 700) / 700;
		draw_set_alpha(0.9 * (1 - _p));
		draw_set_color(FB_ORO);
		draw_circle(_x, _y, 20 + 18 * _p, true);
		draw_circle(_x, _y, 21 + 18 * _p, true);
		draw_set_alpha(1);
	}
	draw_set_color(FB_TINTA);
	draw_circle(_x, _y, 20, false);
	fb_sprite_centro(_spr, _x, _y, 24 * _s, 1);
}

/// Etiqueta "BANDERA AZUL" y debajo el chip de estado. _lado -1 = alineado a la derecha (azul), 1 = a la izquierda (roja).
function fb_chip_estado(_x, _cy, _c, _label, _lado) {
	draw_set_font(fnt_small);
	draw_set_valign(fa_middle);
	draw_set_halign((_lado < 0) ? fa_right : fa_left);
	draw_set_color(FB_TINTA);
	draw_text(_x, _cy - 10, _label);
	var _tw = string_width(_c.txt) * _c.sc;
	var _w = _tw + 14;
	var _x1 = (_lado < 0) ? _x - _w : _x;
	draw_set_alpha(_c.a * _c.blink);
	draw_set_color(_c.bg);
	draw_roundrect_ext(_x1, _cy + 2, _x1 + _w, _cy + 20, 8, 8, false);
	draw_set_alpha(_c.blink);
	draw_set_color(_c.fg);
	draw_set_halign(fa_center);
	draw_text_transformed(_x1 + _w / 2, _cy + 11, _c.txt, _c.sc, _c.sc, 0);
	draw_set_alpha(1);
}

/// Ícono simple dentro del cuadrito de color de cada aviso.
function fb_icono(_tipo, _x, _y) {
	draw_set_color(FB_TINTA);
	switch (_tipo) {
		case "kill":
			draw_line_width(_x - 6, _y - 6, _x + 6, _y + 6, 3);
			draw_line_width(_x + 6, _y - 6, _x - 6, _y + 6, 3);
		break;
		case "trap":
			draw_rectangle(_x - 7, _y - 7, _x + 7, _y - 4, false);
			draw_triangle(_x - 6, _y - 1, _x + 6, _y - 1, _x, _y + 7, false);
		break;
		case "arma":
			draw_line_width(_x - 7, _y, _x + 7, _y, 3);
			draw_line_width(_x, _y - 7, _x, _y + 7, 3);
		break;
		case "star":
			draw_triangle(_x, _y - 8, _x + 7, _y, _x - 7, _y, false);
			draw_triangle(_x, _y + 8, _x + 7, _y, _x - 7, _y, false);
		break;
		case "info":
			draw_rectangle(_x - 1, _y - 2, _x + 2, _y + 7, false);
			draw_rectangle(_x - 1, _y - 7, _x + 2, _y - 4, false);
		break;
		default: // bandera
			draw_line_width(_x - 5, _y - 7, _x - 5, _y + 8, 2);
			draw_triangle(_x - 4, _y - 7, _x + 7, _y - 3, _x - 4, _y + 1, false);
		break;
	}
}

// ------------------------------------------------------
// DIBUJO GENERAL (oBrain Draw GUI, después del marcador)
// ------------------------------------------------------
function fb_draw_gui() {
	fb_ok();
	var _gw = display_get_gui_width(), _gh = display_get_gui_height();

	// --- Flechas de objetivo ---
	fb_flechas();

	// --- Bordes que laten (te robaron la bandera) ---
	if (global.fb_edge > 0) {
		var _pe = 1 - global.fb_edge / global.fb_edge_max;
		var _ae = 0.55 * abs(sin(_pe * pi * 2.5)) * (1 - _pe * 0.5);
		draw_set_alpha(_ae);
		draw_set_color(global.fb_edge_col);
		var _t = 14;
		draw_rectangle(0, 0, _gw, _t, false);
		draw_rectangle(0, _gh - _t, _gw, _gh, false);
		draw_rectangle(0, 0, _t, _gh, false);
		draw_rectangle(_gw - _t, 0, _gw, _gh, false);
		draw_set_alpha(_ae * 0.4);
		_t = 40;
		draw_rectangle(0, 0, _gw, _t, false);
		draw_rectangle(0, _gh - _t, _gw, _gh, false);
		draw_rectangle(0, 0, _t, _gh, false);
		draw_rectangle(_gw - _t, 0, _gw, _gh, false);
		draw_set_alpha(1);
	}

	// --- D · Avisos chicos: abajo al centro, una linea, suben desde abajo. El mas nuevo va abajo. ---
	fb_avisos_draw(_gw, _gh);
	for (var j = 0; j < 0; j++) {   // (el diseno viejo de tarjetas a la derecha ya no se usa)
		var _ty = 200;
		var _xr = _gw - 16;
		var _it = global.fb_toasts[j];
		var _p2 = _it.t / _it.dur;
		draw_set_font(fnt_menu);
		var _w1 = string_width(_it.titulo);
		draw_set_font(fnt_small);
		var _w2 = (_it.sub == "") ? 0 : string_width(_it.sub);
		var _w = max(_w1, _w2) + 74;
		var _h = (_it.sub == "") ? 40 : 52;
		var _xo = 0, _a2 = 1;
		if (_p2 < 0.08) _xo = lerp(_w + 40, 0, fb_ease_out(_p2 / 0.08));
		else if (_p2 < 0.12) _xo = -8 * sin((_p2 - 0.08) / 0.04 * pi);
		else if (_p2 > 0.86) { _a2 = (1 - _p2) / 0.14; _xo = lerp(0, 30, 1 - _a2); }
		var _x1 = _xr - _w + _xo, _y1 = _ty;
		draw_set_alpha(0.3 * _a2);
		draw_set_color(c_black);
		draw_roundrect_ext(_x1, _y1 + 4, _x1 + _w, _y1 + _h + 4, 12, 12, false);
		draw_set_alpha(0.92 * _a2);
		draw_set_color(FB_TINTA);
		draw_roundrect_ext(_x1, _y1, _x1 + _w, _y1 + _h, 12, 12, false);
		draw_set_alpha(_a2);
		draw_set_color(_it.col);
		draw_rectangle(_x1, _y1 + 6, _x1 + 6, _y1 + _h - 6, false);
		draw_roundrect_ext(_x1 + 16, _y1 + _h / 2 - 14, _x1 + 44, _y1 + _h / 2 + 14, 7, 7, false);
		fb_icono(_it.icono, _x1 + 30, _y1 + _h / 2);
		// barrita de tiempo
		draw_set_color(_it.col);
		draw_rectangle(_x1 + 12, _y1 + _h - 4, _x1 + 12 + (_w - 24) * (1 - _p2), _y1 + _h - 2, false);
		draw_set_halign(fa_left);
		draw_set_valign(fa_middle);
		draw_set_font(fnt_menu);
		draw_set_color(c_white);
		draw_text(_x1 + 54, (_it.sub == "") ? _y1 + _h / 2 : _y1 + 18, _it.titulo);
		if (_it.sub != "") {
			draw_set_font(fnt_small);
			draw_set_color(FB_GRIS);
			draw_text(_x1 + 54, _y1 + 37, _it.sub);
		}
		draw_set_alpha(1);
		_ty += _h + 8;
	}

	// --- C2 · Anotación ---
	if (is_struct(global.fb_score)) {
		var _s = global.fb_score;
		var _p3 = _s.t / _s.dur;
		var _a3 = (_p3 > 0.82) ? (1 - _p3) / 0.18 : 1;
		if (!_s.grande) {
			// Franja chica justo debajo del marcador
			var _cy = 128;
			var _sx = (_p3 < 0.12) ? lerp(0, 1.08, fb_ease_out(_p3 / 0.12)) : ((_p3 < 0.18) ? lerp(1.08, 1, (_p3 - 0.12) / 0.06) : 1);
			draw_set_font(fnt_large);
			var _tw = string_width(_s.titulo) * 1.6;
			draw_set_font(fnt_menu);
			var _sw = (_s.sub == "") ? 0 : string_width(_s.sub) + 16;
			var _w3 = (_tw + _sw + 50) * _sx;
			fb_paralelo(_gw / 2 - _w3 / 2 - 5, _cy - 25, _gw / 2 + _w3 / 2 + 5, _cy + 25, 10, FB_TINTA, _a3);
			fb_paralelo(_gw / 2 - _w3 / 2, _cy - 20, _gw / 2 + _w3 / 2, _cy + 20, 10, _s.col, _a3);
			if (_p3 > 0.1) {
				var _ta = _a3 * clamp((_p3 - 0.1) / 0.1, 0, 1);
				var _x0 = _gw / 2 - (_tw + _sw) / 2;
				draw_set_valign(fa_middle);
				draw_set_halign(fa_left);
				draw_set_font(fnt_large);
				fb_texto(_x0, _cy, _s.titulo, 1.6, c_white, _ta, 2);
				if (_s.sub != "") {
					draw_set_font(fnt_menu);
					draw_set_alpha(_ta);
					draw_set_color(FB_TINTA);
					draw_text(_x0 + _tw + 16, _cy + 2, _s.sub);
					draw_set_alpha(1);
				}
			}
		} else {
			// Punto de partido: más grande y dorado, arriba, sin oscurecer la pantalla
			var _cy2 = _gh * 0.3;
			var _ra = _a3 * 0.55 * clamp(_p3 / 0.15, 0, 1);
			var _rr = 220 * fb_ease_out(_p3 / 0.15);
			var _rot = _p3 * 40;
			draw_set_alpha(_ra);
			draw_set_color(FB_ORO);
			for (var r = 0; r < 14; r++) {
				var _ang1 = _rot + r * (360 / 14);
				draw_triangle(_gw / 2, _cy2, _gw / 2 + lengthdir_x(_rr, _ang1), _cy2 + lengthdir_y(_rr, _ang1),
				              _gw / 2 + lengthdir_x(_rr, _ang1 + 9), _cy2 + lengthdir_y(_rr, _ang1 + 9), false);
			}
			draw_set_alpha(1);
			var _bsc = (_p3 < 0.14) ? lerp(4.2, 2.6, fb_ease_out(_p3 / 0.14)) : ((_p3 < 0.22) ? lerp(2.6, 3.1, (_p3 - 0.14) / 0.08) : ((_p3 < 0.3) ? lerp(3.1, 2.9, (_p3 - 0.22) / 0.08) : 2.9));
			draw_set_font(fnt_large);
			draw_set_halign(fa_center);
			draw_set_valign(fa_middle);
			fb_texto(_gw / 2, _cy2, _s.titulo, _bsc, FB_ORO, _a3 * clamp(_p3 / 0.08, 0, 1), 4);
			if (_p3 > 0.2) {
				draw_set_font(fnt_menu);
				var _sw2 = string_width(_s.sub) + 30;
				var _ca = _a3 * clamp((_p3 - 0.2) / 0.1, 0, 1);
				draw_set_alpha(_ca);
				draw_set_color(FB_TINTA);
				draw_roundrect_ext(_gw / 2 - _sw2 / 2 - 3, _cy2 + 44, _gw / 2 + _sw2 / 2 + 3, _cy2 + 80, 18, 18, false);
				draw_set_color(_s.col);
				draw_roundrect_ext(_gw / 2 - _sw2 / 2, _cy2 + 47, _gw / 2 + _sw2 / 2, _cy2 + 77, 15, 15, false);
				draw_set_color(c_white);
				draw_text(_gw / 2, _cy2 + 62, _s.sub);
				draw_set_alpha(1);
			}
		}
	}

	// --- B · Banner de bandera ---
	if (is_struct(global.fb_banner)) {
		var _b = global.fb_banner;
		var _pb = _b.t / _b.dur;
		var _off = 0;
		if (_pb < 0.14) _off = lerp(-_gw * 1.1, 0, fb_ease_out(_pb / 0.14));
		else if (_pb < 0.2) _off = -12 * sin((_pb - 0.14) / 0.06 * pi);
		else if (_pb > 0.82) _off = lerp(0, _gw * 1.15, fb_ease_in((_pb - 0.82) / 0.18));
		var _by = _gh * 0.36, _bh = 92;
		fb_paralelo(-60 + _off, _by - _bh / 2 - 6, _gw + 60 + _off, _by + _bh / 2 + 6, 24, FB_TINTA, 1);
		fb_paralelo(-60 + _off, _by - _bh / 2, _gw + 60 + _off, _by + _bh / 2, 24, _b.col, 1);

		draw_set_font(fnt_large);
		var _tw2 = string_width(_b.titulo) * 2;
		draw_set_font(fnt_menu);
		var _sw3 = string_width(_b.sub);
		var _gw2 = 84 + 20 + max(_tw2, _sw3);
		var _gx = _gw / 2 - _gw2 / 2 + _off;

		// Ícono que golpea
		var _isc = (_pb < 0.2) ? 0 : ((_pb < 0.32) ? lerp(0, 1.3, (_pb - 0.2) / 0.12) : ((_pb < 0.4) ? lerp(1.3, 1, (_pb - 0.32) / 0.08) : 1));
		if (_isc > 0) {
			var _icx = _gx + 42, _icy = _by;
			draw_set_color(FB_ORO);
			draw_circle(_icx, _icy, 40 * _isc, false);
			draw_set_color(FB_TINTA);
			draw_circle(_icx, _icy, 34 * _isc, false);
			fb_sprite_centro(_b.spr, _icx, _icy, 40 * _isc, 1);
		}
		draw_set_halign(fa_left);
		draw_set_valign(fa_middle);
		draw_set_font(fnt_large);
		fb_texto(_gx + 104, _by - 14, _b.titulo, 2, c_white, 1, 3);
		draw_set_font(fnt_menu);
		draw_set_color(FB_TINTA);
		draw_text(_gx + 106, _by + 26, _b.sub);
	}

	draw_set_alpha(1);
	draw_set_color(c_white);
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
}

// ------------------------------------------------------
// E · JUGADORES FUERA DE PANTALLA: burbuja con cara
//   Cara del personaje, anillo de vida, puntita hacia donde está y los metros.
//   Rojo = rival, azul = aliado, dorado = lleva la bandera.
// ------------------------------------------------------
#macro FB_METRO 50   // píxeles del mapa que cuentan como 1 metro

/// Parte de un anillo, desde arriba y en sentido del reloj. _frac de 0 a 1.
function fb_aro(_x, _y, _r1, _r2, _frac, _col, _a) {
	_frac = clamp(_frac, 0, 1);
	if (_frac <= 0) return;
	var _n = max(2, ceil(40 * _frac));
	draw_set_alpha(_a);
	draw_set_color(_col);
	draw_primitive_begin(pr_trianglestrip);
	for (var i = 0; i <= _n; i++) {
		var _ang = 90 - 360 * _frac * (i / _n);
		draw_vertex(_x + lengthdir_x(_r1, _ang), _y + lengthdir_y(_r1, _ang));
		draw_vertex(_x + lengthdir_x(_r2, _ang), _y + lengthdir_y(_r2, _ang));
	}
	draw_primitive_end();
	draw_set_alpha(1);
}

/// Cara según el personaje (0 Asalto, 1 Tanque/Miguel, 2 Exploradora/Marina, 3 Sargento).
function fb_cara_spr(_pj) {
	switch (_pj) {
		case 1: return spr_cara_1;
		case 2: return spr_cara_2;
		case 3: return spr_cara_3;
	}
	return spr_cara_0;
}

/// Va en el Draw GUI de oBrain, en lugar de las flechitas viejas.
function fb_indicadores() {
	var _online = variable_global_exists("ONLINE") && global.ONLINE;
	// En offline usamos fb_indicadores_bot() para el bot
	if (!_online) { fb_indicadores_bot(); return; }
	if (!instance_exists(oOtherPlayer)) return;
	var _cam = view_camera[0];
	var _vx = camera_get_view_x(_cam), _vy = camera_get_view_y(_cam);
	var _vw = camera_get_view_width(_cam), _vh = camera_get_view_height(_cam);
	var _gw = display_get_gui_width(), _gh = display_get_gui_height();
	var _cx = _gw * 0.5, _cy = _gh * 0.5;
	var _mio = scr_my_team();
	var _ox = _vx + _vw / 2, _oy = _vy + _vh / 2;
	if (instance_exists(oPlayer)) { var _yo = instance_find(oPlayer, 0); _ox = _yo.x; _oy = _yo.y; }
	var _ymin = 160;
	var _ymax = touch_mode() ? _gh - 330 : _gh - 90;
	if (_ymax < _ymin) _ymax = _ymin;

	with (oOtherPlayer) {
		if (state == PLAYERSTATE.DEAD || !visible) continue;
		if (scr_pj_oculto(_mio)) continue;   // Exploradora rival: sin circulito (scr_personajes)
		if (x >= _vx && x <= _vx + _vw && y >= _vy && y <= _vy + _vh) continue;   // se ve en pantalla

		// Punto en el borde
		var _tx = (x - _vx) * (_gw / _vw);
		var _ty = (y - 20 - _vy) * (_gh / _vh);
		var _dx = _tx - _cx, _dy = _ty - _cy;
		if (_dx == 0 && _dy == 0) continue;
		var _pad = 56;
		var _k = 1000000000;
		if (_dx != 0) _k = min(_k, ((_dx > 0 ? _gw - _pad : _pad) - _cx) / _dx);
		if (_dy != 0) _k = min(_k, ((_dy > 0 ? _gh - _pad : _pad) - _cy) / _dy);
		var _bx = clamp(_cx + _dx * _k, _pad, _gw - _pad);
		var _by = clamp(_cy + _dy * _k, _ymin, _ymax);
		var _ang = point_direction(_cx, _cy, _tx, _ty);

		var _aliado = (team == _mio);
		var _col = _aliado ? FB_AZUL : FB_ROJO;
		var _flag = has_flag;
		var _punta = _flag ? FB_ORO : _col;
		var _hp = (max_health > 0) ? enemyHealth / max_health : 1;
		var _hpcol = (_hp > 0.5) ? make_color_rgb(91, 227, 125) : make_color_rgb(255, 176, 32);

		// Lleva la bandera: anillo dorado que late
		if (_flag) {
			var _pp = (current_time mod 900) / 900;
			draw_set_alpha(0.9 * (1 - _pp));
			draw_set_color(FB_ORO);
			draw_circle(_bx, _by, 30 + 16 * _pp, true);
			draw_circle(_bx, _by, 31 + 16 * _pp, true);
			draw_circle(_bx, _by, 32 + 16 * _pp, true);
			draw_set_alpha(1);
		}

		// Puntita hacia donde está
		draw_set_color(FB_TINTA);
		draw_triangle(_bx + lengthdir_x(44, _ang), _by + lengthdir_y(44, _ang),
		              _bx + lengthdir_x(26, _ang + 32), _by + lengthdir_y(26, _ang + 32),
		              _bx + lengthdir_x(26, _ang - 32), _by + lengthdir_y(26, _ang - 32), false);
		draw_set_color(_punta);
		draw_triangle(_bx + lengthdir_x(40, _ang), _by + lengthdir_y(40, _ang),
		              _bx + lengthdir_x(27, _ang + 24), _by + lengthdir_y(27, _ang + 24),
		              _bx + lengthdir_x(27, _ang - 24), _by + lengthdir_y(27, _ang - 24), false);

		// Anillo de vida (fondo oscuro + lo que le queda)
		draw_set_color(FB_TINTA);
		draw_circle(_bx, _by, 31, false);
		fb_aro(_bx, _by, 26, 30, 1, make_color_rgb(43, 53, 80), 1);
		fb_aro(_bx, _by, 26, 30, _hp, _hpcol, 1);

		// Círculo con la cara
		draw_set_color(_flag ? FB_ORO : _col);
		draw_circle(_bx, _by, 25, false);
		draw_set_color(FB_TINTA);
		draw_circle(_bx, _by, 22, false);
		var _spr = fb_cara_spr(variable_instance_exists(id, "mySelectedPJ") ? mySelectedPJ : 0);
		var _sc = 30 / max(1, sprite_get_width(_spr));
		draw_sprite_ext(_spr, 0, _bx, _by + 2, _sc, _sc, 0, c_white, 1);

		// Banderita si la lleva
		if (_flag) {
			draw_set_color(FB_TINTA);
			draw_circle(_bx - 21, _by - 21, 12, false);
			draw_set_color(FB_ORO);
			draw_circle(_bx - 21, _by - 21, 10, false);
			fb_icono("flag", _bx - 20, _by - 21);
		}

		// Esta hablando por voz (sala privada, scr_objetivo)
		if (!es_bot && scr_voz_activa() && scr_voz_hablando(clientId)) scr_voz_draw_borde(_bx, _by);

		// Metros
		var _m = string(max(1, round(point_distance(_ox, _oy, x, y) / FB_METRO))) + " m";
		if (_flag) _m = (_aliado ? "ESCOLTALO  " : "ATRAPALO  ") + _m;
		draw_set_font(fnt_small);
		draw_set_halign(fa_center);
		draw_set_valign(fa_middle);
		var _mw = string_width(_m) + 14;
		draw_set_color(FB_TINTA);
		draw_roundrect_ext(_bx - _mw / 2, _by + 31, _bx + _mw / 2, _by + 49, 7, 7, false);
		draw_set_color(_punta);
		draw_roundrect_ext(_bx - _mw / 2, _by + 31, _bx + _mw / 2, _by + 49, 7, 7, true);
		draw_set_color(c_white);
		draw_text(_bx, _by + 40, _m);
	}

	draw_set_alpha(1);
	draw_set_color(c_white);
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
}

/// Burbuja del bot fuera de pantalla (modo local). Misma estetica que fb_indicadores pero para oPlayer2_local.
function fb_indicadores_bot() {
	if (!instance_exists(oPlayer2_local)) return;
	var _cam = view_camera[0];
	var _vx = camera_get_view_x(_cam), _vy = camera_get_view_y(_cam);
	var _vw = camera_get_view_width(_cam), _vh = camera_get_view_height(_cam);
	var _gw = display_get_gui_width(), _gh = display_get_gui_height();
	var _cx = _gw * 0.5, _cy = _gh * 0.5;
	var _mio = scr_my_team();
	var _ox = 0, _oy = 0;
	if (instance_exists(oPlayer_offline)) { var _yo = instance_find(oPlayer_offline, 0); _ox = _yo.x; _oy = _yo.y; }
	var _ymin = 160;
	var _ymax = touch_mode() ? _gh - 330 : _gh - 90;
	if (_ymax < _ymin) _ymax = _ymin;

	with (oPlayer2_local) {
		if (isDead || !visible) continue;
		if (scr_pj_oculto(_mio)) continue;   // Exploradora rival: sin circulito (scr_personajes)
		if (x >= _vx && x <= _vx + _vw && y >= _vy && y <= _vy + _vh) continue;

		var _tx = (x - _vx) * (_gw / _vw);
		var _ty = (y - 20 - _vy) * (_gh / _vh);
		var _dx2 = _tx - _cx, _dy2 = _ty - _cy;
		if (_dx2 == 0 && _dy2 == 0) continue;
		var _pad = 56;
		var _k = 1000000000;
		if (_dx2 != 0) _k = min(_k, ((_dx2 > 0 ? _gw - _pad : _pad) - _cx) / _dx2);
		if (_dy2 != 0) _k = min(_k, ((_dy2 > 0 ? _gh - _pad : _pad) - _cy) / _dy2);
		var _bx = clamp(_cx + _dx2 * _k, _pad, _gw - _pad);
		var _by = clamp(_cy + _dy2 * _k, _ymin, _ymax);
		var _ang = point_direction(_cx, _cy, _tx, _ty);

		var _col = FB_ROJO;   // el bot siempre es rival
		var _flag = has_flag;
		var _punta = _flag ? FB_ORO : _col;
		var _hp_pct = (hp > 0) ? (hp / 100) : 0;
		var _hpcol = (_hp_pct > 0.5) ? make_color_rgb(91, 227, 125) : make_color_rgb(255, 176, 32);

		// Anillo dorado si lleva la bandera
		if (_flag) {
			var _pp = (current_time mod 900) / 900;
			draw_set_alpha(0.9 * (1 - _pp));
			draw_set_color(FB_ORO);
			draw_circle(_bx, _by, 30 + 16 * _pp, true);
			draw_circle(_bx, _by, 31 + 16 * _pp, true);
			draw_circle(_bx, _by, 32 + 16 * _pp, true);
			draw_set_alpha(1);
		}

		// Puntita
		draw_set_color(FB_TINTA);
		draw_triangle(_bx + lengthdir_x(44, _ang), _by + lengthdir_y(44, _ang),
		              _bx + lengthdir_x(26, _ang + 32), _by + lengthdir_y(26, _ang + 32),
		              _bx + lengthdir_x(26, _ang - 32), _by + lengthdir_y(26, _ang - 32), false);
		draw_set_color(_punta);
		draw_triangle(_bx + lengthdir_x(40, _ang), _by + lengthdir_y(40, _ang),
		              _bx + lengthdir_x(27, _ang + 24), _by + lengthdir_y(27, _ang + 24),
		              _bx + lengthdir_x(27, _ang - 24), _by + lengthdir_y(27, _ang - 24), false);

		// Anillo de vida
		draw_set_color(FB_TINTA);
		draw_circle(_bx, _by, 31, false);
		fb_aro(_bx, _by, 26, 30, 1, make_color_rgb(43, 53, 80), 1);
		fb_aro(_bx, _by, 26, 30, _hp_pct, _hpcol, 1);

		// Circulo con cara
		draw_set_color(_flag ? FB_ORO : _col);
		draw_circle(_bx, _by, 25, false);
		draw_set_color(FB_TINTA);
		draw_circle(_bx, _by, 22, false);
		var _spr = fb_cara_spr(variable_instance_exists(id, "mySelectedPJ") ? mySelectedPJ : 0);
		var _sc2 = 30 / max(1, sprite_get_width(_spr));
		draw_sprite_ext(_spr, 0, _bx, _by + 2, _sc2, _sc2, 0, c_white, 1);

		// Banderita si la lleva
		if (_flag) {
			draw_set_color(FB_TINTA);
			draw_circle(_bx - 21, _by - 21, 12, false);
			draw_set_color(FB_ORO);
			draw_circle(_bx - 21, _by - 21, 10, false);
			fb_icono("flag", _bx - 20, _by - 21);
		}

		// Metros
		var _m = string(max(1, round(point_distance(_ox, _oy, x, y) / FB_METRO))) + " m";
		if (_flag) _m = "ATRAPALO  " + _m;
		draw_set_font(fnt_small);
		draw_set_halign(fa_center);
		draw_set_valign(fa_middle);
		var _mw = string_width(_m) + 14;
		draw_set_color(FB_TINTA);
		draw_roundrect_ext(_bx - _mw / 2, _by + 31, _bx + _mw / 2, _by + 49, 7, 7, false);
		draw_set_color(_punta);
		draw_roundrect_ext(_bx - _mw / 2, _by + 31, _bx + _mw / 2, _by + 49, 7, 7, true);
		draw_set_color(c_white);
		draw_text(_bx, _by + 40, _m);
	}

	draw_set_alpha(1);
	draw_set_color(c_white);
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
}

// ------------------------------------------------------
// AVISOS NUEVOS: pastillita de una linea abajo al centro (entre los joysticks)
// ------------------------------------------------------
#macro FB_AVISO_MAX  2      // cuantos se ven a la vez
#macro FB_AVISO_COLA 6      // cuantos pueden esperar en fila
#macro FB_AVISO_SEG  2.4    // cuanto dura cada uno

function fb_avisos_draw(_gw, _gh) {
	// Mismo estilo de tarjeta de siempre (rayita de color, cuadrito con icono, barrita de tiempo), en una linea
	var _n = array_length(global.fb_toasts);
	if (_n == 0) return;
	var _h = 44;
	var _base = _gh - 24 - _h;   // arriba de la tarjeta de abajo
	for (var j = 0; j < _n; j++) {
		var _it = global.fb_toasts[j];
		var _fila = _n - 1 - j;   // el ultimo que entro va abajo (fila 0)
		var _p = _it.t / _it.dur;
		var _a = 1, _dy = 0;
		if (_p < 0.1) { var _q = _p / 0.1; _a = _q; _dy = (1 - fb_ease_out(_q)) * 40; }
		else if (_p > 0.88) _a = (1 - _p) / 0.12;
		draw_set_font(fnt_menu);
		var _w = string_width(_it.titulo) + 74;
		var _x1 = _gw / 2 - _w / 2;
		var _y1 = _base - _fila * (_h + 8) + _dy;
		draw_set_alpha(0.3 * _a);
		draw_set_color(c_black);
		draw_roundrect_ext(_x1, _y1 + 4, _x1 + _w, _y1 + _h + 4, 12, 12, false);
		draw_set_alpha(0.92 * _a);
		draw_set_color(FB_TINTA);
		draw_roundrect_ext(_x1, _y1, _x1 + _w, _y1 + _h, 12, 12, false);
		draw_set_alpha(_a);
		draw_set_color(_it.col);
		draw_rectangle(_x1, _y1 + 6, _x1 + 6, _y1 + _h - 6, false);
		draw_roundrect_ext(_x1 + 16, _y1 + _h / 2 - 14, _x1 + 44, _y1 + _h / 2 + 14, 7, 7, false);
		fb_icono(_it.icono, _x1 + 30, _y1 + _h / 2);
		draw_set_color(_it.col);
		draw_rectangle(_x1 + 12, _y1 + _h - 4, _x1 + 12 + (_w - 24) * (1 - _p), _y1 + _h - 2, false);
		draw_set_halign(fa_left);
		draw_set_valign(fa_middle);
		draw_set_font(fnt_menu);
		draw_set_color(c_white);
		draw_text(_x1 + 54, _y1 + _h / 2, _it.titulo);
	}
	draw_set_alpha(1);
	draw_set_valign(fa_top);
}
