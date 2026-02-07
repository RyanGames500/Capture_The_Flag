function scr_apply_powerup(_tipo, _amount) {
    switch(_tipo) {
        case "salud":
            health = min(health + _amount, 100);
            //if (global.sfx) audio_play_sound(snd_heal, 10, false); // Pon tu sonido
        break;
        
        case "velocidad":
            oPlayer.walksp = 8; // Tu variable de velocidad (ajusta el nombre si es walkSpeed)
            oPlayer.alarm[0] = 300; // 5 segundos
            //if (global.sfx) audio_play_sound(snd_speed, 10, false); // Pon tu sonido
        break;
    }
}