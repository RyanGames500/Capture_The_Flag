
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_set_font(fnt_killfeed); // Usa una fuente que tengas

// Sombra para que se vea pro
draw_set_color(c_black);
draw_text(display_get_gui_width()/2 + 2, pos_y + 2, text);

// Texto principal
draw_set_color(c_white);
draw_text(display_get_gui_width()/2, pos_y, text);