function host_spawn_ammo(_x, _y, _amount)
{
    if (!oBrain.AmIPseudoHost) return noone;

    var a = instance_create_layer(_x, _y, "Instances", oAmmoPack);
    a.amount = _amount;
    a.taken = false;

    if (!variable_global_exists("next_ammo_uid")) global.next_ammo_uid = 10000; // Rango distinto para ammo
    a.net_uid = global.next_ammo_uid++;
    
    // 🔥 DIFUSIÓN: Avisar a TODOS los clientes (para los 4 jugadores)
    with(oOtherPlayer) {
        SendEventToClient(clientId, "spawn_ammo_pack", {
            uid: a.net_uid,
            x: _x,
            y: _y,
            amount: _amount
        });
    }

    // 🔥 EL FIX MAESTRO: Retornar la instancia
    return a; 
}
