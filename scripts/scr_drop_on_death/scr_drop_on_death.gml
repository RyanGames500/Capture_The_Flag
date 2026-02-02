function scr_drop_on_death(_weapon_struct, _x, _y) {
    if (!oBrain.AmIPseudoHost) exit;
    if (!is_struct(_weapon_struct)) exit;
 

    var drop = instance_create_layer(_x, _y, "Weapons", oGun);
    drop.weapon = _weapon_struct;
    drop.sprite_index = drop.weapon.sprite;
    drop.image_index  = drop.weapon.subimage;
    
    if (!variable_global_exists("next_weapon_uid")) global.next_weapon_uid = 10000;
    drop.net_uid = global.next_weapon_uid++;
    
    drop.taken = false;
    drop.no_pickup_timer = 40; 
	drop.vida_timer = 1800;

    // Avisar a todos los clientes (incluyendo al que murió para que vea su arma en el suelo)
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