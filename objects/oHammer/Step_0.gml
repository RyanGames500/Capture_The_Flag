

if (!ataca) {
    timer--;
    if (timer <= 0) {
        ataca = true;
        image_speed = 1; // Inicia la animación pro
    }
} else {
    // Si la animación llegó al final, lo detenemos arriba otra vez
    if (image_index >= image_number - 1) {
        image_index = 0;
        image_speed = 0;
		if(global.sfx) audio_play_sound(snd_hammer_hit,1,0);
		scrCamShake(3);
        ataca = false;
        timer = room_speed * random_range(1, 4); // Nueva espera aleatoria
    }
}

if (ataca) {
    if (image_index >= image_number - 1) {
        image_speed = 0;
        image_index = 0;
        ataca = false;
    }
}