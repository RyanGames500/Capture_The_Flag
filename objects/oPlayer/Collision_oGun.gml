// other = oGun pickup (el objeto en el suelo)

// 0) Validaciones iniciales
if (other.no_pickup_timer > 0) exit;
if (global.ONLINE && (other.taken || !other.visible)) exit;

var same_weapon = (guns[weapon.index] != noone)
                && is_struct(other.weapon)
                && (string(guns[weapon.index].type2) == string(other.weapon.type2));

// ====== 1) STACK (Misma arma) ======
if (same_weapon) {
    if (guns[weapon.index].ammo > 0) exit; 

    guns[weapon.index].ammo = min(guns[weapon.index].ammo + other.weapon.ammo, guns[weapon.index].maxAmmo);

    if (global.ONLINE) {
        var uid = other.net_uid;
        if (oBrain.AmIPseudoHost) {
            scr_release_spawn_point(other.x, other.y);
            instance_destroy(other);
            // --- BROADCAST A TODOS ---
            with(oOtherPlayer) { SendEventToClient(clientId, "weapon_pickup_taken", { uid: uid }); }
        } else {
            other.taken = true;
            other.visible = false;
            // --- BUSCAR AL HOST ---
            var _hostID = -1;
            with(oOtherPlayer) { if (variable_instance_exists(id, "isHost") && isHost) _hostID = clientId; }
            if (_hostID == -1 && instance_exists(oOtherPlayer)) _hostID = instance_find(oOtherPlayer, 0).clientId;
            
            if (_hostID != -1) SendEventToClient(_hostID, "request_pickup_weapon", { uid: uid, mode: "stack" });
        }
    } else {
        instance_destroy(other);
    }
    exit;
}

// ====== 2) SWAP (Arma diferente) ======
if (global.ONLINE) {
    var uid2 = other.net_uid;
    if (!oBrain.AmIPseudoHost) {
        // --- CLIENTE ---
        guns[weapon.index] = other.weapon; 
        other.taken = true;
        other.visible = false;

        // --- BUSCAR AL HOST PARA PEDIR EL SWAP ---
        var _hostID = -1;
        with(oOtherPlayer) { if (variable_instance_exists(id, "isHost") && isHost) _hostID = clientId; }
        if (_hostID == -1 && instance_exists(oOtherPlayer)) _hostID = instance_find(oOtherPlayer, 0).clientId;

        if (_hostID != -1) {
            SendEventToClient(_hostID, "request_pickup_weapon", { uid: uid2, mode: "swap" });
        }
        instance_destroy(other); 
    } else {
        // --- HOST ---
        guns[weapon.index] = other.weapon; 
        scr_release_spawn_point(other.x, other.y);
        instance_destroy(other);
        
        // --- BROADCAST A TODOS LOS CLIENTES ---
        with(oOtherPlayer) {
            SendEventToClient(clientId, "weapon_pickup_taken", { uid: uid2 });
        }
    }
} else {
    guns[weapon.index] = other.weapon;
    instance_destroy(other);
}