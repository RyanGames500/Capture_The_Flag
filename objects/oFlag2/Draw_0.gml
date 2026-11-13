// REY DE LA BANDERA: no hay banderas que robar (scr_reloj)
if (scr_modo_sin_banderas()) exit;
// Bandera AZUL: faro cuando esta suelta, en la espalda + estela cuando la llevan
flag_draw_fx(make_color_rgb(31, 155, 255));
