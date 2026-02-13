function scr_host_spawn_powerup(_x, _y, _tipo, _spawnID)
{
    if (!oBrain.AmIPseudoHost) return noone; // Usamos return para evitar errores

    var p = instance_create_layer(_x, _y, "Weapons", oPowerupPickup);
    p.tipo = _tipo;
    p.spawn_id = _spawnID;
    
    // Inicializar amount para evitar errores de "variable no definida"
    p.amount = (_tipo == "heal") ? 25 : 0; 

    if (_tipo == "speed") {
        p.duration = 300; // 5 segundos (suponiendo 60fps)
    } else {
        p.duration = 0;
    }

    if (!variable_global_exists("next_power_uid"))
        global.next_power_uid = 20000;

    p.net_uid = global.next_power_uid++;

    // 🔥 IMPORTANTE: Avisar a TODOS los jugadores, no solo a uno
    with(oOtherPlayer) {
        SendEventToClient(clientId, "spawn_powerup", {
            uid: p.net_uid,
            x: _x,
            y: _y,
            tipo: _tipo,
            duration: p.duration,
            amount: p.amount,
            spawnID: _spawnID
        });
    }

    // 🔥 EL FIX MAESTRO: Devolver la instancia al oBrain
    return p; 
}

