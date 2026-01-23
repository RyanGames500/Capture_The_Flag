// other = oGun pickup
// si el arma está "caliente", nadie la puede recoger
if (other.no_pickup_timer > 0) exit;

// si ya fue reclamada por alguien en online
if (global.ONLINE && other.taken) exit;

// si ya fue reclamado, no hacemos nada
if (global.ONLINE && other.taken) exit;

// ====== DIFERENCIAR SI ES LA MISMA ======
var same_weapon = (guns[weapon.index] != noone)
               && is_struct(other.weapon)
               && (string(guns[weapon.index].type2) == string(other.weapon.type2));

// ====== 1) STACK si es la misma arma ======
if (same_weapon)
{
    // si ya tienes balas, NO recoges
    if (guns[weapon.index].ammo > 0) exit;

    // sumas ammo
    guns[weapon.index].ammo = min(guns[weapon.index].ammo + other.weapon.ammo, guns[weapon.index].maxAmmo);

    if (global.ONLINE)
    {
        if (oBrain.AmIPseudoHost)
        {
            var uid = other.net_uid;
            instance_destroy(other);
            if (instance_exists(oOtherPlayer)) SendEventToClient(oOtherPlayer.clientId, "weapon_pickup_taken", { uid: uid });
        }
        else
        {
            other.taken = true;
            SendEventToClient(oOtherPlayer.clientId, "request_pickup_weapon", { uid: other.net_uid, mode:"stack" });
        }
        exit;
    }
    else
    {
        instance_destroy(other);
        exit;
    }
}

// ====== 2) SWAP si es arma diferente ======
if (global.ONLINE && !oBrain.AmIPseudoHost)
{
    // CLIENTE: equipar local YA (para que se vea instantáneo)
    var oldWeapon = guns[weapon.index];     // puede ser noone
    guns[weapon.index] = other.weapon;

    // pedir al host: destruir pickup + dropear arma vieja
    other.taken = true;

    SendEventToClient(oOtherPlayer.clientId, "request_pickup_weapon", {
        uid: other.net_uid,
        mode: "swap",
        dropX: x,
        dropY: y,
        oldWeapon: oldWeapon
    });

    exit; // cliente NO destruye
}

// HOST (o offline): el host hace el swap completo y dropea
if (guns[weapon.index] != noone)
{
    // host deja arma anterior en el piso
    if (global.ONLINE && oBrain.AmIPseudoHost)
    {
        var dx = 24 * sign(image_xscale); // al frente
		var dy = 0;
		host_drop_weapon(guns[weapon.index], x + dx, y + dy);

    }
    else if (!global.ONLINE)
    {
        var drop = instance_create_layer(x, y, "Instances", oGun);
        drop.weapon = guns[weapon.index];
        drop.sprite_index = drop.weapon.sprite;
        drop.image_index  = drop.weapon.subimage;
        drop.taken = false;
    }
}

// equipar nueva
guns[weapon.index] = other.weapon;

// destruir pickup (host) o offline
if (global.ONLINE)
{
    if (oBrain.AmIPseudoHost)
    {
        var uid2 = other.net_uid;
        instance_destroy(other);
        if (instance_exists(oOtherPlayer)) SendEventToClient(oOtherPlayer.clientId, "weapon_pickup_taken", { uid: uid2 });
    }
}
else
{
    instance_destroy(other);
}
