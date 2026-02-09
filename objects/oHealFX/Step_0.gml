// Rotación y desvanecimiento
image_angle += rot_speed;
image_alpha -= 0.02; // Se destruye en unos 50 frames

// Oscilación tipo "burbuja" (movimiento de lado a lado)
timer++;
hspeed += sin(timer * 0.1) * 0.08;

// Destrucción
if (image_alpha <= 0) instance_destroy();