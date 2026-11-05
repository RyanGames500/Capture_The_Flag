var _s = 1 - 0.35 * (golpe / 12);
draw_sprite_ext(sprite_index, image_index, x, y, 1, _s, 0, c_white, 1);

// brillo
gpu_set_blendmode(bm_add);
var _a = 0.25 + 0.15 * sin(current_time * 0.006) + golpe / 20;
draw_sprite_ext(sprite_index, image_index, x, y, 1, _s, 0, make_color_rgb(111, 227, 255), _a);
gpu_set_blendmode(bm_normal);
