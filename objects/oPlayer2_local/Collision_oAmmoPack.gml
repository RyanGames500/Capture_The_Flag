// other = oAmmoPack
if (other.taken || !other.visible) exit;

// --- 1. CAPTURAR DATOS ---
var _otherID = other.id;
var _amt     = other.amount;
var esPackDeGranadas = (variable_instance_exists(_otherID, "is_grenade_pack")) ? _otherID.is_grenade_pack : false;

// --- 2. LÓGICA DE RECOGIDA ---
if (esPackDeGranadas) 
{
    other.taken = true;
    
    granadas += 3; 
    
    // Notificación visual
    var notif = instance_create_layer(x, y - 20, "Instances", oNotification);
    notif.text = "+3 GRANADAS";
    notif.color = c_orange;
    
    if (global.sfx) audio_play_sound(snd_ammo_pickup, 1, false);
    instance_destroy(_otherID);
} 
else 
{
    // Si no tienes arma en mano, no puedes recoger balas de reserva
    if (guns[weapon.index] == noone) exit;
    
    var w = guns[weapon.index];
    var t = w.ammoType;
    if (t == "" || is_undefined(t)) exit;

    // Límites de reserva
    var maxReserve = 999;
    switch (t) {
        case "gun":   maxReserve = 120; break;
        case "smg":   maxReserve = 240; break;
        case "escop": maxReserve = 180; break;
        case "shell": maxReserve = 40;  break;
    }

    // Revisar cuánto tenemos en la reserva (el struct 'reserve')
    var cur = (variable_struct_exists(reserve, t)) ? reserve[$ t] : 0;
    
    // Si ya estamos llenos, no recogemos el pack
    if (cur >= maxReserve) exit; 

    other.taken = true;
    
    // Sumar a la reserva
    reserve[$ t] = min(cur + _amt, maxReserve);

    // Si el arma estaba vacía y no estamos recargando, forzar recarga automática
    if (!reloading && guns[weapon.index].ammo <= 0) {
        scrReloadWeapon(); 
    }

    if (global.sfx) audio_play_sound(snd_ammo_pickup, 1, false);
    
    // --- 3. LIMPIEZA OFFLINE ---
    // Si el pack viene de un spawn point local, lo liberamos
    if (variable_instance_exists(_otherID, "spawn_id")) {
        var _sid = _otherID.spawn_id;
        with(oSpawnPoint) { if (myID == _sid) { ocupado = false; cooldown = 300; } }
    }
    
    instance_destroy(_otherID);
}

// Dentro de la colisión del player con el item:
if (variable_instance_exists(other, "spawn_id") && instance_exists(other.spawn_id)) {
    other.spawn_id.ocupado = false;
    other.spawn_id.timer = other.spawn_id.cooldown_max;
}
instance_destroy(other);