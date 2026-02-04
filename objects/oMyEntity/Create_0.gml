/// @description What this entity has?
// You can write your code in this editor

clientId = global.clientId; //this is your entity, like a bullet
oBrain.entitiesCreated++;
entityId = oBrain.entitiesCreated
array_push(oBrain.entitiesActive , entityId);

/*
* Add your variables in this entityproperties
*/
// oMyEntity - CREATE
tipo = "bala"; // Por defecto, pero el oBrain lo cambiará al crear munición
net_uid = entityId; // Usamos el ID de entidad como ID de red
taken = false;
amount = 0;
entityProperties = {
	_entityId : entityId,
	 _type : tipo,
	_spd: speed,
	_SI: sprite_index,
	_IMXS : image_xscale, // Para que la bandera mire a donde mira el portador
	_x: x,
	_y: y,
	_amount : amount
	

}
life = 0;

damage = 10; // default por si alguien olvida setearlo
ownerClientId = -1; // opcional, si quieres rastrear atacante

MessageStruct = { damage: damage };

damage = 10;
owner_name = "";   // <- nombre del que disparó
owner_id = noone;
owner_team = "";
is_rocket=false;
exploded = false;
net_trail_timer = 0;
smoke_timer = 0;

