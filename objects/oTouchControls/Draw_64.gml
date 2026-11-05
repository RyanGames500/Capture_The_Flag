// AJUSTES: que tanto se ven los botones (70% = como siempre)
var tc_a = opt_btn_alpha();
/// @description Dibujar los controles
if (!touch_mode()) exit;
var _W = display_get_gui_width();
var _H = display_get_gui_height();
var _btns = variable_instance_exists(id, "pressed_btns") ? pressed_btns : touch_buttons(mode, _W, _H);

draw_set_font(fnt_menu);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
var _rojo = make_color_rgb(255, 77, 94);
var _amar = make_color_rgb(255, 212, 71);

// --- Sticks ---
if (mode == "game") {
	// Mover (arriba = saltar)
	var _mx = mv_on ? mv_bx : 200;
	var _my = mv_on ? mv_by : _H - 200;
	draw_set_alpha(min(1, tc_a * (0.35))); draw_set_colour(make_color_rgb(10, 8, 20));
	draw_circle(_mx, _my, 110, false);
	draw_set_alpha(min(1, tc_a * (0.7))); draw_set_colour(c_white);
	draw_circle(_mx, _my, 110, true); draw_circle(_mx, _my, 109, true);
	var _cu = mv_up ? _amar : c_white;
	draw_set_colour(_cu);
	draw_triangle(_mx, _my - 98, _mx - 14, _my - 78, _mx + 14, _my - 78, false);
	draw_set_alpha(min(1, tc_a * (0.85)));
	draw_text_transformed_color(_mx, _my - 128, "SALTA", 0.5, 0.5, 0, _cu, _cu, _cu, _cu, 0.85);
	draw_set_alpha(min(1, tc_a * (0.75))); draw_set_colour(c_white);
	draw_circle(_mx + (mv_on ? mv_ox : 0), _my + (mv_on ? mv_oy : 0), 46, false);

	// Apuntar y disparar (arrastrar lejos del centro = disparar)
	var _ax = am_on ? am_bx : _W - 230;
	var _ay = am_on ? am_by : _H - 215;
	draw_set_alpha(min(1, tc_a * (0.35))); draw_set_colour(make_color_rgb(60, 10, 20));
	draw_circle(_ax, _ay, 110, false);
	draw_set_alpha(min(1, tc_a * (0.9))); draw_set_colour(_rojo);
	draw_circle(_ax, _ay, 110, true); draw_circle(_ax, _ay, 109, true);
	draw_set_alpha(min(1, tc_a * (0.6)));
	draw_circle(_ax, _ay, 110 * 0.35, true);
	draw_set_alpha(min(1, tc_a * (0.75))); draw_set_colour(c_white);
	draw_circle(_ax + (am_on ? am_ox : 0), _ay + (am_on ? am_oy : 0), 46, false);
	if (!am_on) draw_text_transformed_color(_ax, _ay + 140, "APUNTA Y DISPARA", 0.45, 0.45, 0, c_white, c_white, c_white, c_white, 0.8);
}

// --- Botones ---
for (var b = 0; b < array_length(_btns); b++) {
	var _bt = _btns[b];
	var _tiene_ico = variable_struct_exists(_bt, "ico");

	// fondo oscuro y borde blanco (amarillo mientras lo aprietas)
	draw_set_alpha(min(1, tc_a * (_bt.down ? 0.7 : 0.5)));
	draw_set_colour(make_color_rgb(10, 8, 20));
	draw_circle(_bt.bx, _bt.by, _bt.r, false);
	draw_set_alpha(min(1, tc_a * (0.9)));
	draw_set_colour(_bt.down ? _amar : c_white);
	draw_circle(_bt.bx, _bt.by, _bt.r, true);
	draw_circle(_bt.bx, _bt.by, _bt.r - 1, true);
	draw_circle(_bt.bx, _bt.by, _bt.r - 2, true);

	// habilidad: anillo de recarga con el color del personaje
	if (variable_struct_exists(_bt, "p")) {
		var _c = variable_struct_exists(_bt, "col") ? _bt.col : c_white;
		draw_set_colour((_bt.p >= 1) ? _c : merge_colour(_c, c_gray, 0.5));
		var _rr = _bt.r - 7, _n = max(2, ceil(40 * _bt.p));
		var _px = _bt.bx, _py = _bt.by - _rr;
		for (var i = 1; i <= _n; i++) {
			var _ang = 90 - 360 * _bt.p * (i / _n);
			var _nx = _bt.bx + lengthdir_x(_rr, _ang), _ny = _bt.by + lengthdir_y(_rr, _ang);
			draw_line_width(_px, _py, _nx, _ny, 6);
			_px = _nx; _py = _ny;
		}
	}

	draw_set_alpha(1);
	if (_tiene_ico) {
		var _ic = c_white;
		if (variable_struct_exists(_bt, "col") && variable_struct_exists(_bt, "p") && _bt.p >= 1) _ic = _bt.col;
		touch_icono(_bt.ico, _bt.bx, _bt.by, _bt.r / 50, _ic);
		if (_bt.txt != "") {
			draw_text_transformed_color(_bt.bx + 2, _bt.by + _bt.r + 20, _bt.txt, 0.5, 0.5, 0, c_black, c_black, c_black, c_black, 0.8);
			draw_text_transformed_color(_bt.bx, _bt.by + _bt.r + 18, _bt.txt, 0.5, 0.5, 0, c_white, c_white, c_white, c_white, 1);
		}
	} else {
		// botones de solo texto (menú, emotes)
		draw_text_transformed_color(_bt.bx, _bt.by, _bt.txt, 0.75, 0.75, 0, c_white, c_white, c_white, c_white, 1);
	}
}

draw_set_alpha(1);
draw_set_colour(c_white);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
