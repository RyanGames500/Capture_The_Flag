function draw_texture_monitor(_x, _y) {
    // 1. Obtener todas las páginas de textura cargadas actualmente
    var _tex_array = texturegroup_get_textures("Default"); // O puedes dejarlo vacío para ver todas
    var _count = array_length(_tex_array);
    
    // 2. Configurar el dibujo
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    
    // Fondo estético para que se lea bien
    draw_set_alpha(0.5);
    draw_rectangle_color(_x - 5, _y - 5, _x + 220, _y + 60, c_black, c_black, c_black, c_black, false);
    draw_set_alpha(1);
    
    // 3. Dibujar la info
    draw_text_color(_x, _y, "--- MEMORIA DE VIDEO ---", c_yellow, c_yellow, c_orange, c_orange, 1);
    draw_text(_x, _y + 20, "Paginas Activas: " + string(_count));
    
    // 4. Ver si los grupos específicos están cargados (Opcional pero útil)
    var _ui_ready = texture_is_ready("UI") ? "SI" : "NO";
    var _game_ready = texture_is_ready("others") ? "SI" : "NO";
    
    draw_text_color(_x, _y + 40, "Grupo UI: " + _ui_ready, (_ui_ready == "SI" ? c_lime : c_red), c_white, c_white, c_white, 1);
}