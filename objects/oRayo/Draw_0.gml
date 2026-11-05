var _cyan = make_color_rgb(111, 227, 255);

if (modo == "rayo") {
	var _k = vida / vida_max;
	gpu_set_blendmode(bm_add);
	draw_set_alpha(0.55 * _k);
	draw_line_width_colour(x1, y1, x2, y2, 4 + 10 * _k, _cyan, _cyan);
	draw_set_alpha(_k);
	draw_line_width_colour(x1, y1, x2, y2, 1 + 3 * _k, c_white, c_white);
	draw_circle_colour(x2, y2, 2 + 10 * _k, c_white, _cyan, false);
	draw_circle_colour(x1, y1, 2 + 8 * _k, c_white, _cyan, false);
	draw_set_alpha(1);
	gpu_set_blendmode(bm_normal);
	exit;
}

// --- carga: línea de aviso que parpadea y una bola de luz que crece ---
var _sx = x1, _sy = y1, _a = ang;
if (owner != noone) {
	if (!instance_exists(owner)) { instance_destroy(); exit; }
	var _pp = [x1, y1];
	var _aa = 0;
	with (owner) { _pp = scr_arma_punta(); _aa = weapon.angle; }
	_sx = _pp[0]; _sy = _pp[1]; _a = _aa;
}
var _f = scr_rail_fin(_sx, _sy, _a);
var _k2 = 1 - vida / vida_max;
draw_set_alpha(((current_time div 40) mod 2 == 0) ? 0.8 : 0.35);
draw_line_width_colour(_sx, _sy, _f[0], _f[1], 1, _cyan, _cyan);
gpu_set_blendmode(bm_add);
draw_set_alpha(1);
draw_circle_colour(_sx, _sy, 2 + 7 * _k2, c_white, _cyan, false);
gpu_set_blendmode(bm_normal);
draw_set_alpha(1);
