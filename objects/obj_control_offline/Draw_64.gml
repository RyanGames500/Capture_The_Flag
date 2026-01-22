// Si el juego ha terminado, dibujamos el mensaje de victoria
if (game_over == true) 
{
    // --- 1. FONDO SEMI-TRANSPARENTE ---
    // Esto oscurece el juego de fondo para que el texto resalte
    draw_set_alpha(0.8);
    draw_set_color(c_black);
    draw_rectangle(0, 0, display_get_gui_width(), display_get_gui_height(), false);
    
    // --- 2. TEXTO DE VICTORIA ---
    draw_set_alpha(1); // Volvemos a la opacidad total para el texto
    draw_set_halign(fa_center); // Centramos el texto horizontalmente
    draw_set_valign(fa_middle); // Centramos el texto verticalmente
    
    // Elegimos el color según quién ganó
    if (ganador == "AZUL") {
        draw_set_color(c_blue);
    } else {
        draw_set_color(c_red);
    }
    
    // Dibujamos el anuncio (Usamos "transformed" para hacerlo más grande)
    var mid_x = display_get_gui_width() / 2;
    var mid_y = display_get_gui_height() / 2;
    
    draw_text_transformed(mid_x, mid_y, "¡VICTORIA PARA EL EQUIPO " + ganador + "!", 2, 2, 0);
    
    // --- 3. INSTRUCCIONES PARA REINICIAR ---
    draw_set_color(c_white);
    draw_text(mid_x, mid_y + 60, "Presiona 'R' para jugar de nuevo");
}

if (game_over == false) 
{
    draw_set_alpha(1);
    draw_set_color(c_black);
    draw_set_halign(fa_center);
    draw_text(display_get_gui_width() / 2, 30, "AZUL: " + string(puntos_azul) + "  |  ROJO: " + string(puntos_rojo));
}