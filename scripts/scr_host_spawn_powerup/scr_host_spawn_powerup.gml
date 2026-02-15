function scr_host_spawn_powerup(_x, _y, _tipo, _spawnID)
{
    if (!oBrain.AmIPseudoHost) return noone;

    var p = instance_create_layer(_x, _y, "Instances", oPowerupPickup);
    p.tipo = _tipo;
    p.spawn_id = _spawnID;
    
    // Configuración según tipo
    p.amount = (_tipo == "heal") ? 25 : 0; 
    
    // Tiempos (600 frames = 10 segundos)
    if (_tipo == "speed")  p.duration = 400;
    else if (_tipo == "shield") p.duration = 600;
    else if (_tipo == "damage") p.duration = 600;
    else if (_tipo == "ammo")   p.duration = 600;
    else p.duration = 0; // Heal es instantáneo

    if (!variable_global_exists("next_power_uid"))
        global.next_power_uid = 20000;

    p.net_uid = global.next_power_uid++;

    // Avisar a TODOS
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

    return p; 
}
