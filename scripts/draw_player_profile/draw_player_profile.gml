function draw_player_profile(px, py) {
    // --- TAMAÑO XXL ---
    var ww = 800;  
    var hh = 600;  
    var cx = px;
    var cy = py;
    
    // --- 1. FONDO Y MARCO ---
    draw_set_alpha(0.98);
    draw_set_color(make_color_rgb(5, 10, 20));
    draw_roundrect_ext(cx - (ww/2), cy - (hh/2), cx + (ww/2), cy + (hh/2), 20, 20, false);
    
    draw_set_alpha(1);
    draw_set_color(c_aqua);
    draw_roundrect_ext(cx - (ww/2), cy - (hh/2), cx + (ww/2), cy + (hh/2), 20, 20, true);

    // --- 2. ÁREA DEL AVATAR (IZQUIERDA) ---
    var av_x = cx - 250; 
    var av_y = cy - 190;
    var av_radius = 85;
    
    draw_set_color(c_black); draw_set_alpha(0.5);
    draw_circle(av_x, av_y, av_radius, false);
    draw_set_alpha(1); draw_set_color(c_aqua);
    draw_circle(av_x, av_y, av_radius, true);
    
    if (sprite_exists(spr_player_icon)) {
        draw_sprite_ext(spr_player_icon, global.avatar_id, av_x, av_y, 6, 6, 0, c_white, 1);
    }

    // --- 3. NOMBRE E ID (DERECHA DEL AVATAR) ---
    var text_x = cx - 140; 
    var id_y = cy - 250;
    
    draw_set_halign(fa_left);
    draw_set_font(fnt_small);
    draw_set_color(c_gray);
    draw_text(text_x, id_y, "ID: " + string(global.miFriendTag));

    draw_set_font(fnt_menu);
    draw_set_color(c_white);
    var cursor = (input_activo && (current_time % 600 < 300)) ? "|" : "";
    draw_text_transformed(text_x, cy - 215, string_upper(global.myName) + cursor, 1.4, 1.4, 0);
    
    draw_set_color(c_yellow);
    draw_text_transformed(text_x, cy - 175, "[E] EDITAR NOMBRE / [A] SELECCIONAR ICONO", 0.6, 0.6, 0);

    // --- 4. ROL Y LIGA (CENTRADOS) ---
    draw_set_halign(fa_center);
    var rol = "NOOB";
    var rol_col = c_white;
    if (global.flags_captured > global.flags_returned + 2) { rol = "ASALTANTE"; rol_col = c_lime; }
    else if (global.flags_returned > global.flags_captured + 2) { rol = "DEFENSOR"; rol_col = c_aqua; }
    
    draw_set_color(c_orange);
    draw_text_transformed(cx, cy - 115, "LIGA: " + string_upper(global.rank), 1.1, 1.1, 0);
    draw_set_color(c_yellow);
    draw_text_transformed(cx, cy - 90, string(global.copas) + " : COPAS", 0.9, 0.9, 0);
    draw_set_color(rol_col);
    draw_text_transformed(cx, cy - 60, "ROL: " + rol, 0.8, 0.8, 0);

    // --- 5. ESTADÍSTICAS (FILA 1 Y 2) ---
    var sep_h = 250; var start_y = cy + 45;
    draw_stats_box(cx - sep_h, start_y, "KILLS", global.kills, c_red);
    draw_stats_box(cx, start_y, "FLAGS CAPTURE", global.flags_captured, c_lime);
    draw_stats_box(cx + sep_h, start_y, "FLAGS RETURN", global.flags_returned, c_aqua);
    
    var offset_v = start_y + 90;
    draw_stats_box(cx - 120, offset_v, "WINS", global.wins, c_orange);
    draw_stats_box(cx + 120, offset_v, "LOSSES", global.losses, c_gray);

    // --- 6. SECCIÓN DE LOGROS (ESTRELLITAS) ---
    var ach_y = cy + 195; 
    var total_ach = 10;
    var obtained_ach = 0;
    var ids = ["EDfBTkqW", "bQlLwO0e", "Mgt4bwuS", "wpMbRYcU", "lJjtqUBp", "K4ynEN93", "54FbyQ8N", "Y8c81dy3", "Zm9IBCfG", "JkLFQ8yq"];
    for(var i=0; i<total_ach; i++) { if (gmda_check_achievement(ids[i])) obtained_ach++; }
    
    draw_set_color(c_yellow);
    draw_text_transformed(cx, ach_y, "LOGROS OBTENIDOS: " + string(obtained_ach) + "/" + string(total_ach), 0.7, 0.7, 0);
    
    var star_spacing = 35; // Más espacio porque el perfil es grande
    var start_x = cx - ((star_spacing * (total_ach - 1)) / 2); 
    for(var i=0; i<total_ach; i++) {
        var achieved = gmda_check_achievement(ids[i]);
        var _c = achieved ? c_white : c_black;
        var _a = achieved ? 1 : 0.3;
        if (sprite_exists(spr_achievements_images)) {
            draw_sprite_ext(spr_achievements_images, i, start_x + (i * star_spacing), ach_y + 30, 0.7, 0.7, 0, _c, _a);
        }
    }

    // --- 7. BARRA DE XP ---
    var bar_y = cy + 260; var bw = 700; var bh = 25;
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
    draw_text(cx, cy + 295, "[ESC] VOLVER");

if (oMenu.mostrando_selector) {
        draw_set_color(c_black); draw_set_alpha(0.85);
        draw_rectangle(0, 0, display_get_gui_width(), display_get_gui_height(), false);
        
        var vx = cx; var vy = cy;
        var vw = 600; var vh = 450; 
        draw_set_alpha(1); draw_set_color(make_color_rgb(15, 25, 45));
        draw_roundrect_ext(vx - (vw/2), vy - (vh/2), vx + (vw/2), vy + (vh/2), 15, 15, false);
        draw_set_color(c_aqua);
        draw_roundrect_ext(vx - (vw/2), vy - (vh/2), vx + (vw/2), vy + (vh/2), 15, 15, true);
        
        draw_set_color(c_white);
        draw_text(vx, vy - 180, "ELIGE TU ICONO");

        // --- CONFIGURACIÓN DEL ÁREA DE SCROLL ---
        var area_x = vx - 250;
        var area_y = vy - 130;
        var area_w = 500;
        var area_h = 240; // <--- Este es el "hueco" por donde miras
        
        // 1. Creamos una superficie temporal para recortar lo que sobra
        var surf = surface_create(area_w, area_h);
        if (surface_exists(surf)) {
            surface_set_target(surf);
            draw_clear_alpha(c_black, 0); // Limpiar fondo transparente

            var total_iconos = sprite_get_number(spr_player_icon); 
            var columnas = 4;
            var separacion = 120;
            
            // Suavizamos el scroll
            oMenu.scroll_y = lerp(oMenu.scroll_y, oMenu.scroll_y_target, 0.2);

            for (var i = 0; i < total_iconos; i++) {
                var col = i % columnas;
                var fila = floor(i / columnas);
                
                // Calculamos posición RELATIVA a la superficie
                var icon_x = (col * separacion) + 70;
                var icon_y = (fila * separacion) + 60 - oMenu.scroll_y;
                
                // --- DENTRO DEL BUCLE FOR EN EL SELECTOR ---
				var lock = !scr_check_icon_unlocked(i); // Bloquea si NO cumple el requisito

				var _c = lock ? c_black : c_white;
				var _a = lock ? 0.3 : 1;
				draw_sprite_ext(spr_player_icon, i, icon_x, icon_y, 4, 4, 0, _c, _a);

				if (lock) {
				    draw_set_color(c_red);
					draw_set_font(fnt_menu);
				}
                
                // Solo dibujamos si está dentro del rango visible (optimización)
                if (icon_y > -100 && icon_y < area_h + 100) {
                    // Selección
                    if (oMenu.avatar_seleccionado == i) {
                        draw_set_color(c_yellow);
                        draw_rectangle(icon_x - 48, icon_y - 48, icon_x + 48, icon_y + 48, false);
                    }
                    
                    var _c = lock ? c_black : c_white;
                    var _a = lock ? 0.3 : 1;
                    draw_sprite_ext(spr_player_icon, i, icon_x, icon_y, 4, 4, 0, _c, _a);
                    
                    if (lock) {
                        draw_set_color(c_red);
						draw_set_font(fnt_menu);
                        draw_text_transformed(icon_x, icon_y + 35, "LOCK", 0.6, 0.6, 0);
                    }
                }
            }
            
            surface_reset_target();
            draw_surface(surf, area_x, area_y);
            surface_free(surf);
        }

		var info_reto = "REQUISITO: ";
		switch(avatar_seleccionado) {
		    case 0: case 1: info_reto += "INICIAL"; break;
		    case 2: info_reto += "CONSIGUE 100 KILLS"; break;
		    case 3: info_reto += "GANA 10 PARTIDAS"; break;
		    default: info_reto += "LOGRO SECRETO"; break;
		}
		draw_set_color(c_yellow);
		draw_set_font(fnt_menu);
		draw_text_transformed(vx, vy + 145, info_reto, 0.6, 0.6, 0);

        // Botones abajo (Ya no los tapan los iconos)
        draw_set_color(c_lime);
        draw_text(vx, vy + 175, "[ENTER] CONFIRMAR   [SPACE] CANCELAR");
    }
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