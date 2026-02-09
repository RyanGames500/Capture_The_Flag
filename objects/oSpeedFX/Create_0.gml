// Movimiento
vspeed = -random_range(2, 4);       
hspeed = random_range(-1, 1);

// Visual
sprite_index = spr_rayo;            // <--- Pon aquí el nombre exacto de tu sprite
image_speed = 1;                    // Si tu sprite tiene animación
image_alpha = 1;

// Escala aleatoria para variedad
var _sc = random_range(0.6, 1.2);
image_xscale = _sc;
image_yscale = _sc;

// Rotación: Que apunte un poco hacia donde sube o rotación loca eléctrica
image_angle = random_range(-20, 20); 

// Color: Cian o Amarillo eléctrico
image_blend = make_color_rgb(0, 255, 255);