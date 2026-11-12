// AVISO DE LOGRO (opcion A): tarjeta que baja arriba al centro, debajo del marcador,
// con borde dorado y un brillo que la cruza. Dura ~3 s y se va sola. No se puede tocar (no estorba).
t++;
if (t >= dur) { instance_destroy(); exit; }

var _gw = display_get_gui_width(), _gh = display_get_gui_height();
var _u = clamp(min(_gw / 1280, _gh / 720), 0.6, 1.6);
var _p = t / dur;
var _ease = function(_x) { return 1 - power(1 - _x, 3); };

var _w = 400 * _u, _h = 76 * _u;
var _x1 = _gw / 2 - _w / 2;
var _yfin = 100 * _u;                       // debajo del marcador
var _y1 = _yfin;
var _a = 1;
if (_p < 0.12) { _y1 = lerp(-_h - 10, _yfin, _ease(_p / 0.12)); }
else if (_p > 0.86) { var _q = (_p - 0.86) / 0.14; _y1 = lerp(_yfin, -_h - 10, _ease(_q)); _a = 1 - _q * 0.5; }

var _tinta = make_color_rgb(11, 15, 26), _oro = make_color_rgb(255, 212, 71), _gris = make_color_rgb(169, 180, 208);

// Datos del logro (la lista del juego: DatabaseFunctions, LOGROS)
var _nom = "", _desc = "", _img = 0;
var ach_info = scr_logro_info(ach_id);
if (ach_info != -1) {
    _nom  = string(ds_map_find_value(ach_info, "name"));
    _desc = string(ds_map_find_value(ach_info, "descrip"));
    _img  = real(ds_map_find_value(ach_info, "value"));
}

// Sombra y tarjeta
draw_set_alpha(0.35 * _a);
draw_set_color(c_black);
draw_roundrect_ext(_x1, _y1 + 5 * _u, _x1 + _w, _y1 + _h + 5 * _u, 16 * _u, 16 * _u, false);
draw_set_alpha(0.94 * _a);
draw_set_color(_tinta);
draw_roundrect_ext(_x1, _y1, _x1 + _w, _y1 + _h, 16 * _u, 16 * _u, false);
draw_set_alpha(_a);
draw_set_color(_oro);
draw_roundrect_ext(_x1, _y1, _x1 + _w, _y1 + _h, 16 * _u, 16 * _u, true);
draw_roundrect_ext(_x1 + 1, _y1 + 1, _x1 + _w - 1, _y1 + _h - 1, 15 * _u, 15 * _u, true);

// Cuadro dorado con el icono del logro
var _ic = 52 * _u;
var _icx = _x1 + 14 * _u, _icy = _y1 + (_h - _ic) / 2;
draw_set_color(_oro);
draw_roundrect_ext(_icx, _icy, _icx + _ic, _icy + _ic, 14 * _u, 14 * _u, false);
var _es = (_ic * 0.8) / max(1, sprite_get_width(spr_achievements_images));
var _sx = _icx + _ic / 2 - (sprite_get_width(spr_achievements_images) / 2 - sprite_get_xoffset(spr_achievements_images)) * _es;
var _sy = _icy + _ic / 2 - (sprite_get_height(spr_achievements_images) / 2 - sprite_get_yoffset(spr_achievements_images)) * _es;
draw_sprite_ext(spr_achievements_images, _img, _sx, _sy, _es, _es, 0, c_white, _a);

// Textos
var _tx = _icx + _ic + 14 * _u;
var _maxw = _x1 + _w - 14 * _u - _tx;
draw_set_halign(fa_left);
draw_set_valign(fa_middle);
draw_set_font(fnt_small);
draw_set_color(_oro);
draw_text_transformed(_tx, _y1 + 18 * _u, "LOGRO DESBLOQUEADO", 0.55 * _u, 0.55 * _u, 0);
draw_set_font(fnt_menu);
draw_set_color(c_white);
draw_text_transformed(_tx, _y1 + 40 * _u, ctf_ui_fit(string_upper(_nom), _maxw, 0.8 * _u), 0.8 * _u, 0.8 * _u, 0);
draw_set_font(fnt_small);
draw_set_color(_gris);
draw_text_transformed(_tx, _y1 + 61 * _u, ctf_ui_fit(_desc, _maxw, 0.5 * _u), 0.5 * _u, 0.5 * _u, 0);

// Brillo que cruza la tarjeta (al principio)
if (_p > 0.14 && _p < 0.42) {
    var _q2 = (_p - 0.14) / 0.28;
    var _bx = _x1 + _q2 * (_w + 60 * _u) - 30 * _u;
    var _bx1 = max(_x1 + 8 * _u, _bx - 14 * _u), _bx2 = min(_x1 + _w - 8 * _u, _bx + 14 * _u);
    if (_bx2 > _bx1) {
        draw_set_alpha(0.22 * _a);
        draw_set_color(c_white);
        draw_rectangle(_bx1, _y1 + 3 * _u, _bx2, _y1 + _h - 3 * _u, false);
    }
}

draw_set_alpha(1);
draw_set_color(c_white);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
