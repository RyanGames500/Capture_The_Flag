/// @description Update this entity as much as you want


/*
* Update this struct
*/
entityProperties = {
	_entityId : entityId,
	//Add stuff here like type / x / y / whatever
	_type : tipo,
	_x : x,
	_y : y,
	_A : direction,
    _IMXS : image_xscale, // Para que la bandera mire a donde mira el portador
	_SI: sprite_index,
	_amount : amount

}


// 2. LÓGICA DIFERENCIADA
if (tipo == "bala") {
if (life > 0) {
    life--;
    if (life <= 0) instance_destroy();
}	
var target_enemy = instance_place(x, y, oOtherPlayer);

if (target_enemy != noone)
{
    if (target_enemy.invulnerable) exit;

    // ======================================================
    // 🔥 PREDICCIÓN VISUAL INSTANTÁNEA (Feedback Local)
    // ======================================================
with(target_enemy) 
{
    if (state != PLAYERSTATE.DEAD) 
    {
        hit_bloqueo_timer = 10; // Bloqueamos la red por 10 frames (suficiente para ver el hit)
        state = PLAYERSTATE.HIT;
        image_index = 0;
    }
}
    
    // Crear sangre y sonido al momento
    //instance_create_layer(x, y, "Instances", oBloodFX);
    if (global.sfx) audio_play_sound(snd_hit, 20, false, 1.1);
    // ======================================================

    if (global.ONLINE)
    {
        if (oBrain.AmIPseudoHost)
        {
            // El Host valida el golpe y lo manda a la víctima
            SendEventToClient(target_enemy.clientId, "hit", {
                damage: damage,
                killer: global.myName,
                reason: "pvp"
            });
        }
        else
        {
            // El Cliente le pide permiso al host
            SendEventToClient(oOtherPlayer.clientId, "request_hit", {
                victimId: target_enemy.clientId,
                damage: damage,
                killer: global.myName,
                reason: "pvp"
            });
        }
    }

    instance_destroy(); // La bala desaparece
}
} 
else if (tipo == "ammo") {
// --- Lógica de Recogida (Para el jugador local oPlayer) ---
var p = instance_place(x, y, oPlayer);

if (p != noone) 
{
    // 0) Si ya fue tomado, no hacer nada
    if (taken) exit;

    // 1) Debes tener arma equipada (accedemos a las variables de oPlayer 'p')
    if (p.guns[p.weapon.index] == noone) exit;

    // 2) Tipo de ammo según arma equipada
    var w = p.guns[p.weapon.index];
    var t = w.ammoType;

    if (t == "" || is_undefined(t)) exit;

    // 3) LÍMITE de reserva
    var maxReserve = 999;
    switch (t) {
        case "gun":   maxReserve = 120; break;
        case "smg":   maxReserve = 240; break;
        case "escop": maxReserve = 180; break;
        case "shell": maxReserve = 40;  break;
    }

    var cur = 0;
    if (variable_struct_exists(p.reserve, t)) cur = p.reserve[$ t];

    if (cur >= maxReserve) exit;

    // 4) ¡TOMADO!
    taken = true;
    
    // Sumar munición al oPlayer
    var add = amount;
    p.reserve[$ t] = min(cur + add, maxReserve);

    // Auto-recarga
    if (!p.reloading && w.ammo <= 0) {
        with(p) { scrReloadWeapon(); }
    }

    if (global.sfx) audio_play_sound(snd_ammo_pickup, 1, false);

    // 5) DESTRUCCIÓN SINCRONIZADA (MAGIA DE ENTIDADES)
    // Al hacer esto, el evento Destroy de oMyEntity se ejecuta y 
    // le dice al servidor que borre esta entidad en todos lados.
    instance_destroy(); 
}
}














