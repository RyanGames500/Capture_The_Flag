// --- 1. DETECCIÓN DE BALAS (OFFLINE + BOT) ---

// Intentamos detectar tu bala
var _bullet = instance_place(x, y, oPlayer_bullet); 

// Si no encontró tu bala, intentamos detectar la del BOT (oEnemy_bullet)
if (_bullet == noone) {
    _bullet = instance_place(x, y, oEnemy_bullet);
}

if (_bullet != noone) {
    // Si la bala tiene daño, lo restamos; si no, quitamos 1 por defecto
    var _dmg = variable_instance_exists(_bullet, "damage") ? _bullet.damage : 1;
    hp -= _dmg;
    
    // Destruir la bala tras el impacto
    instance_destroy(_bullet);
}

// --- 2. LÓGICA DE EXPLOSIÓN ---
if (hp <= 0 && !exploded) {
    exploded = true;
    
    instance_create_layer(x, y, "Weapons", oExplosionFX);
    scrCamShake(10);
    if (global.sfx) audio_play_sound(sndMissileExplode, 10, false);

    var radius = variable_instance_exists(id, "radius_value") ? radius_value : 80;
    var dmg_to_apply = variable_instance_exists(id, "mi_danio") ? mi_danio : 50;
    
    // A. Daño al Jugador
    if (instance_exists(oPlayer_offline)) {
        if (point_distance(x, y, oPlayer_offline.x, oPlayer_offline.y) < radius) {
            health -= dmg_to_apply; 
        }
    }
    
    // B. Daño a Enemigos/Bots (IMPORTANTE: Cambié oEnemy_Parent por oPlayer2_local)
    if (instance_exists(oPlayer2_local)) { 
        with(oPlayer2_local) {
            if (point_distance(other.x, other.y, x, y) < radius) {
                hp -= dmg_to_apply;
                // Si el barril le quita mucha vida, el bot entrará en modo huida automáticamente
            }
        }
    }

    instance_destroy(); 
}