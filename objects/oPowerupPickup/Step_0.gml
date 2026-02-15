// Efecto de levitación suave
float_timer += 0.05;
y += sin(float_timer) * 0.2;

// Asignar el frame correcto según el tipo
switch(tipo) {
    case "heal":   image_index = 0; break;
    case "speed":  image_index = 1; break;
    case "shield": image_index = 2; break; // Frame del escudo
    case "damage": image_index = 3; break; // Frame del daño x2
    case "ammo":   image_index = 4; break; // Frame de munición infinita
}
image_speed = 0; // Para que no se anime solo