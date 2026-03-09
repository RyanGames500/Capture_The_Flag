function draw_player_profile(px, py) {
    var ww = 600; 
    var hh = 520; 
    var cx = px;
    var cy = py;
    
    // --- 1. FONDO ---
    draw_set_alpha(0.95);
    draw_set_color(make_color_rgb(10, 15, 25));
    draw_roundrect_ext(cx - (ww/2), cy - (hh/2), cx + (ww/2), cy + (hh/2), 20, 20, false);
    
    draw_set_alpha(1);
    draw_set_color(c_aqua);
    draw_roundrect_ext(cx - (ww/2), cy - (hh/2), cx + (ww/2), cy + (hh/2), 20, 20, true);

// --- 2. ENCABEZADO e ID (CON HOVER Y CLICK) ---
    draw_set_halign(fa_center);
    draw_set_font(fnt_small);
    
    //var player_id = string(gmda_getPlayerid()); 
	var player_id = string(global.miFriendTag); 
    var id_y = cy - 230;
    
    var mouse_gui_x = device_mouse_x_to_gui(0);
    var mouse_gui_y = device_mouse_y_to_gui(0);
    var hovering_id = point_in_rectangle(mouse_gui_x, mouse_gui_y, cx - 60, id_y - 15, cx + 100, id_y + 15);

    // LÓGICA DE INTERACCIÓN
    if (oMenu.copiado_timer > 0) {
        // ESTADO 1: Acaba de copiar (Mensaje de éxito con fade out)
        oMenu.copiado_timer -= 1;
        draw_set_color(c_lime);
		draw_set_font(fnt_menu);
        draw_set_alpha(oMenu.copiado_timer / 90);
        draw_text_transformed(cx + 20, id_y - 18, "COPIADO!", 0.8, 0.8, 0);
        draw_set_alpha(1);
    } 
    else if (hovering_id) {
        // ESTADO 2: Mouse encima (Aviso de que se puede copiar)
        draw_set_color(c_aqua);
		draw_set_font(fnt_menu);
        draw_text_transformed(cx + 20, id_y - 18, "CLICK PARA COPIAR", 0.7, 0.7, 0);
        
        if (mouse_check_button_pressed(mb_left)) {
            clipboard_set_text(player_id);
            oMenu.copiado_timer = 90;
        }
    } else {
        // ESTADO 3: Normal
        draw_set_color(c_gray);
    }
    
    // Dibujo del ID permanente
    draw_text(cx + 20, id_y, "ID: " + player_id);


    // --- EL RESTO DE TU CÓDIGO SIGUE IGUAL ---
    // Nombre
    draw_set_font(fnt_menu);
    draw_set_color(c_white);
    var cursor = (input_activo && (current_time % 600 < 300)) ? "|" : "";
    draw_text_transformed(cx, cy - 185, string_upper(global.myName) + cursor, 1.3, 1.3, 0);
    
    draw_set_color(c_yellow);
    draw_text_transformed(cx, cy - 155, "PRESIONA [E] PARA EDITAR NOMBRE", 0.6, 0.6, 0);

    // ... (Mantén aquí el resto de la función: Rol, Liga, Stats, Logros y Barra XP) ...
    // --- 3. ROL Y LIGA ---
    var rol = "NOOB";
    var rol_col = c_white;
    if (global.flags_captured > global.flags_returned + 2) { rol = "ASALTANTE"; rol_col = c_lime; }
    else if (global.flags_returned > global.flags_captured + 2) { rol = "DEFENSOR"; rol_col = c_aqua; }
    
    var liga = string_upper(global.rank); 
    draw_set_color(c_orange);
    draw_text_transformed(cx, cy - 125, "LIGA: " + liga, 0.9, 0.9, 0);
    draw_set_color(c_yellow);
    draw_text_transformed(cx, cy - 105, string(global.copas) + " : COPAS", 0.8, 0.8, 0);
    draw_set_color(rol_col);
    draw_text_transformed(cx, cy - 80, "ROL: " + rol, 0.7, 0.7, 0);

    // --- 4. ESTADÍSTICAS ---
    var sep_h = 190; var sep_v = 85; var start_y = cy + 25;
    draw_stats_box(cx - sep_h, start_y, "KILLS", global.kills, c_red);
    draw_stats_box(cx, start_y, "FLAGS CAPTURE", global.flags_captured, c_lime);
    draw_stats_box(cx + sep_h, start_y, "FLAGS RETURN", global.flags_returned, c_aqua);
    var offset_v = start_y + sep_v;
    draw_stats_box(cx - 95, offset_v, "WINS", global.wins, c_orange);
    draw_stats_box(cx + 95, offset_v, "LOSSES", global.losses, c_gray);

    // --- 5. SECCIÓN DE LOGROS ---
    var ach_y = cy + 158; 
    var total_ach = 10;
    var obtained_ach = 0;
    var ids = ["EDfBTkqW", "bQlLwO0e", "Mgt4bwuS", "wpMbRYcU", "lJjtqUBp", "K4ynEN93", "54FbyQ8N", "Y8c81dy3", "Zm9IBCfG", "JkLFQ8yq"];
    for(var i=0; i<total_ach; i++) { if (gmda_check_achievement(ids[i])) obtained_ach++; }
    draw_set_color(c_yellow);
    draw_text_transformed(cx, ach_y, "ACHIEVEMENTS: " + string(obtained_ach) + "/" + string(total_ach), 0.7, 0.7, 0);
    var star_spacing = 26;
    var start_x = cx - ((star_spacing * (total_ach - 1)) / 2); 
    for(var i=0; i<total_ach; i++) {
        var achieved = gmda_check_achievement(ids[i]);
        var _c = achieved ? c_white : c_black;
        var _a = achieved ? 1 : 0.4;
        draw_sprite_ext(spr_achievements_images, i, start_x + (i * star_spacing), ach_y + 22, 0.5, 0.5, 0, _c, _a);
    }

    // --- 6. BARRA DE XP ---
    var bar_y = cy + 215; var bw = 500; var bh = 20;
    draw_set_color(c_black);
    draw_roundrect_ext(cx - (bw/2), bar_y, cx + (bw/2), bar_y + bh, 10, 10, false);
    var progress = clamp((global.xp / 100) * bw, 0, bw);
    draw_set_color(c_orange);
    draw_roundrect_ext(cx - (bw/2), bar_y, cx - (bw/2) + progress, bar_y + bh, 10, 10, false);
    draw_set_color(c_white); draw_set_font(fnt_small); draw_set_valign(fa_middle);
    draw_text(cx, bar_y + (bh/2), "NIVEL " + string(global.lvl) + " (" + string(global.xp) + "/100 XP)");
    draw_set_valign(fa_top);

    // Pie
    draw_set_color(c_gray);
    draw_text(cx, cy + 245, "[ESC] EXIT");
}

function draw_stats_box(_x, _y, _label, _val, _col) {
    var _w = 85; // Caja un poco más delgada para que no choquen
    var _h = 38;
    
    draw_set_alpha(0.15); draw_set_color(_col);
    draw_rectangle(_x - _w, _y - _h, _x + _w, _y + _h, false);
    
    draw_set_alpha(1); draw_set_color(_col);
    draw_rectangle(_x - _w, _y - _h, _x + _w, _y + _h, true);
    
    draw_set_color(c_gray);
    draw_text_transformed(_x, _y - 22, _label, 0.55, 0.55, 0); // Texto más pequeño
    
    draw_set_color(c_white);
    draw_text_transformed(_x, _y + 8, string(_val), 1.1, 1.1, 0);
}