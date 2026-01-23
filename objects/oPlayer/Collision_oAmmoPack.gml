// other = oAmmoPack

// 0) si ya fue tomado, no hacer nada
if (other.taken) exit;

// 1) Debes tener arma equipada para poder tomar munición
if (guns[weapon.index] == noone) exit;

// 2) Tipo de ammo según arma equipada
var w = guns[weapon.index];
var t = w.ammoType;

// si el arma no tiene ammoType, sal
if (t == "" || is_undefined(t)) exit;

// 3) LÍMITE opcional de reserva (para que no agarre si ya está full)
// (ajusta estos límites como quieras)
var maxReserve = 999;
switch (t) {
    case "gun": maxReserve = 120; break;
    case "smg":    maxReserve = 240; break;
    case "escop":  maxReserve = 180; break;
    case "shell":  maxReserve = 40;  break;
}

// valor actual en reserva
var cur = 0;
if (variable_struct_exists(reserve, t)) cur = reserve[$ t];

// si ya estás full, ignora el pickup
if (cur >= maxReserve) exit;

// 4) Ahora SÍ lo tomamos: marcar tomado ya
other.taken = true;
other.visible = false;

// sumar sin pasarte del límite
var add = other.amount;
reserve[$ t] = min(cur + add, maxReserve);

// sonido 1 vez
if (global.sfx) audio_play_sound(snd_ammo_pickup, 1, false);

// 5) Destrucción sincronizada
var uid = other.net_uid;

if (global.ONLINE)
{
    if (oBrain.AmIPseudoHost)
    {
        instance_destroy(other);

        if (instance_exists(oOtherPlayer))
            SendEventToClient(oOtherPlayer.clientId, "ammo_taken", { uid: uid });
    }
    else
    {
        // Cliente: pide al host que destruya la copia oficial
        if (instance_exists(oOtherPlayer))
            SendEventToClient(oOtherPlayer.clientId, "request_ammo", { uid: uid });

        // (Opcional recomendado) destruir local también para evitar re-colisión rarísima por 1 frame:
        instance_destroy(other);
    }
    exit;
}
else
{
    instance_destroy(other);
}
