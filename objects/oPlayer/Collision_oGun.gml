// other = oGun pickup
if (other.no_pickup_timer > 0) exit;
if (global.ONLINE && other.taken) exit;

// ====== DIFERENCIAR SI ES LA MISMA ======
var same_weapon = (guns[weapon.index] != noone)
                && is_struct(other.weapon)
                && (string(guns[weapon.index].type2) == string(other.weapon.type2));

// ====== 1) STACK si es la misma arma ======
if (same_weapon)
{
    if (guns[weapon.index].ammo > 0) exit;

    guns[weapon.index].ammo = min(guns[weapon.index].ammo + other.weapon.ammo, guns[weapon.index].maxAmmo);
    if (global.sfx) audio_play_sound(snd_ammo_pickup, 10, false); // <--- SONIDO AQUÍ

    if (global.ONLINE)
    {
        var uid = other.net_uid;
        if (oBrain.AmIPseudoHost)
        {
            scr_release_spawn_point(other.x, other.y);
            instance_destroy(other);
            // BROADCAST a todos los demás clientes
            with(oOtherPlayer) { SendEventToClient(clientId, "weapon_pickup_taken", { uid: uid }); }
        }
        else
        {
            other.taken = true;
            other.visible = false; 
            
            // --- BUSCAR AL HOST ENTRE LOS DEMÁS ---
            var _hostID = -1;
            with(oOtherPlayer) { if (variable_instance_exists(id, "isHost") && isHost) _hostID = clientId; }
            if (_hostID == -1 && instance_exists(oOtherPlayer)) _hostID = instance_find(oOtherPlayer, 0).clientId;

            if (_hostID != -1) SendEventToClient(_hostID, "request_pickup_weapon", { uid: uid, mode:"stack" });
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
    var oldWeapon = guns[weapon.index];
    guns[weapon.index] = other.weapon;
    if (global.sfx) audio_play_sound(snd_ammo_pickup, 10, false); // <--- SONIDO AQUÍ

    other.taken = true;
    other.visible = false;

    // --- BUSCAR AL HOST PARA PEDIR EL SWAP ---
    var _hostID = -1;
    with(oOtherPlayer) { if (variable_instance_exists(id, "isHost") && isHost) _hostID = clientId; }
    if (_hostID == -1 && instance_exists(oOtherPlayer)) _hostID = instance_find(oOtherPlayer, 0).clientId;

    if (_hostID != -1) {
        SendEventToClient(_hostID, "request_pickup_weapon", {
            uid: other.net_uid,
            mode: "swap",
            dropX: x,
            dropY: y,
            oldWeapon: oldWeapon
        });
    }
    
    instance_destroy(other); // Destruir localmente para que sea instantáneo
    exit;
}

// HOST (o offline): el host hace el swap completo y dropea
if (guns[weapon.index] != noone)
{
    if (global.ONLINE && oBrain.AmIPseudoHost)
    {
        var dx = 24 * sign(image_xscale);
        var dy = 0;
        scr_drop_on_death(guns[weapon.index], x + dx, y + dy); // Usamos tu script de drop
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

// Equipar nueva y sonido
guns[weapon.index] = other.weapon;
if (global.sfx) audio_play_sound(snd_ammo_pickup, 10, false);

if (global.ONLINE)
{
    if (oBrain.AmIPseudoHost)
    {
        var uid2 = other.net_uid;
        scr_release_spawn_point(other.x, other.y);
        instance_destroy(other);
        // BROADCAST a todos
        with(oOtherPlayer) { SendEventToClient(clientId, "weapon_pickup_taken", { uid: uid2 }); }
    }
}
else
{
    instance_destroy(other);
}