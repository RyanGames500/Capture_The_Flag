// Efecto de levitación suave
float_timer += 0.05;
y += sin(float_timer) * 0.2;

// Asignar el frame correcto según el tipo
if (tipo == "heal") image_index = 0;
else if (tipo == "speed") image_index = 1;