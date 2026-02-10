// ======================================================
// 📦 COLISIÓN CON MUNICIÓN (oAmmoPack)
// ======================================================

// 0) si ya fue tomado, no hacer nada
if (other.taken) exit;

// 1) Debes tener arma equipada para poder tomar munición
if (guns[weapon.index] == noone) exit;

// 2) Tipo de ammo según arma equipada
var w = guns[weapon.index];
var t = w.ammoType;

// si el arma no tiene ammoType, sal
if (t == "" || is_undefined(t)) exit;

// 3) LÍMITE de reserva de balas
var maxReserve = 999;
switch (t) {
    case "gun":    maxReserve = 120; break;
    case "smg":    maxReserve = 240; break;
    case "escop":  maxReserve = 180; break;
    case "shell":  maxReserve = 40;  break;
}

// valor actual en reserva
var cur = 0;
if (variable_struct_exists(reserve, t)) cur = reserve[$ t];

// Si ya estás full de BALAS, no salimos aún, porque quizás necesitas GRANADAS
// Pero si estás full de AMBAS cosas, ahí sí salimos.
var can_take_ammo = (cur < maxReserve);
var can_take_nades = (granadas < 5); // Límite de 5 granadas

if (!can_take_ammo && !can_take_nades) exit;

// 4) MARCAR COMO TOMADO
other.taken = true;
other.visible = false;

// --- A) SUMAR BALAS (Si hay espacio) ---
if (can_take_ammo) {
    var add = other.amount;
    reserve[$ t] = min(cur + add, maxReserve);
    
    // Sonido normal de balas
    if (global.sfx) audio_play_sound(snd_ammo_pickup, 1, false);
}

// --- B) SUMAR GRANADA (30% de Probabilidad) ---
if (can_take_nades) {
    if (random(100) < 30) {
        granadas += 1;
    }
}

// ✅ AUTO-RECARGA si el cargador estaba vacío
if (!reloading && w.ammo <= 0)
{
    scrReloadWeapon();
}

// 5) DESTRUCCIÓN SINCRONIZADA ONLINE
var uid = other.net_uid;

if (global.ONLINE) {
    if (oBrain.AmIPseudoHost) {
        // El Host libera el punto y destruye
        scr_release_spawn_point(other.x, other.y); 
        instance_destroy(other);
        
        if (instance_exists(oOtherPlayer)) {
            SendEventToClient(oOtherPlayer.clientId, "ammo_taken", { uid: uid });
        }
    } else {
        // El Cliente avisa al Host y destruye su copia local
        if (instance_exists(oOtherPlayer)) {
            SendEventToClient(oOtherPlayer.clientId, "request_ammo", { uid: uid });
        }
        instance_destroy(other);
    }
} else {
    instance_destroy(other);
}

