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







if (other.taken) exit;
if (guns[weapon.index] == noone) exit;

var w = guns[weapon.index];
var t = w.ammoType;
if (t == "" || is_undefined(t)) exit;

var maxReserve = 999;
switch (t) {
    case "gun":    maxReserve = 120; break;
    case "smg":    maxReserve = 240; break;
    case "escop":  maxReserve = 180; break;
    case "shell":  maxReserve = 40;  break;
}

var cur = 0;
if (variable_struct_exists(reserve, t)) cur = reserve[$ t];

var can_take_ammo = (cur < maxReserve);
var can_take_nades = (granadas < 5);

if (!can_take_ammo && !can_take_nades) exit;

other.taken = true;
other.visible = false;

if (global.ONLINE) {
    if (oBrain.AmIPseudoHost) {
        var uid = other.net_uid;
        scr_release_spawn_point(other.x, other.y); 
        instance_destroy(other);
        with(oOtherPlayer) { SendEventToClient(clientId, "ammo_taken", { uid: uid }); }
    } else {
        var _targetHost = -1;
        with(oOtherPlayer) { if (variable_instance_exists(id, "isHost") && isHost) _targetHost = clientId; }
        if (_targetHost == -1 && instance_exists(oOtherPlayer)) { _targetHost = instance_find(oOtherPlayer, 0).clientId; }
        
        if (_targetHost != -1) SendEventToClient(_targetHost, "request_ammo", { uid: other.net_uid });
        instance_destroy(other);
    }
} else { instance_destroy(other); }