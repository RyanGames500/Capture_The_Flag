/// @description Draw oMyEntity (Balas / Rockets / Boxeo)

// ======================================================
// 🥊 DIBUJADO ESPECIAL PARA GUANTE DE BOX
// ======================================================
if (variable_instance_exists(id, "is_box") && is_box) 
{
    if (instance_exists(owner)) 
    {
        // 1. Calculamos el origen (el mismo que en el Step)
        var _xBase = owner.x;
        var _yBase = owner.y - 13;

        // 2. Dibujar el "resorte" o cable (línea entre el jugador y el puño)
        draw_set_color(c_gray);
        draw_line_width(_xBase, _yBase, x, y, 3);
        draw_set_color(c_white); // Reset color para no teñir otros sprites

        // 3. Dibujar el puño (Escala 2 como tus otras armas)
        // Usamos image_angle que ya se actualiza en el Step
        draw_sprite_ext(spr_resort_box_idle, 0, x, y, 2, 2, image_angle, c_white, 1);
    }
}
// ======================================================
// 🔫 DIBUJADO NORMAL (BALAS / ROCKETS)
// ======================================================
else 
{
    // Esto dibuja el sprite asignado a la bala/rocket normalmente
    draw_self();
}