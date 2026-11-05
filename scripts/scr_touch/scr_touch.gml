// ======================================================
// CONTROLES TÁCTILES (Android / iOS)
// En PC todo sigue igual: estas funciones devuelven el teclado y el mouse de siempre.
// En el celular, además, leen los botones de pantalla de oTouchControls.
// ======================================================
#macro TOUCH_TEST        false   // true = ver los controles táctiles en Windows para probar con el mouse
#macro TOUCH_VIEW_H      340     // alto de la cámara en el celular (el ancho se calcula con la pantalla). Antes 480: se veía muy chico
#macro TOUCH_GUI_H       768     // alto del HUD en el celular
#macro TOUCH_AIM_DIST    160     // a qué distancia del jugador se pone la mira al apuntar con el dedo

/// ¿Estamos en modo táctil?
function touch_mode() {
	return (os_type == os_android || os_type == os_ios || TOUCH_TEST);
}

/// Crea los controles si no existen (se llama desde el menú y desde las cámaras).
function touch_ensure() {
	if (!touch_mode()) return;
	if (!instance_exists(oTouchControls)) instance_create_depth(0, 0, -15000, oTouchControls);
}

function __touch_init() {
	if (!variable_global_exists("tc_keys")) {
		global.tc_keys   = {};      // teclas virtuales apretadas este frame
		global.tc_prev   = {};      // y el frame anterior
		global.tc_aim_x  = 0;
		global.tc_aim_y  = 0;
		global.tc_aim_dir = 0;
	}
}

function __touch_held(_name) {
	__touch_init();
	return (global.tc_keys[$ _name] == true);
}
function __touch_pressed(_name) {
	__touch_init();
	return (global.tc_keys[$ _name] == true) && (global.tc_prev[$ _name] != true);
}

/// Igual que keyboard_check, pero también con los botones de pantalla.
function vkey(_key) {
	if (keyboard_check(_key)) return true;
	return __touch_held(string(_key));
}

/// Igual que keyboard_check_pressed, pero también con los botones de pantalla.
function vkey_pressed(_key) {
	if (keyboard_check_pressed(_key)) return true;
	return __touch_pressed(string(_key));
}

/// Igual que mouse_check_button. En el celular el dedo no cuenta como clic: solo los botones de pantalla.
function vmouse(_button) {
	if (!touch_mode()) return mouse_check_button(_button);
	return __touch_held("mb" + string(_button));
}

/// Igual que mouse_check_button_pressed.
function vmouse_pressed(_button) {
	if (!touch_mode()) return mouse_check_button_pressed(_button);
	return __touch_pressed("mb" + string(_button));
}

/// Hacia dónde apunta el jugador (en PC, el mouse).
function aim_x() {
	if (!touch_mode()) return mouse_x;
	__touch_init();
	return global.tc_aim_x;
}
function aim_y() {
	if (!touch_mode()) return mouse_y;
	__touch_init();
	return global.tc_aim_y;
}

/// Lista de botones de pantalla según el momento (juego o menú).
/// Cada botón: posición, radio, texto y las teclas que aprieta.
function touch_buttons(_mode, _W, _H) {
	var _b = [];
	var _K = function(_bx, _by, _r, _txt, _keys, _act = "") {
		return { bx: _bx, by: _by, r: _r, txt: _txt, keys: _keys, act: _act, down: false };
	};
	var _esc = string(vk_escape);

	if (_mode == "menu") {
		// En el menú principal también se navega con W y S; en el juego no, para no saltar
		var _up = (room == rm_menu) ? [string(vk_up), string(ord("W"))] : [string(vk_up)];
		var _dn = (room == rm_menu) ? [string(vk_down), string(ord("S"))] : [string(vk_down)];
		array_push(_b, _K(170, _H - 270, 46, "^", _up));
		array_push(_b, _K(170, _H - 80,  46, "v", _dn));
		array_push(_b, _K(75,  _H - 175, 46, "<",  [string(vk_left)]));
		array_push(_b, _K(265, _H - 175, 46, ">",  [string(vk_right)]));
		array_push(_b, _K(_W - 130, _H - 140, 62, "OK",    [string(vk_enter)]));
		array_push(_b, _K(_W - 130, _H - 300, 46, "ATRAS", [_esc]));
		if (room == rm_menu) array_push(_b, _K(_W - 130, 70, 44, "TECLADO", [], "teclado"));
		return _b;
	}

	// --- En el juego ---
	var _p = noone;
	if (instance_exists(oPlayer)) _p = instance_find(oPlayer, 0);
	else if (instance_exists(oPlayer_offline)) _p = instance_find(oPlayer_offline, 0);
	var _gran = (_p != noone && variable_instance_exists(_p, "granadas") && _p.granadas > 0);

	// Botones en arco alrededor del stick de apuntar (centro en _W - 230, _H - 215), sin taparlo.
	// ico = qué dibujo lleva (oTouchControls Draw GUI); el texto va abajo del botón.
	var _hb;
	if (_p != noone && _p.object_index == oPlayer && variable_instance_exists(_p, "pj")) {
		// Habilidad de tu personaje en línea (scr_personajes), con su color y su recarga
		_hb = _K(_W - 470, _H - 150, 58, _p.pj.hab, [string(HAB_TECLA)]);
		_hb.ico = string_lower(_p.pj.hab);
		_hb.col = _p.pj.col;
		_hb.p = (_p.hab_cd <= 0) ? 1 : clamp(1 - _p.hab_cd / max(1, _p.hab_cd_max), 0, 1);
		array_push(_b, _hb);
	} else if (instance_exists(oPlayer_offline)) {
		_hb = _K(_W - 470, _H - 150, 58, "GANCHO", ["mb" + string(mb_middle)]);
		_hb.ico = "gancho";
		array_push(_b, _hb);
	}
	_hb = _K(_W - 420, _H - 370, 48, "SALTO", [string(ord("W")), string(vk_space)]);
	_hb.ico = "salto";
	array_push(_b, _hb);
	_hb = _K(_W - 250, _H - 445, 44, _gran ? "GRANADA" : "GOLPE", ["mb" + string(mb_right)]);
	_hb.ico = _gran ? "granada" : "golpe";
	array_push(_b, _hb);
	_hb = _K(_W - 60,  60, 36, "", [_esc]);
	_hb.ico = "pausa";
	array_push(_b, _hb);
	array_push(_b, _K(_W - 150, 60, 34, ":)", [], "emotes"));
	if (instance_exists(oTouchControls) && oTouchControls.emote_open) {
		for (var i = 0; i < 4; i++) {
			array_push(_b, _K(_W - 150 - i * 78, 140, 34, string(i + 1), [string(ord(string(i + 1)))], "emote" + string(i + 1)));
		}
	}
	return _b;
}

/// Dibujito de cada botón (oTouchControls Draw GUI). _s = tamaño.
function touch_icono(_ico, _x, _y, _s, _col) {
	draw_set_colour(_col);
	switch (_ico) {
		case "salto":
			draw_triangle(_x, _y - 16 * _s, _x - 14 * _s, _y + 4 * _s, _x + 14 * _s, _y + 4 * _s, false);
			draw_rectangle(_x - 5 * _s, _y + 3 * _s, _x + 5 * _s, _y + 14 * _s, false);
		break;
		case "impulso":
			draw_triangle(_x - 18 * _s, _y - 14 * _s, _x, _y, _x - 18 * _s, _y + 14 * _s, false);
			draw_triangle(_x, _y - 14 * _s, _x + 18 * _s, _y, _x, _y + 14 * _s, false);
		break;
		case "coraza":
			draw_rectangle(_x - 14 * _s, _y - 16 * _s, _x + 14 * _s, _y + 2 * _s, false);
			draw_triangle(_x - 14 * _s, _y + 2 * _s, _x + 14 * _s, _y + 2 * _s, _x, _y + 18 * _s, false);
		break;
		case "gancho":
			draw_line_width(_x - 14 * _s, _y + 14 * _s, _x + 8 * _s, _y - 8 * _s, 4 * _s);
			draw_circle(_x + 10 * _s, _y - 10 * _s, 7 * _s, true);
			draw_circle(_x + 10 * _s, _y - 10 * _s, 6 * _s, true);
		break;
		case "botiquin":
			draw_rectangle(_x - 5 * _s, _y - 16 * _s, _x + 5 * _s, _y + 16 * _s, false);
			draw_rectangle(_x - 16 * _s, _y - 5 * _s, _x + 16 * _s, _y + 5 * _s, false);
		break;
		case "granada":
			__touch_spr_centro(spr_granada, _x, _y, 2.2 * _s);
		break;
		case "golpe":
			__touch_spr_centro(spr_Hand, _x, _y, 2.6 * _s);
		break;
		case "pausa":
			draw_rectangle(_x - 9 * _s, _y - 11 * _s, _x - 3 * _s, _y + 11 * _s, false);
			draw_rectangle(_x + 3 * _s, _y - 11 * _s, _x + 9 * _s, _y + 11 * _s, false);
		break;
	}
	draw_set_colour(c_white);
}

/// Dibuja un sprite centrado en (_x, _y) sin importar dónde tenga su origen.
function __touch_spr_centro(_spr, _x, _y, _e) {
	var _ox = (sprite_get_width(_spr) / 2 - sprite_get_xoffset(_spr)) * _e;
	var _oy = (sprite_get_height(_spr) / 2 - sprite_get_yoffset(_spr)) * _e;
	draw_sprite_ext(_spr, 0, _x - _ox, _y - _oy, _e, _e, 0, c_white, 1);
}
