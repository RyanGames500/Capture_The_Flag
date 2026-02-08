function scr_host_spawn_powerup(_x, _y, _tipo, _spawnID)
{
    if (!oBrain.AmIPseudoHost) exit;

    var p = instance_create_layer(_x, _y, "Weapons", oPowerupPickup);
    p.tipo = _tipo;
    p.spawn_id = _spawnID;

    if (_tipo == "speed") {
        p.duration = room_speed * 5; // 5 segundos
    }

    if (!variable_global_exists("next_power_uid"))
        global.next_power_uid = 20000;

    p.net_uid = global.next_power_uid++;

    // avisar al cliente
    if (instance_exists(oOtherPlayer)) {
		SendEventToClient(oOtherPlayer.clientId, "spawn_powerup", {
		    uid: p.net_uid,
		    x: _x,
		    y: _y,
		    tipo: _tipo,
		    duration: p.duration,
		    amount: p.amount,
		    spawnID: _spawnID
		});

    }
}

