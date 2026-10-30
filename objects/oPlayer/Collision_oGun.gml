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
    if (global.sfx) audio_play_sound(snd_ammo_pickup, 10, false);

    if (global.ONLINE)
    {
        var uid = other.net_uid;
        if (oBrain.AmIPseudoHost)
        {
            scr_release_spawn_point(other.x, other.y);
            instance_destroy(other);
            with(oOtherPlayer) { SendEventToClient(clientId, "weapon_pickup_taken", { uid: uid }); }
        }
        else
        {
            other.taken = true;
            other.visible = false; 
            
            var _hostID = scr_get_host_id();
            if (_hostID != -1) SendEventToClient(_hostID, "request_pickup_weapon", { uid: uid, mode:"stack" });
        }
        exit;
    }
    else
    {
        instance_destroy(other);
    }
}

// ====== 2) SWAP (REEMPLAZO SIN DEJAR ARMA EN EL SUELO) ======
// Quitamos la lógica que crea un drop. Simplemente borramos la vieja de la mano.

if (global.ONLINE && !oBrain.AmIPseudoHost)
{
    // Cliente solo informa al Host pero ya no manda el 'oldWeapon' para spawnearla
    guns[weapon.index] = other.weapon; // Reemplazo directo
    if (global.sfx) audio_play_sound(snd_ammo_pickup, 10, false);

    other.taken = true;
    other.visible = false;

    var _hostID = -1;
    with(oOtherPlayer) { if (variable_instance_exists(id, "isHost") && isHost) _hostID = clientId; }
    if (_hostID == -1 && instance_exists(oOtherPlayer)) _hostID = instance_find(oOtherPlayer, 0).clientId;

    if (_hostID != -1) {
        SendEventToClient(_hostID, "request_pickup_weapon", {
            uid: other.net_uid,
            mode: "swap", // El Host recibirá esto y solo destruirá el pickup
            dropX: x,
            dropY: y
            // No enviamos oldWeapon porque no queremos que se cree en el suelo
        });
    }
    instance_destroy(other);
    exit; // Importante para no ejecutar el código de abajo
}

// LÓGICA PARA HOST U OFFLINE (Reemplazo silencioso)
if (guns[weapon.index] != noone)
{
    // Antes aquí había un scr_drop_on_death o instance_create. 
    // Al dejar esto vacío, el arma vieja simplemente desaparece de la memoria.
}

// Equipar nueva
guns[weapon.index] = other.weapon;
if (global.sfx) audio_play_sound(snd_ammo_pickup, 10, false);

if (global.ONLINE)
{
    if (oBrain.AmIPseudoHost)
    {
        var uid2 = other.net_uid;
        scr_release_spawn_point(other.x, other.y);
        instance_destroy(other);
        // Avisar a todos que el pickup ya no existe
        with(oOtherPlayer) { SendEventToClient(clientId, "weapon_pickup_taken", { uid: uid2 }); }
    }
}
else
{
    instance_destroy(other);
}