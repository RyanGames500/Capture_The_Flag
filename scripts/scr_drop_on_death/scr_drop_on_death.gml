function scr_drop_on_death(_weapon_struct, _x, _y) {
    if (!oBrain.AmIPseudoHost) exit;
    if (!is_struct(_weapon_struct)) exit;
    
    // No dropear el arma básica (pistola) para no llenar el mapa de basura
    if (_weapon_struct.type2 == "pistol") exit; 

    var drop = instance_create_layer(_x, _y, "Instances", oGun);
    drop.weapon = _weapon_struct;
    drop.sprite_index = drop.weapon.sprite;
    drop.image_index  = drop.weapon.subimage;
    
    // Asignar un UID único
    if (!variable_global_exists("next_weapon_uid")) global.next_weapon_uid = 1;
    drop.net_uid = global.next_weapon_uid++;
    
    drop.taken = false;
    drop.no_pickup_timer = 40; // Evita que el mismo que murió la recoja al instante

	// ✅ ENVIAR A TODOS LOS CLIENTES CONECTADOS
    with(oOtherPlayer) {
        SendEventToClient(oOtherPlayer.clientId, "spawn_weapon_pickup", {
            uid: drop.net_uid,
            x: _x,
            y: _y,
            weapon: _weapon_struct,
            npt: 40
        });
    }
}