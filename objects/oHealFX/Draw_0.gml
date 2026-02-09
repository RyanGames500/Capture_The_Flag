// Activamos modo aditivo para que el "+" brille si se enciman varios
gpu_set_blendmode(bm_add);

draw_set_halign(fa_center);
draw_set_valign(fa_middle);

// Dibujamos el "+" (si tienes un sprite úsalo, si no, este texto sirve)
draw_text_transformed_color(
    x, y, "+", 
    image_xscale, image_yscale, image_angle, 
    image_blend, image_blend, image_blend, image_blend, 
    image_alpha
);

gpu_set_blendmode(bm_normal); // Siempre volver al modo normal