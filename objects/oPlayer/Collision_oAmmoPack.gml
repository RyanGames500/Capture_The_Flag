// other = oAmmoPack
// other = oAmmoPack
if (id != oPlayer.id) exit; 
if (other.taken || !other.visible) exit;

// --- 1. CAPTURAR DATOS DE FORMA SEGURA (Antes de que el objeto muera) ---
var _otherID = other.id;
var _uid     = other.net_uid;
var _amt     = other.amount;
var _posX    = other.x;
var _posY    = other.y;
var esPackDeGranadas = (variable_instance_exists(_otherID, "is_grenade_pack")) ? _otherID.is_grenade_pack : false;

// --- 2. LÓGICA DE RECOGIDA ---
if (esPackDeGranadas) 
{
    other.taken = true;
    other.visible = false;
    
    granadas += 3; 
    var notif = instance_create_layer(x, y - 20, "Instances", oNotification);
    notif.text = "+3 GRANADAS";
    notif.color = c_orange;
    if (global.sfx) audio_play_sound(snd_ammo_pickup, 1, false);
} 
else 
{
    if (guns[weapon.index] == noone) exit;
    var w = guns[weapon.index];
    var t = w.ammoType;
    if (t == "" || is_undefined(t)) exit;

    var maxReserve = 999;
    switch (t) {
        case "gun":   maxReserve = 120; break;
        case "smg":   maxReserve = 240; break;
        case "escop": maxReserve = 180; break;
        case "shell": maxReserve = 40;  break;
    }

    var cur = (variable_struct_exists(reserve, t)) ? reserve[$ t] : 0;
    if (cur >= maxReserve) exit; 

    other.taken = true;
    other.visible = false;
    
    // Usamos la variable local _amt que guardamos arriba
    reserve[$ t] = min(cur + _amt, maxReserve);

    if (!reloading && guns[weapon.index].ammo <= 0) scrReloadWeapon(); 
    if (global.sfx) audio_play_sound(snd_ammo_pickup, 1, false);
}

// --- 3. SINCRONIZACIÓN ONLINE (Usando variables locales) ---
if (global.ONLINE)
{
    if (oBrain.AmIPseudoHost)
    {
        scr_release_spawn_point(_posX, _posY); // Usamos _posX/_posY locales
        if (instance_exists(_otherID)) instance_destroy(_otherID);
        
        with(oOtherPlayer) {
            SendEventToClient(clientId, "ammo_taken", { uid: _uid });
        }
    }
    else
    {
        if (instance_exists(_otherID)) instance_destroy(_otherID);
        
        var _hID = -1;
        with(oOtherPlayer) { 
            if (variable_instance_exists(id, "isHost") && isHost) _hID = clientId; 
        }
        if (_hID == -1 && instance_exists(oOtherPlayer)) _hID = instance_find(oOtherPlayer, 0).clientId;

        if (_hID != -1) {
            SendEventToClient(_hID, "request_ammo", { uid: _uid }); // Usamos _uid local
        }
    }
}
else
{
    if (instance_exists(_otherID)) instance_destroy(_otherID);
}

