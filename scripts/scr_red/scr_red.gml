// ======================================================
// AVISO DE RED
// Usa last_got_ping de oBrain: la última vez que el servidor respondió al ping.
// ======================================================
#macro RED_INESTABLE  1500    // ms sin respuesta para "CONEXION INESTABLE"
#macro RED_PERDIDA    5000    // ms sin respuesta para "SIN CONEXION"
#macro RED_BOTONES    15000   // ms en "SIN CONEXION" antes de mostrar los botones
#macro RED_LAG_OTRO   1500    // ms sin datos de otro jugador para ponerle LAG

/// Va en el Step de oBrain.
function scr_red_step() {
	var _en_partida = global.ONLINE && room != rm_menu && global.clientId != -1;
	if (!_en_partida) {
		net_estado = "ok";
		net_toast = 0;
		if (room == rm_menu) scr_red_menu_step();   // en el menu tambien se revisa (abajo)
		return;
	}

	var _sin = current_time - last_got_ping;
	if (_sin > RED_PERDIDA) {
		if (net_estado != "lost") {
			net_estado = "lost";
			net_lost_desde = current_time;
			net_botones_desde = current_time;
			net_sel = 0;
		}
	} else if (_sin > RED_INESTABLE) {
		if (net_estado != "lost") net_estado = "unst";
	} else {
		if (net_estado == "lost") net_toast = 120;   // volvió la conexión
		net_estado = "ok";
	}
	if (net_toast > 0) net_toast -= 1;

	// Botones: SEGUIR ESPERANDO / SALIR AL MENU
	if (net_estado == "lost" && current_time - net_botones_desde > RED_BOTONES) {
		var _mv = vkey_pressed(vk_right) - vkey_pressed(vk_left);
		if (_mv != 0) net_sel = clamp(net_sel + _mv, 0, 1);
		var _ok = vkey_pressed(vk_enter);

		// También con clic o con el dedo directo sobre el botón
		if (device_mouse_check_button_pressed(0, mb_left)) {
			var _gx = device_mouse_x_to_gui(0);
			var _gy = device_mouse_y_to_gui(0);
			var _cx = display_get_gui_width() / 2;
			var _by = display_get_gui_height() / 2 + 150;
			if (_gy > _by - 32 && _gy < _by + 32) {
				if (_gx > _cx - 330 && _gx < _cx - 20) { net_sel = 0; _ok = true; }
				if (_gx > _cx + 20  && _gx < _cx + 330) { net_sel = 1; _ok = true; }
			}
		}

		if (_ok) {
			if (net_sel == 0) net_botones_desde = current_time;   // esperar otros 15 s
			else scr_red_salir();
		}
	}
}

/// Salir al menú cuando no hay conexión, y volver a conectarse desde cero.
function scr_red_salir() {
	net_estado = "ok";
	net_toast = 0;
	try { network_destroy(oBrain.socket); } catch (_e) {}
	global.clientId = -1;
	callback_LeaveRoom();      // limpia la partida y va al menú
	ConnectToServer();         // conexión nueva
	last_got_ping = current_time;
}

/// Rayitas de señal + ping. Va en el Draw GUI de oBrain.
/// _abajo = true: solito y chiquito en la esquina de abajo a la derecha (en la partida). false: arriba a la derecha (en el menú).
function scr_red_draw_hud(_abajo = false) {
	if (_abajo) { scr_red_draw_esquina(); return; }
	var _x2 = display_get_gui_width() - 10;
	var _y2 = 10;
	if (_abajo) {
		_x2 = display_get_gui_width() / 2 + 78;
		_y2 = display_get_gui_height() - 40;
	}

	var _q = 4;
	var _col = c_lime;
	if (net_estado == "lost")      { _q = 0; _col = c_red; }
	else if (net_estado == "unst") { _q = 1; _col = c_red; }
	else if (global.ping >= 250)   { _q = 1; _col = c_red; }
	else if (global.ping >= 180)   { _q = 2; _col = c_yellow; }
	else if (global.ping >= 120)   { _q = 3; _col = c_yellow; }
	var _apagado = (net_estado != "ok") && ((current_time div 250) mod 2 == 0);

	draw_set_alpha(0.55);
	draw_set_colour(c_black);
	draw_roundrect_ext(_x2 - 150, _y2 - 4, _x2 + 6, _y2 + 30, 8, 8, false);
	draw_set_alpha(1);

	for (var i = 0; i < 4; i++) {
		var _bx = _x2 - 142 + i * 9;
		var _bh = 6 + i * 5;
		draw_set_colour((i < _q && !_apagado) ? _col : c_dkgray);
		draw_rectangle(_bx, _y2 + 24 - _bh, _bx + 6, _y2 + 24, false);
	}

	var _txt = (net_estado == "ok" && global.ping >= 0) ? string(global.ping) + " ms" : "--- ms";
	draw_set_font(fnt_killfeed);
	draw_set_halign(fa_right);
	draw_set_valign(fa_top);
	draw_set_colour(c_black);
	draw_text_transformed(_x2 + 1, _y2 + 1, _txt, 0.8, 0.8, 0);
	draw_set_colour(_col);
	draw_text_transformed(_x2, _y2, _txt, 0.8, 0.8, 0);

	// Aviso amarillo de conexión inestable (abajo del ping en el menú, arriba del ping en la partida)
	if (net_estado == "unst") {
		var _w = 230;
		var _ax2 = _abajo ? _x2 - 78 + _w / 2 : _x2;
		var _ay = _abajo ? _y2 - 44 : _y2 + 40;
		draw_set_colour(c_black);
		draw_roundrect_ext(_ax2 - _w + 3, _ay + 3, _ax2 + 3, _ay + 32 + 3, 6, 6, false);
		draw_set_colour(c_yellow);
		draw_roundrect_ext(_ax2 - _w, _ay, _ax2, _ay + 32, 6, 6, false);
		draw_set_halign(fa_center);
		draw_set_valign(fa_middle);
		draw_set_colour(c_black);
		draw_text_transformed(_ax2 - _w / 2, _ay + 16, "CONEXION INESTABLE", 0.8, 0.8, 0);
	}

	draw_set_colour(c_white);
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
}

/// Pantalla de SIN CONEXION y aviso de CONEXION RECUPERADA. Al final del Draw GUI de oBrain.
function scr_red_draw_overlay() {
	if (!global.ONLINE || room == rm_menu) return;
	var _gw = display_get_gui_width();
	var _gh = display_get_gui_height();
	var _cx = _gw / 2;
	var _cy = _gh / 2;
	draw_set_font(fnt_menu);
	draw_set_halign(fa_center);
	draw_set_valign(fa_middle);

	if (net_estado == "lost") {
		draw_set_alpha(0.75);
		draw_set_colour(c_black);
		draw_rectangle(0, 0, _gw, _gh, false);
		draw_set_alpha(1);

		// ruedita girando
		for (var i = 0; i < 8; i++) {
			var _a = i * 45 - current_time * 0.36;
			draw_set_alpha(0.25 + 0.75 * (i / 7));
			draw_set_colour(c_white);
			draw_circle(_cx + lengthdir_x(30, _a), _cy - 140 + lengthdir_y(30, _a), 6, false);
		}
		draw_set_alpha(1);

		draw_text_transformed_color(_cx + 4, _cy - 50 + 4, "SIN CONEXION", 2.6, 2.6, 0, c_black, c_black, c_black, c_black, 1);
		draw_text_transformed_color(_cx, _cy - 50, "SIN CONEXION", 2.6, 2.6, 0, c_red, c_red, c_maroon, c_maroon, 1);
		var _seg = floor((current_time - net_lost_desde) / 1000) + floor(RED_PERDIDA / 1000);
		draw_text_transformed_color(_cx, _cy + 20, "Reconectando... " + string(_seg) + " s", 1.1, 1.1, 0, c_white, c_white, c_white, c_white, 1);
		draw_text_transformed_color(_cx, _cy + 60, "Revisa tu wifi o tus datos", 0.9, 0.9, 0, c_ltgray, c_ltgray, c_ltgray, c_ltgray, 1);

		if (current_time - net_botones_desde > RED_BOTONES) {
			var _by = _cy + 150;
			for (var b = 0; b < 2; b++) {
				var _x1 = (b == 0) ? _cx - 330 : _cx + 20;
				var _x2 = _x1 + 310;
				var _sel = (net_sel == b);
				draw_set_colour(_sel ? c_white : c_black);
				draw_set_alpha(_sel ? 1 : 0.5);
				draw_rectangle(_x1, _by - 32, _x2, _by + 32, false);
				draw_set_alpha(1);
				draw_set_colour(c_white);
				draw_rectangle(_x1, _by - 32, _x2, _by + 32, true);
				var _tc = _sel ? c_black : c_white;
				draw_text_transformed_color((_x1 + _x2) / 2, _by, (b == 0) ? "SEGUIR ESPERANDO" : "SALIR AL MENU", 1, 1, 0, _tc, _tc, _tc, _tc, 1);
			}
		}
	}

	if (net_toast > 0) {
		var _ta = min(1, net_toast / 20);
		var _txt = "CONEXION RECUPERADA";
		var _w2 = string_width(_txt) * 1.1 + 60;
		draw_set_alpha(0.95 * _ta);
		draw_roundrect_color_ext(_cx - _w2/2, 200 - 26, _cx + _w2/2, 200 + 26, 40, 40, make_color_rgb(30, 160, 80), make_color_rgb(30, 160, 80), false);
		draw_set_alpha(_ta);
		draw_text_transformed_color(_cx, 200, _txt, 1.1, 1.1, 0, c_white, c_white, c_white, c_white, _ta);
		draw_set_alpha(1);
	}

	draw_set_colour(c_white);
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
}

/// LAG encima de otro jugador. Va al final del Draw de oOtherPlayer.
function scr_red_draw_lag() {
	if (!visible) return;
	var _sin = current_time - last_sp_time;
	var _afk = (variable_instance_exists(id, "afk") && is_numeric(afk)) ? afk : 0;
	if (_sin < RED_LAG_OTRO && _afk < RED_LAG_OTRO + 500) return;

	// lo oscurezco: se ve gris y medio transparente
	if (sprite_exists(sprite_index)) {
		draw_sprite_ext(sprite_index, image_index, x, y, image_xscale, image_yscale, image_angle, c_black, 0.45);
	}

	var _ty = bbox_top - 40 + sin(current_time * 0.006) * 4;
	draw_set_font(fnt_killfeed);
	draw_set_halign(fa_center);
	draw_set_valign(fa_middle);
	draw_set_alpha(0.8);
	draw_set_colour(c_black);
	draw_roundrect_ext(x - 26, _ty - 12, x + 26, _ty + 12, 4, 4, false);
	draw_set_alpha(1);
	draw_set_colour(c_red);
	draw_roundrect_ext(x - 26, _ty - 12, x + 26, _ty + 12, 4, 4, true);
	draw_text_transformed(x, _ty, "LAG", 0.7, 0.7, 0);
	draw_set_colour(c_white);
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
}

/// Ping en la partida: rayitas y ms chiquitos en la esquina de abajo a la derecha, sin cuadro
function scr_red_draw_esquina() {
	var _gw = display_get_gui_width(), _gh = display_get_gui_height();
	var _x2 = _gw - 14, _y2 = _gh - 12;   // abajo a la derecha (es el borde de abajo del texto)
	var _q = 4;
	var _col = c_lime;
	if (net_estado == "lost")      { _q = 0; _col = c_red; }
	else if (net_estado == "unst") { _q = 1; _col = c_red; }
	else if (global.ping >= 250)   { _q = 1; _col = c_red; }
	else if (global.ping >= 180)   { _q = 2; _col = c_yellow; }
	else if (global.ping >= 120)   { _q = 3; _col = c_yellow; }
	var _apagado = (net_estado != "ok") && ((current_time div 250) mod 2 == 0);

	var _txt = (net_estado == "ok" && global.ping >= 0) ? string(global.ping) + " ms" : "--- ms";
	draw_set_font(fnt_killfeed);
	var _sc = 0.6;
	var _tw = string_width(_txt) * _sc;
	draw_set_halign(fa_right);
	draw_set_valign(fa_bottom);
	draw_set_colour(c_black);
	draw_text_transformed(_x2 + 1, _y2 + 1, _txt, _sc, _sc, 0);
	draw_set_colour(_col);
	draw_text_transformed(_x2, _y2, _txt, _sc, _sc, 0);

	// Rayitas de senal a la izquierda del texto
	for (var i = 0; i < 4; i++) {
		var _bx = _x2 - _tw - 8 - (3 - i) * 6 - 4;
		var _bh = 4 + i * 3;
		draw_set_colour((i < _q && !_apagado) ? _col : c_dkgray);
		draw_rectangle(_bx, _y2 - _bh, _bx + 4, _y2, false);
	}

	// Aviso amarillo de conexion inestable, arriba del ping en la esquina
	if (net_estado == "unst") {
		var _w = 230;
		var _ay = _y2 - 26 - 38;
		draw_set_colour(c_black);
		draw_roundrect_ext(_x2 - _w + 3, _ay + 3, _x2 + 3, _ay + 32 + 3, 6, 6, false);
		draw_set_colour(c_yellow);
		draw_roundrect_ext(_x2 - _w, _ay, _x2, _ay + 32, 6, 6, false);
		draw_set_halign(fa_center);
		draw_set_valign(fa_middle);
		draw_set_colour(c_black);
		draw_text_transformed(_x2 - _w / 2, _ay + 16, "CONEXION INESTABLE", 0.8, 0.8, 0);
	}

	draw_set_colour(c_white);
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
}


// ======================================================
// CONEXION EN EL MENU
// Antes solo se revisaba en la partida. Si el servidor se reiniciaba (por ejemplo cuando
// Render se actualiza) o se caia el internet estando en el menu, el juego seguia como si
// estuviera conectado: buscabas partida y nadie contestaba, y a los 3 s te mandaba al bot
// viejo (la sala con un solo bot). Ahora, si el servidor deja de contestar el ping,
// se vuelve a conectar solo (cada 10 s mientras no lo logre) y cancela la busqueda.
// ======================================================
#macro RED_MENU_REINTENTO 10000   // ms entre intentos de volver a conectar

function scr_red_menu_step() {
	if (!variable_global_exists("red_reconectando")) { global.red_reconectando = false; global.red_intento_t = 0; }
	// Ya conectado y contestando: todo bien
	if (global.clientId != -1 && current_time - last_got_ping <= RED_PERDIDA) { global.red_reconectando = false; return; }
	var _caida = (global.clientId != -1 && current_time - last_got_ping > RED_PERDIDA);   // estaba conectado y dejo de contestar
	var _reintento = (global.clientId == -1 && global.red_reconectando && current_time - global.red_intento_t > RED_MENU_REINTENTO);
	if (!_caida && !_reintento) return;
	if (_caida) {
		show_debug_message(">>> RED: el servidor no contesta en el menu, me vuelvo a conectar");
		// Si estaba buscando partida o en una sala, eso ya no sirve: de regreso a elegir modo
		if (instance_exists(oMenu) && (oMenu.menu_state == "connecting" || oMenu.menu_state == "lobby_espera")) {
			oMenu.menu_state = "modos";
			if (variable_global_exists("mn_ui") && is_struct(global.mn_ui)) { global.mn_ui.msg = "SE PERDIO LA CONEXION, BUSCA OTRA VEZ"; global.mn_ui.msg_t = 150; }
		}
		global.botq_pendiente = false;
		global.botnet_defs = [];
		global.botnet_partida = false;
	}
	global.red_reconectando = true;
	global.red_intento_t = current_time;
	try { network_destroy(oBrain.socket); } catch (_e) {}
	global.clientId = -1;
	global.roomId = "";
	ConnectToServer();          // conexion nueva (al conectar entra solo a tu cuenta)
	last_got_ping = current_time;
}
