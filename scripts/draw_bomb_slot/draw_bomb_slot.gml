function draw_bomb_slot(_x, _y, _pj, _name, _ready, _is_me, _team) {
    var _sz = 75;
    var _col_team = (_team == "AZUL") ? c_aqua : c_red;
    if (_ready) _col_team = c_lime; 

    // --- 0. Fondo interno con transparencia (Siempre abajo) ---
    draw_set_alpha(0.3);
    draw_rectangle_color(_x - _sz, _y - _sz, _x + _sz, _y + _sz, c_black, c_black, _col_team, _col_team, false);
    draw_set_alpha(1);

    // --- 1. PERSONAJE (Foto) - ¡AHORA ABAJO DEL MARCO! ---
    if (_pj != -1) {
        // Dibujamos la cara del personaje primero. 
        // Subí un pelín la escala (de 4 a 4.2) para que el marco lo cubra mejor.
        draw_sprite_ext(spr_player_icon, _pj, _x, _y, 4.2, 4.2, 0, c_white, 1);
        
        draw_set_halign(fa_center);
        var _nombres = ["ASALTO", "TANQUE", "MEDICO", "SCOUT"];
        var _clase = (_pj < array_length(_nombres)) ? _nombres[_pj] : "DESCONOCIDO";
        draw_text_transformed_color(_x, _y + _sz - 20, _clase, 0.8, 0.8, 0, c_white, c_white, c_gray, c_gray, 0.8);
    }

    // --- 2. EL MARCO (Sprite Sincronizado y Transparente) - ¡AHORA ENCIMA! ---
    var _spr_w = sprite_get_width(spr_marco_slot);
    var _escala_marco = (_sz * 2) / _spr_w; 

    var _frames_totales = sprite_get_number(spr_marco_slot);
    var _anim_frame = (current_time * 0.015) % _frames_totales; 

    // CAMBIO AQUÍ: Bajamos el alpha de 1 a 0.7 para la transparencia
    draw_sprite_ext(spr_marco_slot, _anim_frame, _x, _y, _escala_marco, _escala_marco, 0, _col_team, 0.7);

    // --- 3. INFO JUGADOR (Igual que antes, encima de todo) ---
    draw_set_halign(fa_center);
    draw_text_transformed_color(_x, _y - _sz - 25, _name, 1, 1, 0, _col_team, _col_team, c_white, c_white, 1);

    // --- 4. CARTEL READY (Igual que antes) ---
    if (_ready) {
        draw_rectangle_color(_x - _sz, _y - 20, _x + _sz, _y + 20, c_black, c_black, c_black, c_black, false);
        draw_text_transformed_color(_x, _y, "READY!", 1.5, 1.5, sin(current_time*0.05)*5, c_lime, c_lime, c_white, c_white, 1);
    }
    
    // --- 5. TRIANGULITO DE "TÚ" (Original) ---
    if (_is_me) {
        var _float = sin(current_time * 0.01) * 5;
        draw_arrow(_x, _y - _sz - 60 + _float, _x, _y - _sz - 40 + _float, 20);
    }
}