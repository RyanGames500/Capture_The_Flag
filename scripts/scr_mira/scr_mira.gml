// ======================================================
// MIRA, CÁMARA QUE MIRA HACIA DONDE APUNTAS Y BALAS QUE NO SE SALTAN NADA
// ======================================================
#macro MIRA_ADELANTO      0.3    // cuánto se adelanta la cámara hacia la mira
#macro MIRA_ADELANTO_X    150    // máximo hacia los lados
#macro MIRA_ADELANTO_Y    90     // máximo arriba / abajo

/// ¿Está apuntando? En PC siempre (el mouse); en el celular solo con el joystick de apuntar.
function scr_mira_activa() {
	if (!touch_mode()) return true;
	return instance_exists(oTouchControls) && oTouchControls.am_on;
}

/// Lo que se adelanta la cámara (lo usan las cámaras en su Step).
function scr_mira_adelanto_x(_p) {
	if (!instance_exists(_p) || global.game_over || global.pausa || !scr_mira_activa()) return 0;
	var _z = scr_mira_zoom(_p);
	return clamp((aim_x() - _p.x) * (_z ? 0.5 : MIRA_ADELANTO), -(_z ? 280 : MIRA_ADELANTO_X), (_z ? 280 : MIRA_ADELANTO_X));
}
function scr_mira_adelanto_y(_p) {
	if (!instance_exists(_p) || global.game_over || global.pausa || !scr_mira_activa()) return 0;
	var _z = scr_mira_zoom(_p);
	return clamp((aim_y() - _p.y) * (_z ? 0.5 : MIRA_ADELANTO), -(_z ? 140 : MIRA_ADELANTO_Y), (_z ? 140 : MIRA_ADELANTO_Y));
}

/// Con francotirador la cámara ve más lejos (scr_armas)
function scr_mira_zoom(_p) {
	var _q = instance_find(_p, 0);
	if (_q == noone || !variable_instance_exists(_q, "guns")) return false;
	var _w = _q.guns[_q.weapon.index];
	return scr_arma_es_generica(_w) && _w.zoom;
}

/// ¿El tramo de la bala cruza un muro o una plataforma?
function scr_bala_cruza_muro(_x1, _y1, _x2, _y2) {
	if (collision_line(_x1, _y1, _x2, _y2, obj_wall, false, true) != noone) return true;
	if (collision_line(_x1, _y1, _x2, _y2, oPlataformaPasable, false, true) != noone) return true;
	return false;
}

/// El primer rival (en línea) que hay en el tramo de la bala, o noone.
function scr_bala_rival_en_tramo(_x1, _y1, _x2, _y2) {
	var _r = noone;
	var _l = ds_list_create();
	var _n = collision_line_list(_x1, _y1, _x2, _y2, oOtherPlayer, false, true, _l, true);
	for (var i = 0; i < _n; i++) {
		var _c = _l[| i];
		if (variable_instance_exists(_c, "team") && _c.team != global.myTeam) { _r = _c; break; }
	}
	ds_list_destroy(_l);
	return _r;
}

/// Estela de la bala (va antes del draw_self de la bala).
function scr_bala_estela(_x, _y, _dir, _len) {
	var _x0 = _x - lengthdir_x(_len, _dir);
	var _y0 = _y - lengthdir_y(_len, _dir);
	var _xm = (_x0 + _x) / 2, _ym = (_y0 + _y) / 2;
	var _c = make_color_rgb(255, 236, 160);
	draw_set_alpha(0.25);
	draw_line_width_colour(_x0, _y0, _xm, _ym, 2, _c, _c);
	draw_set_alpha(0.7);
	draw_line_width_colour(_xm, _ym, _x, _y, 2, _c, _c);
	draw_set_alpha(1);
}

/// Cuánto se abre cada arma (en grados). La SMG y la M4 se abren más si disparas seguido.
function scr_mira_abertura(_p, _w) {
	switch (_w.type2) {
		case "smg":   return 2   + _p.ak_recoil * 0.6;
		case "m4":    return 1.5 + _p.ak_recoil * 0.6;
		case "escop": return 9;
	}
	if (scr_arma_es_generica(_w)) return (_w.balas > 1) ? _w.disp * 0.5 : _w.disp + _p.ak_recoil * 0.6;
	return 0;
}

/// La mira. Va en el Draw GUI de oMouseIcon_falso (en lugar de la flechita).
function scr_mira_draw() {
	var _p = noone;
	if (instance_exists(oPlayer)) _p = instance_find(oPlayer, 0);
	else if (instance_exists(oPlayer_offline)) _p = instance_find(oPlayer_offline, 0);

	var _vx = camera_get_view_x(view_camera[0]), _vy = camera_get_view_y(view_camera[0]);
	var _kx = display_get_gui_width() / camera_get_view_width(view_camera[0]);
	var _ky = display_get_gui_height() / camera_get_view_height(view_camera[0]);
	var _mx = (aim_x() - _vx) * _kx;
	var _my = (aim_y() - _vy) * _ky;

	// En pausa, al terminar la partida o sin jugador: la flechita de siempre
	var _muerto = (_p == noone) || (variable_instance_exists(_p, "isDead") && _p.isDead);
	if (global.pausa || global.game_over || _muerto) {
		// (como antes: el ícono de oMouseIcon_falso, al mismo tamaño que tenía en el room)
		draw_sprite_ext(sprite_index, image_index, _mx, _my, image_xscale * _kx, image_yscale * _ky, 0, c_white, 1);
		return;
	}
	if (!scr_mira_activa()) return;

	var _w = _p.guns[_p.weapon.index];
	var _arma = (_w != noone && is_struct(_w));

	// "Bloom": se abre un poco cada vez que disparas y se cierra sola
	if (!variable_instance_exists(id, "mira_bloom")) { mira_bloom = 0; mira_ammo = -1; }
	if (_arma) {
		if (mira_ammo != -1 && _w.ammo < mira_ammo) mira_bloom = min(1, mira_bloom + ((_w.type2 == "escop") ? 1 : 0.18));
		mira_ammo = _w.ammo;
	} else mira_ammo = -1;
	mira_bloom = max(0, mira_bloom - 0.04);

	var _dist = point_distance(_p.x, _p.y, aim_x(), aim_y()) * _kx;
	var _ab = _arma ? scr_mira_abertura(_p, _w) : 0;
	var _gap = 6 + tan(degtorad(_ab + mira_bloom * 4)) * _dist * 0.5 + _p.recoil_kick * 1.5;
	_gap = min(_gap, 90);

	var _pega = variable_global_exists("hm_timer") && global.hm_timer > 0;
	var _col = _pega ? c_white : make_color_rgb(255, 212, 71);
	var _a = (_p.has_flag || !_arma) ? 0.45 : 1;   // con la bandera no puedes disparar: se ve apagada

	// 4 rayitas + punto
	draw_set_alpha(_a);
	for (var i = 0; i < 4; i++) {
		var _ang = i * 90;
		var _x1 = _mx + lengthdir_x(_gap, _ang), _y1 = _my + lengthdir_y(_gap, _ang);
		var _x2 = _mx + lengthdir_x(_gap + 9, _ang), _y2 = _my + lengthdir_y(_gap + 9, _ang);
		draw_set_colour(c_black);
		draw_line_width(_x1, _y1, _x2, _y2, 4);
		draw_set_colour(_col);
		draw_line_width(_x1, _y1, _x2, _y2, 2);
	}
	draw_set_colour(_col);
	draw_rectangle(_mx - 1, _my - 1, _mx + 1, _my + 1, false);

	// Anillo: balas que quedan (rojo si quedan pocas) o la recarga (celeste)
	if (_arma) {
		var _r = 24 + _gap * 0.3;
		var _fr = 0, _rc = c_white, _ra = 0.35;
		if (_p.reloading && _p.reload_max > 0) { _fr = 1 - _p.reload_timer / _p.reload_max; _rc = make_color_rgb(111, 227, 255); _ra = 0.9; }
		else if (_w.maxAmmo > 0) { _fr = clamp(_w.ammo / _w.maxAmmo, 0, 1); if (_fr < 0.3) { _rc = make_color_rgb(255, 74, 92); _ra = 0.85; } }
		draw_set_alpha(_ra * _a);
		draw_set_colour(_rc);
		var _seg = 32;
		var _hasta = floor(_seg * _fr);
		for (var s = 0; s < _hasta; s++) {
			var _a1 = 90 - s * (360 / _seg), _a2 = 90 - (s + 1) * (360 / _seg);
			draw_line_width(_mx + lengthdir_x(_r, _a1), _my + lengthdir_y(_r, _a1), _mx + lengthdir_x(_r, _a2), _my + lengthdir_y(_r, _a2), 2);
		}
	}
	draw_set_alpha(1);
	draw_set_colour(c_white);
}
