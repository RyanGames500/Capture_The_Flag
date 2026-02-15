function scr_barrel_explode(_x, _y) {
    // 1. Efecto local (para el que ejecuta la función)
    instance_create_layer(_x, _y, "Weapons", oExplosionFX);
    scrCamShake(10);
    if (global.sfx) audio_play_sound(sndMissileExplode, 10, false);

    if (global.ONLINE && oBrain.AmIPseudoHost) {
        // 2. Avisar a TODOS los clientes que el barril explotó
        with(oOtherPlayer) {
            SendEventToClient(clientId, "barrel_explode", { bx: _x, by: _y });
        }

        // 3. Daño en área (El Host calcula para todos)
        var radius = 80;
        
        // Daño al Host mismo
        if (point_distance(_x, _y, oPlayer.x, oPlayer.y) < radius) {
            health -= 50;
        }

        // Daño a los Clientes
        with(oOtherPlayer) {
            if (point_distance(_x, _y, x, y) < radius) {
                SendEventToClient(clientId, "hit", {
                    damage: 50,
                    killer: "Barril",
                    reason: "explosion"
                });
            }
        }
    }
    
    // Destruir el barril que esté en esa posición
    var _inst = instance_position(_x, _y, oBarril);
    if (instance_exists(_inst)) instance_destroy(_inst);
}