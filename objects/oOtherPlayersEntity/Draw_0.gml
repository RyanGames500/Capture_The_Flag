/// @description Draw oOtherPlayerEntity

if (variable_instance_exists(id, "is_box") && is_box) 
{
    // 1. Dibujar el resorte usando las coordenadas remotas que recibimos
    draw_set_color(c_gray);
    draw_line_width(x_base_remote, y_base_remote, x, y, 3);
    draw_set_color(c_white);

    // 2. Dibujar el puño (Escala 2)
    draw_sprite_ext(spr_resort_box_idle, 0, x, y, 2, 2, image_angle, c_white, 1);
}
else 
{
    // Balas o Rockets normales
    draw_self();
}