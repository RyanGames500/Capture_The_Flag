
var _xArma = round(other.x); 
var _yArma = round(other.y);

	for (var i=0;i<1;i++) {
		if (guns[i] != noone && guns[i].object == other.weapon.object) {
			var remaining = guns[i].ammo + other.weapon.ammo - other.weapon.maxAmmo;
			
			guns[i].ammo += other.weapon.ammo;
			guns[i].ammo = min(guns[i].ammo, guns[i].maxAmmo);
			
			if (remaining > 0) {
				other.weapon.ammo = remaining;
			} else {
				instance_destroy(other);
			}
			
			exit;
		}
	}
	
	if (guns[weapon.index] != noone) {
		var gun = instance_create_layer(x,y,"Weapons",guns[weapon.index].object);
		gun.weapon = guns[weapon.index];
	}
	
	guns[weapon.index] = other.weapon;

if (instance_exists(oOtherPlayer)) {
    with(oOtherPlayer) {
        var pickData = {
            _x: _xArma,
            _y: _yArma
        };
        SendEventToClient(id.clientId, "weapon_picked", pickData);
    }
}
instance_destroy(other);
