/// @description Leer los dedos (Begin Step: antes de que los jugadores lean los controles)
global.tc_prev = global.tc_keys;
global.tc_keys = {};
if (!touch_mode()) exit;

var _W = display_get_gui_width();
var _H = display_get_gui_height();

// --- ¿Menú o juego? ---
mode = "game";
if (room == rm_menu) mode = "menu";
if (variable_global_exists("pausa") && global.pausa) mode = "menu";
if (variable_global_exists("game_over") && global.game_over) mode = "menu";
if (instance_exists(oBrain) && variable_instance_exists(oBrain, "net_estado") && oBrain.net_estado == "lost") mode = "menu";
if (instance_exists(oBrain)) {
	if (variable_instance_exists(oBrain, "abandono_activo") && oBrain.abandono_activo) mode = "menu";
	if (room != rm_menu && variable_global_exists("mi_listo") && !global.mi_listo
	&& variable_instance_exists(oBrain, "intro_disparada") && !oBrain.intro_disparada) mode = "menu";
}

var _btns = touch_buttons(mode, _W, _H);
mv_on = false;
am_on = false;
mv_up = false;
var _mv_h = 0;

for (var i = 0; i < 5; i++) {
	if (!device_mouse_check_button(i, mb_left)) { owner[i] = -1; continue; }
	var _gx = device_mouse_x_to_gui(i);
	var _gy = device_mouse_y_to_gui(i);

	// Dedo nuevo: ver qué tocó
	if (owner[i] == -1) {
		owner[i] = -2;   // nada
		for (var b = 0; b < array_length(_btns); b++) {
			var _bt = _btns[b];
			if (point_distance(_gx, _gy, _bt.bx, _bt.by) <= _bt.r * 1.25) { owner[i] = b; break; }
		}
		if (owner[i] == -2 && mode == "game") {
			if (_gx < _W * 0.42 && _gy > _H * 0.30) { owner[i] = 100; mv_bx = _gx; mv_by = _gy; }
			else if (_gx > _W * 0.58 && _gy > _H * 0.30) { owner[i] = 101; am_bx = _gx; am_by = _gy; }
		}
		// Botones que se usan una vez al tocar
		if (owner[i] >= 0 && owner[i] < 100) {
			var _t = _btns[owner[i]];
			if (_t.act == "emotes") emote_open = !emote_open;
			if (_t.act == "teclado") {
				kb_open = !kb_open;
				if (kb_open) keyboard_virtual_show(kbv_type_default, kbv_returnkey_done, kbv_autocapitalize_none, false);
				else keyboard_virtual_hide();
			}
			if (_t.act != "emotes" && string_copy(_t.act, 1, 5) == "emote") emote_open = false;
		}
	}

	var _o = owner[i];
	if (_o >= 0 && _o < 100 && _o < array_length(_btns)) {
		var _keys = _btns[_o].keys;
		for (var k = 0; k < array_length(_keys); k++) global.tc_keys[$ _keys[k]] = true;
		_btns[_o].down = true;
	}
	else if (_o == 100) {
		mv_on = true;
		var _d = min(point_distance(mv_bx, mv_by, _gx, _gy), 110);
		var _a = point_direction(mv_bx, mv_by, _gx, _gy);
		mv_ox = lengthdir_x(_d, _a);
		mv_oy = lengthdir_y(_d, _a);
		var _h = mv_ox / 110;
		if (_h < -0.3) global.tc_keys[$ string(ord("A"))] = true;
		if (_h >  0.3) global.tc_keys[$ string(ord("D"))] = true;
		_mv_h = _h;
		// Stick hacia arriba = saltar (así no sueltas la mira para brincar)
		mv_up = (mv_oy / 110 < -0.55);
		if (mv_up) global.tc_keys[$ string(ord("W"))] = true;
	}
	else if (_o == 101) {
		am_on = true;
		var _d2 = min(point_distance(am_bx, am_by, _gx, _gy), 110);
		var _a2 = point_direction(am_bx, am_by, _gx, _gy);
		am_ox = lengthdir_x(_d2, _a2);
		am_oy = lengthdir_y(_d2, _a2);
		if (_d2 > 16) global.tc_aim_dir = _a2;
		if (_d2 > 110 * 0.35) global.tc_keys[$ "mb" + string(mb_left)] = true;   // arrastrar lejos = disparar
	}
}
pressed_btns = _btns;

// Si no está apuntando con el otro dedo, mira hacia donde camina
if (!am_on && abs(_mv_h) > 0.3) global.tc_aim_dir = (_mv_h > 0) ? 0 : 180;

// --- Mira: alrededor de mi jugador ---
var _p = noone;
if (instance_exists(oPlayer)) _p = instance_find(oPlayer, 0);
else if (instance_exists(oPlayer_offline)) _p = instance_find(oPlayer_offline, 0);
if (_p != noone) {
	global.tc_aim_x = _p.x + lengthdir_x(touch_aim_dist(), global.tc_aim_dir);
	global.tc_aim_y = _p.y - 16 + lengthdir_y(touch_aim_dist(), global.tc_aim_dir);
}
