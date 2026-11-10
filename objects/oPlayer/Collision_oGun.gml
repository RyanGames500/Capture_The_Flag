// other = oGun pickup
if (other.no_pickup_timer > 0) exit;
if (global.ONLINE && other.taken) exit;

// ====== DIFERENCIAR SI ES LA MISMA ======
// Con 2 armas: busca la misma en cualquiera de tus dos lugares (scr_armas, SEGUNDA ARMA)
var _sm = scr_slot_misma(other.weapon);
var same_weapon = (_sm != -1);

// ====== 1) STACK si es la misma arma ======
if (same_weapon)
{
    if (guns[_sm].ammo > 0) exit;

    guns[_sm].ammo = min(guns[_sm].ammo + other.weapon.ammo, guns[_sm].maxAmmo);
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
    // Si tienes un lugar vacio entra ahi y te la pones en la mano (scr_armas, SEGUNDA ARMA)
    var _sl = scr_slot_para_nueva();
    if (_sl != weapon.index) { weapon.index = _sl; reloading = false; reload_timer = 0; }
    guns[weapon.index] = other.weapon; // Reemplazo directo
    if (global.sfx) audio_play_sound(snd_ammo_pickup, 10, false);

    other.taken = true;
    other.visible = false;

    // El host que dice el servidor (antes podia tomar al primer oOtherPlayer, y ahora ese puede ser un bot)
    var _hostID = scr_get_host_id();

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

// Equipar nueva (con 2 armas: en el lugar vacio y te la pones en la mano)
var _sl2 = scr_slot_para_nueva();
if (_sl2 != weapon.index) { weapon.index = _sl2; reloading = false; reload_timer = 0; }
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