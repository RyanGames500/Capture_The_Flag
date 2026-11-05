/// @description Resolución del celular al entrar a cada sala
if (!touch_mode()) exit;

var _dw = display_get_width();
var _dh = display_get_height();
var _asp = max(_dw, _dh) / max(1, min(_dw, _dh));

if (instance_exists(oCameraController) || instance_exists(oCameraController_offline)) {
	// En el juego: la cámara se ensancha para llenar toda la pantalla, sin barras negras
	var _vh = TOUCH_VIEW_H;
	var _vw = round(_vh * _asp);
	with (oCameraController)         camera_set_view_size(cam, min(_vw, room_width), _vh);
	with (oCameraController_offline) camera_set_view_size(cam, min(_vw, room_width), _vh);
	view_wport[0] = min(_vw, room_width);
	view_hport[0] = _vh;
	surface_resize(application_surface, view_wport[0] * 2, _vh * 2);
	display_set_gui_size(round(TOUCH_GUI_H * _asp), TOUCH_GUI_H);
} else {
	// En el menú: se deja igual que en PC (con barras a los lados si la pantalla es más ancha)
	var _w = view_enabled ? view_wport[0] : room_width;
	var _h = view_enabled ? view_hport[0] : room_height;
	surface_resize(application_surface, _w, _h);
	display_set_gui_size(_w, _h);
}
