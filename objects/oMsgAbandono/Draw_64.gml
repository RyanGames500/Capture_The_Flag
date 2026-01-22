// --- Evento Draw GUI de oMsgAbandono ---
draw_set_halign(fa_center);
draw_set_alpha(alpha);

// Sombra negra
draw_set_color(c_black);
draw_text(display_get_gui_width()/2 + 2, y_pos + 2, texto);

// Texto en color (puedes usar c_red o c_orange)
draw_set_color(c_red);
draw_text(display_get_gui_width()/2, y_pos, texto);

// Lógica de movimiento
y_pos -= 1; 
alpha -= 0.01;

if (alpha <= 0) instance_destroy();
draw_set_alpha(1);