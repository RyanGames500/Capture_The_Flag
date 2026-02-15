function host_spawn_ammo(_x, _y, _amount)
{
    if (!oBrain.AmIPseudoHost) return noone;

    var a = instance_create_layer(_x, _y, "Instances", oAmmoPack);
    a.amount = _amount;
    a.taken = false;

    // --- NUEVO: Decidir si es granada ---
    // 25% de probabilidad (random(100) < 25)
    var esGranada = (random(100) < 25); 
    a.is_grenade_pack = esGranada;

    if (esGranada) {
        a.sprite_index = spr_pack_granadas; // Asegúrate que este sprite exista
    }

    if (!variable_global_exists("next_ammo_uid")) global.next_ammo_uid = 10000;
    a.net_uid = global.next_ammo_uid++;
    
    // DIFUSIÓN: Mandar a todos incluyendo la nueva variable "is_grenade"
    with(oOtherPlayer) {
        SendEventToClient(clientId, "spawn_ammo_pack", {
            uid: a.net_uid,
            x: _x,
            y: _y,
            amount: _amount,
            is_grenade: esGranada // <--- TRANSMITIMOS LA DECISIÓN
        });
    }

    return a; 
}
