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

}

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
















