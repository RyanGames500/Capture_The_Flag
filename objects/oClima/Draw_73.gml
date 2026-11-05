// Lluvia por encima de todo (Draw End)
var _vx = camera_get_view_x(view_camera[0]);
var _vy = camera_get_view_y(view_camera[0]);
draw_set_alpha(0.35);
draw_set_colour(make_color_rgb(170, 190, 230));
for (var i = 0; i < array_length(gotas); i++) {
	var _g = gotas[i];
	draw_line(_vx + _g.x, _vy + _g.y, _vx + _g.x + 2, _vy + _g.y - 10);
}
draw_set_alpha(1);
draw_set_colour(c_white);
