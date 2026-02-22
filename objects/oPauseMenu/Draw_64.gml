if (global.pausa) {
    var gw = display_get_gui_width();
    var gh = display_get_gui_height();
    
    // Fondo oscuro semi-transparente sobre todo el juego
    draw_set_alpha(0.6);
    draw_set_color(c_black);
    draw_rectangle(0, 0, gw, gh, false);
    
    // El cuadro del menú flotante
    var mw = 300;
    var mh = 250;
    var mx = (gw/2) - (mw/2);
    var my = (gh/2) - (mh/2);
    
    draw_set_alpha(0.9);
    draw_set_color(make_color_rgb(20, 25, 35)); // Azul muy oscuro
    draw_roundrect_ext(mx, my, mx + mw, my + mh, 20, 20, false);
    
    // Borde brillante
    draw_set_color(c_aqua);
    draw_roundrect_ext(mx, my, mx + mw, my + mh, 20, 20, true);
    
    // Opciones
    draw_set_alpha(1);
    draw_set_halign(fa_center);
    draw_text(gw/2, my + 40, "--- PAUSA ---");
    
    var opciones = ["CONTINUAR", "REINICIAR", "SALIR AL MENÚ"];
    for(var i=0; i<3; i++) {
        draw_set_color( (pause_index == i) ? c_yellow : c_white );
        var txt = (pause_index == i) ? "> " + opciones[i] + " <" : opciones[i];
        draw_text(gw/2, my + 100 + (i * 50), txt);
    }
}