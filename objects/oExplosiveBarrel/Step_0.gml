// --- DETECCIÓN DE BALAS ---
var _bullet = instance_place(x, y, oMyEntity); 
if (_bullet != noone) {
    hp -= _bullet.damage;
    instance_destroy(_bullet);
}

// --- EXPLOSIÓN ---
if (hp <= 0 && !exploded) {
    exploded = true;
    
    // 1. Efecto Visual Local
    instance_create_layer(x, y, "Weapons", oExplosionFX);
    scrCamShake(10);
    if (global.sfx) audio_play_sound(sndMissileExplode, 10, false);

    // 2. AVISAR A TODOS LOS DEMÁS
    if (global.ONLINE) {
        var barrelData = { bx: x, by: y }; 
        with(oOtherPlayer) {
            SendEventToClient(clientId, "barrel_dead", barrelData);
        }
    }

    // 3. DAÑO EN ÁREA
    // Definimos las variables AQUÍ para que el barril las use
    var radius = variable_instance_exists(id, "radius_value") ? radius_value : 80;
    var dmg_to_apply = variable_instance_exists(id, "mi_danio") ? mi_danio : 50; // Sin el "other"
    
    // Daño a MÍ (El jugador local)
    if (point_distance(x, y, oPlayer.x, oPlayer.y) < radius) {
        with(oPlayer) { // Entramos al player para restar salud
            health -= dmg_to_apply;
        }
    }
    
    // Daño a los DEMÁS (Clientes remotos)
    if (global.ONLINE) {
        // Guardamos la posición del barril en variables locales 
        // para que los oOtherPlayer puedan leerlas dentro del with
        var _bx = x;
        var _by = y;

        with(oOtherPlayer) {
            if (point_distance(_bx, _by, x, y) < radius) {
                SendEventToClient(clientId, "hit", {
                    damage: dmg_to_apply,
                    killer: "Barril",
                    reason: "explosion"
                });
            }
        }
    }

    instance_destroy(); 
}