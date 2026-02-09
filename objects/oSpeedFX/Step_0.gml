// Desvanecimiento
image_alpha -= 0.04; 

// Efecto vibración eléctrica (cambia de escala rápido)
image_xscale += random_range(-0.1, 0.1);
image_yscale = image_xscale;

// Moverse un poco en zigzag
x += sin(current_time * 0.05) * 2;

if (image_alpha <= 0) instance_destroy();