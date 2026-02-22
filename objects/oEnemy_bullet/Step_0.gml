// ======================================================
// ⏳ VIDA ÚTIL
// ======================================================
if (life > 0) {
    life--;
    if (life <= 0) {
        instance_destroy();
    }
}

// ======================================================
// 🎯 COLISIÓN BALA LOCAL (HACIA EL JUGADOR)
// ======================================================

// 1. Chocar con paredes
if (place_meeting(x, y, obj_wall)) {
    instance_destroy();
}

// 2. Chocar con el Jugador (oPlayer_offline)
var bot = instance_place(x, y, oPlayer_offline);

if (bot != noone) {
    // Solo si son de equipos distintos
    if (bot.team != team) { 
        
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
        if (!bot.invulnerable) {
            with(bot) {
                // Solo si no está muerto ya (usando tu lógica de estados)
                if (state != PLAYER2.DEAD) {
                    
                    health -= other.damage; // Bajamos vida al jugador
                    
                    // Feedback visual
                    image_blend = c_red;
                    alarm[3] = 5; 
                    
                    // Sonido de impacto
                    if (global.sfx) audio_play_sound(snd_hit, 10, false);
                }
            }
            instance_destroy();
        }
    }
}