var _col = make_color_rgb(215, 124, 255);
var _a = (t < 60) ? t / 60 : 1;                  // se desvanece el último segundo
var _r = HAB_BOTI_RADIO * min(1, (HAB_BOTI_T - t) / 10 + 0.3);

draw_set_alpha(0.10 * _a);
draw_set_colour(_col);
draw_circle(x, y, _r, false);
draw_set_alpha(0.5 * _a);
draw_circle(x, y, _r, true);

// la cajita
draw_set_alpha(_a);
draw_set_colour(c_white);
draw_rectangle(x - 8, y - 4, x + 8, y + 6, false);
draw_set_colour(make_color_rgb(255, 77, 94));
draw_rectangle(x - 2, y - 3, x + 2, y + 5, false);
draw_rectangle(x - 6, y - 1, x + 6, y + 3, false);
draw_set_alpha(1);
draw_set_colour(c_white);
