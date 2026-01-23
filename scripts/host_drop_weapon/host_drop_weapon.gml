function host_drop_weapon(_weaponStruct, _x, _y)
{
    if (!oBrain.AmIPseudoHost) exit;

    var d = instance_create_layer(_x, _y, "Instances", oGun);
    d.weapon = _weaponStruct;
    d.sprite_index = d.weapon.sprite;
	d.no_pickup_timer = 15;

    if (!variable_global_exists("next_weapon_uid")) global.next_weapon_uid = 1;
    d.net_uid = global.next_weapon_uid++;
    d.taken = false;

    if (instance_exists(oOtherPlayer)) {
        SendEventToClient(oOtherPlayer.clientId, "spawn_weapon_pickup", {
            uid: d.net_uid,
            x: _x,
            y: _y,
            weapon: _weaponStruct
        });
    }
}

