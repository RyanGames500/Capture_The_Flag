// Si las balas le dan
var _bullet = instance_place(x, y, oMyEntity); // Ajusta al nombre de tu bala
if (_bullet != noone) {
    hp -= _bullet.damage;
    instance_destroy(_bullet);
}

// EXPLOSIÓN
if (hp <= 0 && !exploded) {
    exploded = true;
    
    // 1. Efecto Visual Local
    instance_create_layer(x, y, "Weapons", oExplosionFX);
    scrCamShake(10);
    if (global.sfx) audio_play_sound(sndMissileExplode, 10, false);

// 2. AVISAR A LOS DEMÁS PARA QUE BORREN EL BARRIL
    if (global.ONLINE) {
        var barrelData = { bx: x, by: y }; // Mandamos su posición exacta para identificarlo
        
            SendEventToClient(oOtherPlayer.clientId, "barrel_dead", barrelData);
         
    }

    // 3. DAÑO EN ÁREA (Solo el Host calcula el daño para evitar trampas)
        var radius = 80;
        
        // Daño al Player Local
        if (point_distance(x, y, oOtherPlayer.x, oOtherPlayer.y) < radius) {
            health -= 50; 
        }
        
        // Daño al Otro Player
        if (instance_exists(oOtherPlayer)) {
            if (point_distance(x, y, oOtherPlayer.x, oOtherPlayer.y) < radius) {
                if (global.ONLINE) {
                    SendEventToClient(oOtherPlayer.clientId, "hit", {
                        damage: 50,
                        killer: "Barril",
                        reason: "explosion"
                    });
                }
            }
        }
    

    instance_destroy(); // El barril desaparece
}