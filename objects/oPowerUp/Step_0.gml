// Efecto de levitación suave
float_timer += 0.05;
y += sin(float_timer) * 0.2;

// Rotación lenta para que brille
image_angle += 1;

// Asignar el frame correcto según el tipo
if (tipo == "salud") image_index = 0;
else if (tipo == "velocidad") image_index = 1;