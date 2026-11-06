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
    // Armas con efecto: su propio dibujo (scr_armas)
    if (variable_instance_exists(id, "efecto") && efecto != "") { scr_efx_bala_draw(efecto, x, y, direction); exit; }
    // Balas o Rockets normales (las balas con su estela, scr_mira)
    if (!is_rocket && (sprite_index == sprBullet_gun || sprite_index == sprBullet_smg || sprite_index == sprBullet_escop)) scr_bala_estela(x, y, direction, 24);
    draw_self();
}