if (instance_exists(owner)) {
    x = owner.x-7;
    
    // El "75" es la altura final sobre la cabeza. 
    // Le sumamos el pop_y_offset que irá disminuyendo.
    y = owner.y - 100 + pop_y_offset;
}

// --- LÓGICA DEL MOVIMIENTO ---
// 1. El offset tiende a 0 (sube el emote)
pop_y_offset = lerp(pop_y_offset, 0, 0.15);

// 2. El tamaño crece hasta 1.5
image_xscale = lerp(image_xscale, 1.5, 0.15);
image_yscale = image_xscale;

// 3. Vida y Desvanecimiento
life--;
if (life <= 0) instance_destroy();
if (life < 30) image_alpha -= 0.04;