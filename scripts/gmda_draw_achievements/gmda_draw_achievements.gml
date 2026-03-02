function gmda_draw_achievements(xc, yc) {
    var rowspace = 90; 
    var horsize = 550;
    var visible_height = rowspace * 5; 
    
    var table = gmda_get_achievement_list();
    if (is_undefined(table)) exit;
    var size = ds_map_size(table);

    // --- CORRECCIÓN AQUÍ: Usar la variable del objeto ---
    if (!surface_exists(oMenu.ach_surf)) {
        oMenu.ach_surf = surface_create(horsize, visible_height);
    }

    surface_set_target(oMenu.ach_surf);
    draw_clear_alpha(c_black, 0);

    for (var i = 0; i < size; i++) {
        var infoachievement = ds_map_find_value(table, string(i + 1));
        var name = ds_map_find_value(infoachievement, "name");
        var descrip = ds_map_find_value(infoachievement, "descrip");
        var img_num = real(ds_map_find_value(infoachievement, "value"));
        var id_ach = ds_map_find_value(infoachievement, "ide");
        var achieved = gmda_check_achievement(id_ach);
        
        // La Y ahora resta el scroll_y (que debe ser variable global o de oMenu)
        var ry = (rowspace * i) - oMenu.scroll_y; 

        // Optimización: Solo dibujar si está dentro del área visible
        if (ry > -rowspace && ry < visible_height) {
            // Fondo del logro
            draw_set_color(achieved ? c_green : make_color_rgb(60, 60, 60));
            draw_roundrect_ext(5, ry + 5, horsize - 5, ry + rowspace - 5, 15, 15, 0);

            // Icono (Más grande)
            draw_sprite_ext(spr_achievements_images, img_num, 25, ry + (rowspace/2)-25, 1.5, 1.5, 0, c_white, 1);

            // Textos
            draw_set_halign(fa_left);
            draw_set_valign(fa_middle);
            draw_set_font(fnt_menu)
            draw_set_color(c_yellow);
            draw_text_transformed(100, ry + 25, string(i+1) + ". " + string_upper(name), 1.1, 1.1, 0);
            
            draw_set_color(c_white);
            draw_text_ext_transformed(100, ry + 55, descrip, 18, horsize - 120, 0.9, 0.9, 0);
        }
    }
    surface_reset_target();

    // Dibujar el cuadro general de fondo
    draw_set_color(c_black);
    draw_set_alpha(0.5);
    draw_roundrect_ext(xc - 10, yc - 10, xc + horsize + 10, yc + visible_height + 10, 20, 20, 0);
    draw_set_alpha(1);

    // Dibujar la superficie final en la pantalla
    draw_surface(ach_surf, xc, yc);
    
    // Indicador de scroll (opcional)
    draw_set_color(c_gray);
    draw_rectangle(xc + horsize + 5, yc, xc + horsize + 10, yc + visible_height, 0);
    var bar_pos = (oMenu.scroll_y / scroll_max) * (visible_height - 30);
    draw_set_color(c_yellow);
    draw_rectangle(xc + horsize + 5, yc + bar_pos, xc + horsize + 10, yc + bar_pos + 30, 0);
}