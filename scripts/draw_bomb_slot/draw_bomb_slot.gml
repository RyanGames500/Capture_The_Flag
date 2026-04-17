function draw_bomb_slot(_x, _y, _pj, _name, _ready, _is_me, _team, _w, _h) {
    var _col_team = (_team == "AZUL") ? c_aqua : c_red;
    if (_ready) _col_team = c_lime; 

    // --- 1. FONDO DE PUNTOS (spr_fondo_select) ---
    // Lo dibujamos estirado exactamente al tamaño alto del slot
    draw_sprite_stretched(global.fondo_puntos, 0, _x - (_w/2), _y - (_h/2), _w, _h);

    // --- 2. PERSONAJE (Imagen completa p.ej. Adriana, Terry...) ---
    if (_pj != -1 && _pj < array_length(global.pj_portraits)) {
        var _spr_portrait = global.pj_portraits[_pj]; 
        
        // --- 2a. CÁLCULO DE ESCALA PARA CUERPO COMPLETO ---
        var _img_h = sprite_get_height(_spr_portrait);
        
        // Calculamos escala para que el personaje ocupe el 95% de la altura del cuadro.
        // Esto encogerá tus imágenes gigantes para que queden enteras dentro del slot.
        var _scale = (_h * 0.95) / _img_h; 
        
        // Si no está listo, se ve un poco oscuro (silver)
        var _blend = _ready ? c_white : c_silver;
        
        // --- 2b. DIBUJO DEL JUGADOR ---
        // Dibujamos al personaje centrado, con los pies cerca de la base del cuadro.
        // Asumimos que el origen del sprite es "Middle Center".
        draw_sprite_ext(_spr_portrait, 0, _x, _y + (_h * 0.05), _scale, _scale, 0, _blend, 1);
    }

    // --- 3. EL MARCO (spr_marco_slot) ---
    // Lo escalamos para que cubra exactamente el fondo rojo
    var _anim_frame = (current_time * 0.015) % sprite_get_number(spr_marco_slot); 
    draw_sprite_ext(spr_marco_slot, _anim_frame, _x, _y, (_w * 1.08) / sprite_get_width(spr_marco_slot), (_h * 1.08) / sprite_get_height(spr_marco_slot), 0, _col_team, 1);

    // --- 4. INFO JUGADOR (Nombre arriba) ---
    draw_set_halign(fa_center);
    var _txt_c = _is_me ? c_yellow : c_white;
    // Bajamos un poco el nombre (`_y + (_h/2) + 20`) para que no pise el marco
    draw_text_transformed_color(_x, _y + (_h/2) + 20, _name, 1, 1, 0, _txt_c, _txt_c, c_black, c_black, 1);

    // --- 5. CARTEL READY (Estilo agresivo) ---
    if (_ready) {
        draw_set_alpha(0.7);
        draw_rectangle_color(_x - (_w/2), _y - 30, _x + (_w/2), _y + 30, c_black, c_black, c_black, c_black, false);
        draw_set_alpha(1);
        
        var _vib = sin(current_time*0.05)*5; // Vibración estilo arcade
        draw_text_transformed_color(_x, _y, "READY!", 2, 2, _vib, c_lime, c_lime, c_white, c_white, 1);
    }
    
    // Indicador de "TÚ"
    if (_is_me) {
        var _float = sin(current_time * 0.01) * 5;
        // Ponemos un "P1" o flecha brillante arriba a la izquierda del marco
        draw_text_transformed_color(_x - (_w/2), _y - (_h/2) - 20 + _float, "P1 YOURS", 0.8, 0.8, 0, c_yellow, c_yellow, c_orange, c_orange, 1);
    }
}