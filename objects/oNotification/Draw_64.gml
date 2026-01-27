var gw = display_get_gui_width();
var gh = display_get_gui_height();

draw_set_font(fnt_killfeed); // Usa una fuente gruesa/bold
draw_set_halign(fa_center);
draw_set_valign(fa_middle);

// Sombra neón (sexy glow)
draw_text_transformed_color(gw/2 + 3, gh/4 + 3, text, scale, scale, 0, c_black, c_black, c_black, c_black, alpha * 0.5);

// Texto principal
draw_text_transformed_color(gw/2, gh/4, text, scale, scale, 0, color, color, color, color, alpha);

// Dibujar el texto dos veces con un pequeño desfase de 1 píxel para que se vea más grueso
//draw_text_transformed_color(gw/2 - 1, gh/4, text, scale, scale, 0, color, color, color, color, alpha);
//draw_text_transformed_color(gw/2 + 1, gh/4, text, scale, scale, 0, color, color, color, color, alpha);