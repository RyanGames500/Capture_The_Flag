// MODO ADITIVO: Esto hará que el sprite del rayo brille intensamente
gpu_set_blendmode(bm_add);

draw_sprite_ext(
    sprite_index, 
    image_index, 
    x, y, 
    image_xscale, 
    image_yscale, 
    image_angle, 
    image_blend, 
    image_alpha
);

gpu_set_blendmode(bm_normal); // Volver siempre al normal