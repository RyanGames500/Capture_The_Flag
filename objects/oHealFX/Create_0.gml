// Movimiento
vspeed = -random_range(1, 2.5);   // Velocidad de subida aleatoria
hspeed = random_range(-0.5, 0.5); // Dispersión lateral
timer = 0;                        // Para la oscilación tipo burbuja

// Visual
image_alpha = 1;
var _scale = random_range(0.7, 1.3);
image_xscale = _scale;
image_yscale = _scale;
image_angle = random(360);
rot_speed = random_range(-2, 2);

// Color verde neón
image_blend = make_color_rgb(80, 255, 80);