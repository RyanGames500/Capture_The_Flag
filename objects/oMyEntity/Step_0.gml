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

if (target_enemy != noone) 
{
    // Usamos la variable directa. 
    // Si en sharedProperties mandaste "_INV", aquí la buscas como _INV
    if (target_enemy.invulnerable == false) 
    {
        // SOLO si NO es invulnerable ejecutamos el sonido y la destrucción
        if(global.sfx==true){audio_play_sound(snd_hit, 20, false, .9);}
		SendEventToClient(target_enemy.clientId, "hit", { damage: damage });
       instance_destroy();
    } 
    else 
    {
        // Si es invulnerable, ignoramos la colisión visualmente
        image_alpha = 0.5;
    }
}



if (target_enemy != noone) {
    // Mandamos el hit y nuestro nombre (global.userName)
    var hitData = {
        killerName: global.userName 
    };
    SendEventToClient(target_enemy.clientId, "hit", hitData);
    
    instance_destroy();
}



















