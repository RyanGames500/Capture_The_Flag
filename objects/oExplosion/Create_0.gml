scrCamShake(4);
if (global.sfx) audio_play_sound(snd_pearl_explodes, 1, false);

// Daño en área al crear la explosión
with(oOtherPlayer) {
    if (distance_to_object(other) < 64) {
        // Mandar evento de daño
        enemyHealth -= 40; 
    }
}