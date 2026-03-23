if (instance_exists(owner)) {
    x = owner.x - 7;
    // Ajustamos el -100 si ves que con la imagen nueva queda muy alto o muy bajo
    y = owner.y - 110 + pop_y_offset; 
}


// 1. El offset tiende a 0 (sube el emote)
pop_y_offset = lerp(pop_y_offset, 0, 0.15);

// 2. El tamaño crece hasta la escala calculada (no a 1.5)
image_xscale = lerp(image_xscale, escala_final, 0.15);
image_yscale = image_xscale;

// 3. Vida y Desvanecimiento
life--;
if (life <= 0) instance_destroy();
if (life < 30) image_alpha -= 0.04;