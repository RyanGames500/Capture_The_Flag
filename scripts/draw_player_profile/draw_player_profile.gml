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

    // --- 2. ENCABEZADO ---
    draw_set_halign(fa_center);
    
    // ID
    draw_set_font(fnt_small);
    draw_set_color(c_gray);
    var player_id = gmda_getPlayerid(); 
    draw_text(cx + 20, cy - 230, "ID: " + string(player_id));

    // Nombre
    draw_set_font(fnt_menu);
    draw_set_color(c_white);
    var cursor = (input_activo && (current_time % 600 < 300)) ? "|" : "";
    draw_text_transformed(cx, cy - 185, string_upper(global.myName) + cursor, 1.3, 1.3, 0);
    
    draw_set_color(c_yellow);
    draw_text_transformed(cx, cy - 155, "PRESIONA [E] PARA EDITAR NOMBRE", 0.6, 0.6, 0);

	// --- 3. SEPARACIÓN DE ROL Y LIGA ---
    var rol = "NOOB";
    var rol_col = c_white;
    if (global.flags_captured > global.flags_returned + 2) { rol = "ASALTANTE"; rol_col = c_lime; }
    else if (global.flags_returned > global.flags_captured + 2) { rol = "DEFENSOR"; rol_col = c_aqua; }
    
    var liga = string_upper(global.rank); 

    // Dibujamos la LIGA y las COPAS en una sola línea bien organizada
    draw_set_color(c_orange);
    draw_text_transformed(cx, cy - 125, "LIGA: " + liga, 0.9, 0.9, 0);
    
    draw_set_color(c_yellow); // Color oro para las copas
    draw_text_transformed(cx, cy - 105, string(global.copas) + ": COPAS", 0.8, 0.8, 0);
    
    // Dibujamos el ROL un poco más abajo
    draw_set_color(rol_col);
    draw_text_transformed(cx, cy - 80, "ROL: " + rol, 0.7, 0.7, 0);

    // --- 4. GRID DE ESTADÍSTICAS (5 CAJAS REORGANIZADAS) ---
    var sep_h = 190; 
    var sep_v = 85;  
    var start_y = cy + 25;

    // Fila 1: Las 3 principales
    draw_stats_box(cx - sep_h, start_y, "KILLS", global.kills, c_red);
    draw_stats_box(cx, start_y, "FLAGS CAPTURE", global.flags_captured, c_lime);
    draw_stats_box(cx + sep_h, start_y, "FLAGS RETURN", global.flags_returned, c_aqua);

    // Fila 2: Victorias y Derrotas (Centradas)
    var offset_v = start_y + sep_v;
    draw_stats_box(cx - 95, offset_v, "WINS", global.wins, c_orange);
    draw_stats_box(cx + 95, offset_v, "LOSSES", global.losses, c_gray);

    // --- 5. BARRA DE XP ---
    var bar_y = cy + 200;
    var bw = 500;
    var bh = 22;
    
    draw_set_color(c_black);
    draw_roundrect_ext(cx - (bw/2), bar_y, cx + (bw/2), bar_y + bh, 10, 10, false);
    
    var progress = clamp((global.xp / 100) * bw, 0, bw);
    draw_set_color(c_orange);
    draw_roundrect_ext(cx - (bw/2), bar_y, cx - (bw/2) + progress, bar_y + bh, 10, 10, false);
    
    draw_set_color(c_white);
    draw_set_font(fnt_small);
    draw_text(cx, bar_y + 11, "NIVEL " + string(global.lvl) + " (" + string(global.xp) + "/100 XP)");

    // Pie
    draw_set_color(c_gray);
    draw_text(cx, cy + 240, "[ESC] PARA VOLVER AL MENU");
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