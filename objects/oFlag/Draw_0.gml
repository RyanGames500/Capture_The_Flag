// REY DE LA BANDERA: en vez de la bandera roja se dibuja la zona del centro (scr_reloj)
if (scr_modo_rey()) { scr_rey_draw_zona(); exit; }
// Bandera ROJA: faro cuando esta suelta, en la espalda + estela cuando la llevan
flag_draw_fx(make_color_rgb(255, 42, 58));
