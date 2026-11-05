// ======================================================
// RELOJ DE PARTIDA Y AJUSTES DE LA SALA (solo en línea)
//   global.match_tiempo   segundos de partida (0 = SIN LIMITE)
//   global.match_mapa     0 = NIVEL 1, 1 = NIVEL 2, 2 = NIVEL 3
//   global.match_banderas banderas para ganar (1 a 5)
// El reloj lo lleva el líder y lo manda a todos cada segundo ("sync_reloj").
// Si se acaba empatado: MUERTE SUBITA, la siguiente bandera gana.
// ======================================================
#macro RELOJ_ROJO 30   // últimos segundos en rojo

/// Valores de partida rápida: 5 minutos, nivel 1, 3 banderas.
function scr_ajustes_default() {
	global.match_tiempo   = 300;
	global.match_mapa     = 0;
	global.match_banderas = 3;
}

function scr_ajustes_tiempos() { return [180, 300, 480, 600, 0]; }

/// Texto de cada ajuste para la sala de espera.
function scr_ajustes_texto(_fila) {
	switch (_fila) {
		case 0: return (global.match_tiempo <= 0) ? "SIN LIMITE" : string(global.match_tiempo div 60) + " MIN";
		case 1: return "NIVEL " + string(global.match_mapa + 1);
		case 2: return string(global.match_banderas);
	}
	return "";
}

/// Cambia un ajuste (_dir = -1 o 1). Lo usa el líder en la sala de espera.
function scr_ajustes_cambiar(_fila, _dir) {
	switch (_fila) {
		case 0:
			var _ts = scr_ajustes_tiempos();
			var _i = 1;
			for (var k = 0; k < array_length(_ts); k++) if (_ts[k] == global.match_tiempo) _i = k;
			_i = (_i + _dir + array_length(_ts)) mod array_length(_ts);
			global.match_tiempo = _ts[_i];
		break;
		case 1: global.match_mapa = (global.match_mapa + _dir + 3) mod 3; break;
		case 2: global.match_banderas = clamp(global.match_banderas + _dir, 1, 5); break;
	}
}

function scr_ajustes_struct() {
	return { t: global.match_tiempo, m: global.match_mapa, b: global.match_banderas };
}

/// Aplica los ajustes que mandó el líder (revisa que vengan bien).
function scr_ajustes_aplicar(_s) {
	if (!is_struct(_s)) return;
	if (variable_struct_exists(_s, "t") && is_numeric(_s.t)) global.match_tiempo   = max(0, round(_s.t));
	if (variable_struct_exists(_s, "m") && is_numeric(_s.m)) global.match_mapa     = clamp(round(_s.m), 0, 2);
	if (variable_struct_exists(_s, "b") && is_numeric(_s.b)) global.match_banderas = clamp(round(_s.b), 1, 5);
}

/// El líder les manda los ajustes a todos los de la sala.
function scr_ajustes_enviar() {
	var _s = scr_ajustes_struct();
	with (oOtherPlayer) SendEventToClient(clientId, "sync_ajustes", _s);
}

/// Room del mapa elegido.
function scr_mapa_room(_m) {
	switch (_m) {
		case 1: return rm_stage2;
		case 2: return rm_stage3;
	}
	return rm_stage1;
}

/// Banderas para ganar: en línea las de la sala, en local las del menú local.
function scr_banderas_para_ganar() {
	if (global.ONLINE) return variable_global_exists("match_banderas") ? global.match_banderas : 3;
	return variable_global_exists("off_flags") ? global.off_flags : 3;
}

// ------------------------------------------------------
// RELOJ (variables en oBrain: reloj_seg, reloj_frames, reloj_fin)
//   reloj_seg = -1  todavía no empieza (o no hay límite)
// ------------------------------------------------------
function scr_reloj_reset() {
	reloj_seg = -1;
	reloj_frames = 0;
	reloj_fin = false;
}

/// Va en el Step de oBrain.
function scr_reloj_step() {
	if (!global.ONLINE || room == rm_menu) {
		if (reloj_seg != -1 || reloj_fin) scr_reloj_reset();
		return;
	}
	if (global.game_over) return;
	if (global.match_tiempo <= 0) return;                     // SIN LIMITE
	if (!intro_disparada || instance_exists(oIntroVersus)) return;   // empieza cuando termina la intro
	if (!AmIPseudoHost) return;                               // los invitados solo muestran lo que manda el líder

	if (reloj_seg < 0) {
		reloj_seg = global.match_tiempo;
		reloj_frames = 0;
		scr_reloj_enviar();
	}
	if (reloj_fin) return;

	reloj_frames += 1;
	if (reloj_frames >= room_speed) {
		reloj_frames = 0;
		reloj_seg = max(0, reloj_seg - 1);
		if (reloj_seg == 0) reloj_fin = true;
		scr_reloj_enviar();
	}
}

function scr_reloj_enviar() {
	var _s = { s: reloj_seg };
	with (oOtherPlayer) SendEventToClient(clientId, "sync_reloj", _s);
}

/// ¿Se dibuja el reloj? (en línea, con límite y ya empezado)
function scr_reloj_visible() {
	if (!instance_exists(oBrain)) return false;
	return global.ONLINE && room != rm_menu && oBrain.reloj_seg >= 0;
}

/// Reloj debajo del marcador. Va en el Draw GUI de oBrain (centro x, y).
function scr_reloj_draw(_cx, _cy) {
	if (!scr_reloj_visible()) return;
	var _empate = (global.puntos_azul == global.puntos_rojo);
	var _txt, _col, _s = 1;

	if (reloj_fin && _empate) {
		_txt = "MUERTE SUBITA";
		_col = ((current_time div 300) mod 2 == 0) ? c_red : c_yellow;
	} else {
		var _m = reloj_seg div 60;
		var _sg = reloj_seg mod 60;
		_txt = string(_m) + ":" + ((_sg < 10) ? "0" : "") + string(_sg);
		_col = c_white;
		if (reloj_seg <= RELOJ_ROJO) {
			_col = c_red;
			_s = 1 + 0.08 * max(0, 1 - (current_time mod 1000) / 200);   // pequeño latido
		}
	}

	draw_set_font(fnt_menu);
	draw_set_halign(fa_center);
	draw_set_valign(fa_middle);
	var _w = string_width(_txt) * 0.8 + 34;
	draw_set_alpha(0.7);
	draw_set_colour(c_black);
	draw_roundrect_ext(_cx - _w/2, _cy - 16, _cx + _w/2, _cy + 16, 14, 14, false);
	draw_set_alpha(1);
	draw_text_transformed_color(_cx + 2, _cy + 2, _txt, 0.8 * _s, 0.8 * _s, 0, c_black, c_black, c_black, c_black, 1);
	draw_text_transformed_color(_cx, _cy, _txt, 0.8 * _s, 0.8 * _s, 0, _col, _col, _col, _col, 1);

	draw_set_colour(c_white);
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
}

/// Altura del cuadro AJUSTES DE LA PARTIDA en la sala de espera (debajo de los nombres).
function scr_ajustes_panel_y() {
	var _mitad = max(1, global.max_players_allowed / 2);
	return 200 + _mitad * 80 + 4;
}

/// Cuadro AJUSTES DE LA PARTIDA. Va en el Draw GUI de oMenu (sala de espera).
/// (Las flechas < > quedan en las mismas posiciones que lee el Step para el clic/toque)
function scr_ajustes_draw(_soy_lider, _sel) {
	var _tinta = make_color_rgb(11, 15, 26);
	var _azul  = make_color_rgb(31, 155, 255);
	var _oro   = make_color_rgb(255, 212, 71);
	var _gris  = make_color_rgb(169, 180, 208);

	var _cx = display_get_gui_width() / 2;
	var _y0 = scr_ajustes_panel_y();
	var _x1 = _cx - 300, _x2 = _cx + 300;

	ctf_ui_panel(_x1, _y0, _x2, _y0 + 156, _azul);

	draw_set_font(fnt_small);
	draw_set_valign(fa_middle);
	draw_set_halign(fa_left);
	draw_set_colour(_azul);
	draw_rectangle(_x1 + 16, _y0 + 12, _x1 + 18, _y0 + 24, false);
	draw_set_colour(_gris);
	draw_set_alpha(0.7);
	draw_text_transformed(_x1 + 28, _y0 + 18, _soy_lider ? "AJUSTES DE LA PARTIDA" : "AJUSTES DE LA PARTIDA (LOS ELIGE EL LIDER)", 0.6, 0.6, 0);
	draw_set_alpha(1);

	var _nom = ["TIEMPO", "MAPA", "BANDERAS PARA GANAR"];
	for (var f = 0; f < 3; f++) {
		var _fy = _y0 + 48 + f * 34;
		var _on = _soy_lider && (_sel == f);
		if (_on) {
			ctf_ui_para(_x1 + 10, _fy - 15, 580, 30, 8, _azul, 0.12, false);
			ctf_ui_para(_x1 + 10, _fy - 15, 580, 30, 8, _azul, 0.8, true);
		}
		draw_set_font(fnt_small);
		draw_set_halign(fa_left);
		draw_set_colour(_on ? _azul : _gris);
		draw_text_transformed(_x1 + 28, _fy, _nom[f], 0.65, 0.65, 0);

		draw_set_font(fnt_menu);
		draw_set_halign(fa_center);
		draw_set_colour(_oro);
		draw_text_transformed(_cx + 120, _fy, scr_ajustes_texto(f), 0.7, 0.7, 0);
		if (_soy_lider) {
			draw_set_colour(_on ? _azul : _gris);
			draw_set_alpha(_on ? 1 : 0.5);
			draw_text_transformed(_cx + 10, _fy, "<", 0.8, 0.8, 0);
			draw_text_transformed(_cx + 230, _fy, ">", 0.8, 0.8, 0);
			draw_set_alpha(1);
		}
	}
	if (_soy_lider) {
		draw_set_font(fnt_small);
		draw_set_halign(fa_center);
		draw_set_colour(_gris);
		draw_set_alpha(0.5);
		draw_text_transformed(_cx, _y0 + 140, touch_mode() ? "TOCA < > PARA CAMBIAR" : "[W/S] ELEGIR     [A/D] CAMBIAR", 0.55, 0.55, 0);
		draw_set_alpha(1);
	}

	draw_set_colour(c_white);
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
}
