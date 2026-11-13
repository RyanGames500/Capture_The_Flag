hp = 100;
mi_danio = 60;        // barril rojo: fuerte
radius_value = 130;   // y llega lejos
exploded = false;

// Barriles al doble de tamano (una sola vez: el chico llama a este Create dos veces).
// El dibujo empieza arriba a la izquierda, asi que lo subimos para que siga parado en el piso.
if (!variable_instance_exists(id, "barril_grande")) {
	barril_grande = true;
	var _w = sprite_width, _h = sprite_height;
	image_xscale *= 2;
	image_yscale *= 2;
	x -= _w / 2;
	y -= _h;
}
