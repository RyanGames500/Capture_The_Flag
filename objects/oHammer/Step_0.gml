
if (crush_cd > 0) crush_cd--;


if (!ataca) {
    timer--;
    if (timer <= 0) {
        ataca = true;
        image_speed = 1; // Inicia la animación pro
		hit_this_swing = false;
    }
} else {
    // Si la animación llegó al final, lo detenemos arriba otra vez
    if (image_index >= image_number - 1) {
        image_index = 0;
        image_speed = 0;
        ataca = false;
        timer = room_speed * random_range(1, 4); // Nueva espera aleatoria
    }
}

if (ataca) {
    if (image_index >= image_number - 1) {
        image_speed = 0;
        image_index = 0;
		if(global.sfx) audio_play_sound(snd_hammer_hit,1,0);
		scrCamShake(3);
        ataca = false;
    }
}

// SOLO el host evalúa daño
if (!global.ONLINE || oBrain.AmIPseudoHost)
{
    var f = floor(image_index);
    var golpeando = (ataca && f >= 2 && f <= 4);

    // ✅ solo una vez por swing
    if (golpeando && !hit_this_swing)
    {
        // ===== PLAYER LOCAL (HOST) =====
        if (instance_exists(oPlayer))
        {
            if (place_meeting(x, y, oPlayer) && !oPlayer.isDead)
            {
                hit_this_swing = true; // ✅ latch

				with (oPlayer) {
				    // para que tu lógica de muerte muestre "aplastado"
				    death_reason = "crush";
				    last_killer = "";
				    health = 0;
				}

 
            }
        }

        // ===== PLAYER REMOTO (TÍTERE) =====
        if (global.ONLINE && !hit_this_swing && instance_exists(oOtherPlayer))
        {
            if (place_meeting(x, y, oOtherPlayer))
            {
                hit_this_swing = true; // ✅ latch

                //SendEventToClient(oOtherPlayer.clientId, "hit", { damage: 9999 });

				SendEventToClient(oOtherPlayer.clientId, "hit", {
				    damage: 9999,
				    killer: "",
				    reason: "crush"
				});


            }
        }
    }
}
