function host_spawn_weapon(_obj_weapon_pickup, _x, _y, _weaponStruct)
{
    if (!oBrain.AmIPseudoHost) exit;

    if (!variable_global_exists("next_weapon_uid")) global.next_weapon_uid = 1;
    var uid = global.next_weapon_uid++;
    
	
    var w = instance_create_depth(_x, _y, 1, _obj_weapon_pickup);
    w.net_uid = uid;
    w.weapon  = _weaponStruct;
	w.taken = false;
	w.sprite_index = w.weapon.sprite;



    // avisar al cliente
    if (instance_exists(oOtherPlayer)) {
        SendEventToClient(oOtherPlayer.clientId, "spawn_weapon_pickup", {
            uid: uid,
            obj: _obj_weapon_pickup,  // si tu engine no manda object_index bien, te doy otra forma
            x: _x,
            y: _y,
            weapon: _weaponStruct,
        });
    }
}
