//if (other.taken) exit;
//if (guns[weapon.index] == noone) exit;



//other.taken = true;
//other.visible = false;

//if (can_take_ammo) {
//    var add = other.amount;
//    reserve[$ t] = min(cur + add, maxReserve);
//    if (global.sfx) audio_play_sound(snd_ammo_pickup, 1, false);
//}

//if (can_take_nades) {
//    if (random(100) < 30) granadas += 1;
//}

//if (!reloading && w.ammo <= 0) scrReloadWeapon();

//// --- NETWORKING ---
//if (global.ONLINE) {
//    var uid = other.net_uid;
//    if (oBrain.AmIPseudoHost) {
//        // Host la agarra: Avisa a todos
//        scr_release_spawn_point(other.x, other.y); 
//        instance_destroy(other);
//        with(oOtherPlayer) { SendEventToClient(clientId, "ammo_taken", { uid: uid }); }
//    } else {
//        // Cliente la agarra: Pide permiso al Host
//        var hostID = -1;
//        with(oOtherPlayer) { if (isHost) hostID = clientId; } 
//        if (hostID != -1) SendEventToClient(hostID, "request_ammo", { uid: uid });
//        instance_destroy(other);
//    }
//} else {
//    instance_destroy(other);
//}







// other = oAmmoPack
if (id != oPlayer.id) exit; // Solo el jugador local procesa esto
if (other.taken || !other.visible) exit;

// 1) Debes tener arma equipada
if (guns[weapon.index] == noone) exit;

// 2) Tipo de ammo según arma equipada
var w = guns[weapon.index];
var t = w.ammoType;
if (t == "" || is_undefined(t)) exit;

// 3) LÍMITES de reserva
var maxReserve = 999;
switch (t) {
    case "gun":   maxReserve = 120; break;
    case "smg":   maxReserve = 240; break;
    case "escop": maxReserve = 180; break;
    case "shell": maxReserve = 40;  break;
}

var cur = 0;
if (variable_struct_exists(reserve, t)) cur = reserve[$ t];

// Si ya estás full, no lo toma
if (cur >= maxReserve) exit;

// 4) RECOGER (Lógica local inmediata)
other.taken = true;
other.visible = false;

var add = other.amount;
reserve[$ t] = min(cur + add, maxReserve);

// --- AUTO-RECARGA ---
// Si tienes el cargador vacío, activa el script de recarga automáticamente
if (!reloading && guns[weapon.index].ammo <= 0)
{
    scrReloadWeapon(); 
}

if (global.sfx) audio_play_sound(snd_ammo_pickup, 1, false);

// 5) SINCRONIZACIÓN ONLINE
var uid = other.net_uid;

if (global.ONLINE)
{
    if (oBrain.AmIPseudoHost)
    {
        // El Host libera el spawn y destruye el objeto
        scr_release_spawn_point(other.x, other.y);
        instance_destroy(other);

        // 🔥 BROADCAST: Avisar a TODOS los clientes que borren esta munición
        with(oOtherPlayer) {
            SendEventToClient(clientId, "ammo_taken", { uid: uid });
        }
    }
    else
    {
        // El Cliente la borra de su vista
        instance_destroy(other);

        // --- BUSCAR AL HOST PARA INFORMAR ---
        var _hID = -1;
        with(oOtherPlayer) { if (variable_instance_exists(id, "isHost") && isHost) _hID = clientId; }
        if (_hID == -1 && instance_exists(oOtherPlayer)) _hID = instance_find(oOtherPlayer, 0).clientId;

        if (_hID != -1) {
            SendEventToClient(_hID, "request_ammo", { uid: uid });
        }
    }
}
else
{
    instance_destroy(other);
}