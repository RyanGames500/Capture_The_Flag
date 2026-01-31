function host_spawn_ammo(_x, _y, _amount)
{
    if (!oBrain.AmIPseudoHost) exit;

    // 1. Crear localmente en el Host
    var a = instance_create_layer(_x, _y, "Instances", oAmmoPack);
    a.amount = _amount;
    a.taken = false;

    if (!variable_global_exists("next_ammo_uid")) global.next_ammo_uid = 1;
    a.net_uid = global.next_ammo_uid++;
    
    // 2. AVISO RADICAL AL CLIENTE
    if (instance_exists(oOtherPlayer))
    {
        // Forzamos que las coordenadas sean floored (enteros) para evitar desfases de decimales
        var _posX = floor(_x);
        var _posY = floor(_y);
        
        SendEventToClient(oOtherPlayer.clientId, "spawn_ammo_pack", {
            uid: a.net_uid,
            x: _posX,
            y: _posY,
            amount: _amount
        });
    }
}