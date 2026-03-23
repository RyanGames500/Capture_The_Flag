if (instance_exists(owner)) {
    // Dibujar el resorte
    draw_set_color(c_gray);
    draw_line_width(x_base, y_base, x, y, 3);

    // Dibujar el puño (escala 2 como tus otras armas)
    draw_sprite_ext(spr_resort_box_idle, 0, x, y, 2, 2, image_angle, c_white, 1);
}