function host_spawn_ammo(_x, _y, _amount)
{
    if (!oBrain.AmIPseudoHost) exit;

    var a = instance_create_layer(_x, _y, "Instances", oAmmoPack);
    a.amount = _amount;
    a.taken = false;

    if (!variable_global_exists("next_ammo_uid")) global.next_ammo_uid = 1;
    a.net_uid = global.next_ammo_uid++;
    
    // Si el cliente ya existe, le mandamos la orden
    if (instance_exists(oOtherPlayer))
    {
        SendEventToClient(oOtherPlayer.clientId, "spawn_ammo_pack", {
            uid: a.net_uid,
            x: floor(_x), // Enviamos la posición exacta que calculó el Host
            y: floor(_y),
            amount: _amount
        });
    }
}