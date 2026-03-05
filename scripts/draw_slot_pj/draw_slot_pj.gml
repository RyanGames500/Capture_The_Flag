function draw_slot_pj(_x, _y, _pj_index, _nombre, _listo, _es_mio) {
    var _size = 80; // Un poco más pequeño para que quepan 4 hacia abajo    
    // Dibujar el marco del cuadro
    var _col_marco = _listo ? c_blue : (_es_mio ? c_red : c_white);
    draw_rectangle_color(_x - _size, _y - _size, _x + _size, _y + _size, _col_marco, _col_marco, _col_marco, _col_marco, true);
    
    // Fondo del cuadro
    draw_set_alpha(0.2);
    draw_rectangle(_x - _size, _y - _size, _x + _size, _y + _size, false);
    draw_set_alpha(1);

    // Dibujar la cara del personaje (Index -1 significa que aún no carga)
    if (_pj_index != -1) {
        var _nombre_pj = (_pj_index == 0 ? "ASALTO" : (_pj_index == 1 ? "TANQUE" : "MEDICO"));
        
        // Aquí dibujarías el sprite de la cara
        // draw_sprite_ext(sCaras_PJs, _pj_index, _x, _y, 2, 2, 0, c_white, 1);
        
        draw_set_halign(fa_center);
        draw_text(_x, _y + _size + 20, _nombre_pj);
    }

    // Nombre del Jugador arriba
    draw_text_color(_x, _y - _size - 30, _nombre, c_white, c_white, c_silver, c_silver, 1);
    
    // Cartel de LISTO
    if (_listo) {
        draw_text_transformed_color(_x, _y, "READY", 2, 2, 15, c_lime, c_lime, c_green, c_green, 1);
    }
}