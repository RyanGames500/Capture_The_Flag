function scr_apply_powerup(_tipo, _amount) {
    switch(_tipo) {
        case "salud":
            oPlayer.health = min(oPlayer.health + _amount, 100);
            if (global.sfx) audio_play_sound(snd_heal, 10, false);
        break;
        
        case "velocidad":
            oPlayer.walkSpeed = 8; // Aumenta su velocidad base
            oPlayer.alarm[0] = 300; // Alarma para quitar el efecto en 5 segundos
            //if (global.sfx) audio_play_sound(snd_speed, 10, false);
        break;
    }
}