/// @description Update this entity as much as you want
if (life > 0) {
    life--;
    if (life <= 0) instance_destroy();
}

/*
* Update this struct
*/
entityProperties = {
	_entityId : entityId,
	//Add stuff here like type / x / y / whatever
	_x : x,
	_y : y,
	_A : direction,
    _IMXS : image_xscale, // Para que la bandera mire a donde mira el portador
	_SI: sprite_index

}


var target_enemy = instance_place(x, y, oOtherPlayer);

// target_enemy es oOtherPlayer (o el que pegaste)
if (target_enemy != noone)
{
    if (target_enemy.invulnerable) exit;

    // 🔥 SOLO el host manda HIT real
    if (global.ONLINE)
    {
        if (oBrain.AmIPseudoHost)
        {
            // Host pega directo y manda killer
            SendEventToClient(target_enemy.clientId, "hit", {
                damage: damage,
                killer: global.myName,     // <- VIENE DE LA BALA
                reason: "pvp"
            });
        }
        else
        {
            // Cliente NO manda hit a la víctima, se lo pide al host
            SendEventToClient(oOtherPlayer.clientId, "request_hit", {
                victimId: target_enemy.clientId,
                damage: damage,
                killer: global.myName,
                reason: "pvp"
            });
        }


    }

        instance_destroy();

  
}












