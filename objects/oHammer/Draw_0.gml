/// @description Prensa con aviso
var _jx = 0;
if (estado == "aviso") {
    _jx = ((aviso_t div 2) mod 2 == 0) ? 1 : -1;   // tiembla

    // piso de abajo en rojo y amarillo, parpadeando
    var _on = ((aviso_t div 5) mod 2 == 0);
    var _fy = y + 90;
    draw_set_alpha(_on ? 0.6 : 0.25);
    draw_set_colour(c_red);
    draw_rectangle(x, _fy - 6, x + 31, _fy, false);
    draw_set_alpha(1);
    for (var i = 0; i < 4; i++) {
        draw_set_colour(_on ? c_yellow : c_black);
        draw_triangle(x + i * 8, _fy - 6, x + i * 8 + 4, _fy - 6, x + i * 8 + 6, _fy, false);
    }
    // "!" encima del piso
    draw_set_halign(fa_center);
    draw_set_valign(fa_bottom);
    draw_set_colour(c_black);
    draw_text(x + 17, _fy - 21, "!");
    draw_set_colour(c_yellow);
    draw_text(x + 16, _fy - 22, "!");
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_colour(c_white);
}
draw_sprite_ext(sprite_index, image_index, x + _jx, y, image_xscale, image_yscale, image_angle, image_blend, image_alpha);
