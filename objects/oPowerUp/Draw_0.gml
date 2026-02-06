// Dibujar una sombra pequeña en el suelo
draw_set_alpha(0.3);
draw_ellipse_color(x-12, y+15, x+12, y+20, c_black, c_black, false);
draw_set_alpha(1);

// Dibujar el Power-Up con un resplandor (Glow)
draw_sprite_ext(sprite_index, image_index, x, y, 1.1, 1.1, image_angle, image_blend, 0.5); // Brillo detrás
draw_self(); // El item real