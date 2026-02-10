var gw = display_get_gui_width();
var gh = display_get_gui_height();

// Fondo
draw_set_color(c_black);
draw_set_alpha(1);
draw_rectangle(0, 0, gw, gh, false);

// Logo o Nombre del Juego
draw_set_alpha(alpha);
draw_set_font(fnt_intro);
draw_set_halign(fa_center);
draw_set_color(c_white);

// Un efecto de "respiración" en el texto
var pulse = 1 + sin(get_timer()/200000) * 0.03;
draw_text_transformed(gw/2, gh/2 - 20, "FLAG CAPTURE!", pulse, pulse, 0);

// Mensaje de estado (Pequeño abajo)
draw_set_font(fnt_menu);
draw_text(gw/2, gh/2 + 80, mensaje);

// Si es Online, podemos dibujar un iconito de red
if (global.ONLINE) {
    draw_set_color(c_lime);
    draw_circle(gw/2 - 100, gh/2 + 80, 4, false);
}