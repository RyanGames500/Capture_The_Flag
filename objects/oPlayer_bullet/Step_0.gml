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
// 🎯 COLISIÓN BALA LOCAL (PARA EL BOT)
// ======================================================

// 1. Chocar con paredes
if (place_meeting(x, y, obj_wall)) {
    instance_destroy();
}

// 2. Chocar con el Bot (oPlayer2_local)
var bot = instance_place(x, y, oPlayer2_local);

if (bot != noone) {
    // Solo si son de equipos distintos
    if (bot.team != team) { 
        
        // --- 🛡️ LOGICA DE ESCUDO ---
        if (bot.has_shield) {
            // Efecto visual de chispas en el escudo
            instance_create_layer(x, y, "Instances", oShieldSparkFX);
            
            // Sonido metálico de escudo
            if (global.sfx) audio_play_sound(snd_shield_impact, 20, false, 2.0);
            
            // Destruimos la bala y salimos (exit) para que no ejecute el daño de abajo
            instance_destroy();
            exit; 
        }

        // --- 🩸 APLICAR DAÑO (Si no tiene escudo) ---
// --- 🩸 APLICAR DAÑO ---
if (!bot.invulnerable) {
    with(bot) {
        if (state != PLAYER2.DEAD) {
            hp -= other.damage; 
            
            // ACTIVAMOS EL SISTEMA DE GOLPE
            hit = true;
            hit_time = 3; // Aumentamos a 8 para que se vea mejor
            image_blend = c_red; 
            
            if (global.sfx) audio_play_sound(snd_hit, 10, false);
        }
    }
    instance_destroy();
}
    }
}