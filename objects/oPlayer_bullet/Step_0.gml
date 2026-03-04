// ======================================================
// ⏳ VIDA ÚTIL
// ======================================================
if (life > 0) {
    life--;
    if (life <= 0) {
        instance_destroy();
    }
}

if (is_rocket)
{
    if (irandom(2) == 0)
    {
        var sm = instance_create_layer(x, y, "Instances", oSmokeTrail);
        sm.color = c_gray;
    }
    image_angle = direction;
}



// 1. Chocar con paredes
if (place_meeting(x, y, obj_wall)  and !is_rocket) 
{
    instance_destroy();
}
else if (place_meeting(x, y, obj_wall)  and is_rocket) 
{
    instance_create_layer(x, y, "Instances", oExplosionFX); // Tu objeto de explosión
	scrCamShake(11);
    instance_destroy();
}

// 2. Chocar con el Jugador (oPlayer2_local)
var bot = instance_place(x, y, oPlayer2_local);

if (bot != noone) 
{
    // Solo si son de equipos distintos
    if (bot.team != team) 
	{ 
        
        // --- 🛡️ LOGICA DE ESCUDO (JUGADOR) ---
        if (bot.has_shield) {
            // Efecto visual de chispas en tu escudo
            instance_create_layer(x, y, "Instances", oShieldSparkFX);
            
            // Sonido de rebote metálico
            if (global.sfx) audio_play_sound(snd_shield_impact, 20, false, 2.0);
            
            instance_destroy();
            exit; // Salimos para no recibir daño
        }

        // --- 🩸 APLICAR DAÑO AL JUGADOR (Si no tiene escudo) ---
        if (!bot.invulnerable and !is_rocket) 
		{
            with(bot) {
                // Solo si no está muerto ya (usando tu lógica de estados)
                if (state != PLAYER2.DEAD) 
				{
                    
                    hp -= other.damage; // Bajamos vida al jugador
                    
                    // Feedback visual
                    image_blend = c_red;
                    alarm[3] = 5; 
                    
                    // Sonido de impacto
                    if (global.sfx) audio_play_sound(snd_hit, 10, false);
                }
            }
            instance_destroy();
        }
		else if (!bot.invulnerable and is_rocket) 
		{
            with(bot) {
                // Solo si no está muerto ya (usando tu lógica de estados)
                if (state != PLAYER2.DEAD) 
				{
                    
                    hp -= other.damage_rocket; // Bajamos vida al jugador
                    
                    // Feedback visual
                    image_blend = c_red;
                    alarm[3] = 5; 
                    
                    // Sonido de impacto
                    if (global.sfx) audio_play_sound(snd_hit, 10, false);
                }
            }
		    instance_create_layer(x, y, "Instances", oExplosionFX); // Tu objeto de explosión
			scrCamShake(11);
		    instance_destroy();
			
        }

    }
}