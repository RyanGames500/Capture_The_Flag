// El destello va detrás del nivel (encima del fondo): ilumina el cielo, no los tiles
if (flash <= 0) exit;
var _vx = camera_get_view_x(view_camera[0]);
var _vy = camera_get_view_y(view_camera[0]);
var _vw = camera_get_view_width(view_camera[0]);
var _vh = camera_get_view_height(view_camera[0]);
draw_set_alpha(flash * 0.55);
draw_set_colour(make_color_rgb(220, 230, 255));
draw_rectangle(_vx, _vy, _vx + _vw, _vy + _vh, false);
if (flash > 0.85 && array_length(rayo) > 1) {
	draw_set_alpha(flash);
	draw_set_colour(c_white);
	for (var i = 1; i < array_length(rayo); i++) {
		draw_line_width(_vx + rayo[i - 1][0], _vy + rayo[i - 1][1], _vx + rayo[i][0], _vy + rayo[i][1], 2);
	}
}
draw_set_alpha(1);
draw_set_colour(c_white);
