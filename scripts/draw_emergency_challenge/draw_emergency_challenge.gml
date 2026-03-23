function draw_emergency_challenge(px, py) {
    if (!oMenu.mostrando_reto || oMenu.datos_reto == -1) return;

    var cx = px;
    var cy = py;
    var ww = 500;
    var hh = 250;

    // Efecto de parpadeo suave para el borde
    var alpha_pulse = abs(sin(current_time / 200)) * 0.5;

    // 1. FONDO OSCURO DETRÁS
    draw_set_alpha(0.7);
    draw_set_color(c_black);
    draw_rectangle(0, 0, display_get_gui_width(), display_get_gui_height(), false);

    // 2. CAJA DE LA VENTANA
    draw_set_alpha(0.95);
    draw_set_color(make_color_rgb(20, 0, 0)); // Rojo muy oscuro
    draw_roundrect_ext(cx - (ww/2), cy - (hh/2), cx + (ww/2), cy + (hh/2), 15, 15, false);
    
    // Borde con pulso rojo
    draw_set_alpha(1);
    draw_set_color(merge_color(c_red, c_maroon, alpha_pulse));
    draw_roundrect_ext(cx - (ww/2), cy - (hh/2), cx + (ww/2), cy + (hh/2), 15, 15, true);

    // 3. TEXTO Y CONTENIDO
    draw_set_halign(fa_center);
    draw_set_font(fnt_menu);
    draw_set_color(c_white);
    draw_text_transformed(cx, cy - 80, "NUEVO DESAFiO!", 1.2, 1.2, 0);
    
    draw_set_color(c_yellow);
    var nombre_retador = string_upper(oMenu.datos_reto.retador_nombre);
    draw_text(cx, cy - 20, nombre_retador);
    
    draw_set_font(fnt_small);
    draw_set_color(c_white);
    draw_text(cx, cy + 20, "TE HA RETADO A UN DUELO");

    // 4. BOTONES
    var bx1 = cx - 120; var bx2 = cx + 120;
    var by = cy + 80;

    // Aceptar (ENTER)
    draw_set_color(c_lime);
    draw_text(bx1, by, "[ENTER] ACEPTAR");
    
    // Rechazar (SPACE)
    draw_set_color(c_red);
    draw_text(bx2, by, "[ESC] RECHAZAR");
    
    // Barra de tiempo restante (si el timer llega a 0 se cierra)
    var tw = (oMenu.reto_timer / 600) * ww;
    draw_set_color(c_red);
    draw_rectangle(cx - (ww/2), cy + (hh/2) - 5, cx - (ww/2) + tw, cy + (hh/2), false);
}