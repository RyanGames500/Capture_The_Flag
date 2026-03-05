function draw_bomb_slot(_x, _y, _pj, _name, _ready, _is_me, _team) {
    var _sz = 75;
    var _col_team = (_team == "AZUL") ? c_aqua : c_red;
    if (_ready) _col_team = c_lime; 

    // 1. Bordes y Fondo (Lo que ya teníamos)
    draw_rectangle_color(_x - _sz - 2, _y - _sz - 2, _x + _sz + 2, _y + _sz + 2, _col_team, _col_team, _col_team, _col_team, true);
    draw_rectangle_color(_x - _sz, _y - _sz, _x + _sz, _y + _sz, c_white, c_white, c_white, c_white, true);

    draw_set_alpha(0.3);
    draw_rectangle_color(_x - _sz, _y - _sz, _x + _sz, _y + _sz, c_black, c_black, _col_team, _col_team, false);
    draw_set_alpha(1);

    // 2. PERSONAJE (Sprite de la cara)
    // Usamos el _pj (0, 1, 2) como image_index si tu sprite tiene los 3 personajes dentro
    if (_pj != -1) {
        // Dibujamos el sprite centrado. 
        // Si el sprite mide 32x32, le subimos la escala (ej: 4) para que llene el cuadro.
        draw_sprite_ext(spr_player_icon, _pj, _x, _y, 4, 4, 0, c_white, 1);
        
        // Nombre de la clase abajo
        draw_set_halign(fa_center);
        var _clase = (_pj == 0 ? "ASALTO" : (_pj == 1 ? "TANQUE" : "MEDICO"));
        draw_text_transformed_color(_x, _y + _sz - 20, _clase, 0.8, 0.8, 0, c_white, c_white, c_gray, c_gray, 0.8);
    }

    // 3. Info del Jugador (Lo que ya teníamos)
    draw_set_halign(fa_center);
    draw_text_transformed_color(_x, _y - _sz - 25, _name, 1, 1, 0, _col_team, _col_team, c_white, c_white, 1);

    // 4. Cartel de READY
    if (_ready) {
        draw_rectangle_color(_x - _sz, _y - 20, _x + _sz, _y + 20, c_black, c_black, c_black, c_black, false);
        draw_text_transformed_color(_x, _y, "READY!", 1.5, 1.5, sin(current_time*0.05)*5, c_lime, c_lime, c_white, c_white, 1);
    }
    
    // 5. Triangulito de "TÚ"
    if (_is_me) {
        var _float = sin(current_time * 0.01) * 5;
        draw_arrow(_x, _y - _sz - 60 + _float, _x, _y - _sz - 40 + _float, 20);
    }
}