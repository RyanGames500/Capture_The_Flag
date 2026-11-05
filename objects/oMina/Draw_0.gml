// Los de tu equipo la ven bien; los rivales casi no
var _a = (es_mia || team == scr_my_team()) ? 1 : 0.3;
if (armado > 0) _a *= 0.5;
draw_sprite_ext(sprite_index, 0, x, y - 6, 1.5, 1.5, 0, c_white, _a);

var _on = (mecha >= 0) ? ((current_time div 60) mod 2 == 0) : ((current_time div 100) mod 12 == 0);
if (_on && armado <= 0) {
	gpu_set_blendmode(bm_add);
	draw_set_alpha(_a);
	draw_circle_colour(x, y - 10, (mecha >= 0) ? 10 : 5, c_red, c_black, false);
	draw_set_alpha(1);
	gpu_set_blendmode(bm_normal);
}

// Aviso: el radio de la explosión se va cerrando
if (mecha >= 0) {
	draw_set_alpha(0.5);
	draw_set_colour(c_red);
	draw_circle(x, y - 8, MINA_RADIO * (1 - mecha / MINA_MECHA) + 4, true);
	draw_set_alpha(1);
	draw_set_colour(c_white);
}
