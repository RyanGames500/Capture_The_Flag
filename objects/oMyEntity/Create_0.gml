/// @description What this entity has?
// You can write your code in this editor

clientId = global.clientId; //this is your entity, like a bullet
oBrain.entitiesCreated++;
entityId = oBrain.entitiesCreated
array_push(oBrain.entitiesActive , entityId);

/*
* Add your variables in this entityproperties
*/
entityProperties = {
	_entityId : entityId,
	_spd: speed,
	_SI: sprite_index,
	_IMXS : image_xscale, // Para que la bandera mire a donde mira el portador
	_x: x,
	_y: y,
	

}

MessageStruct = {
	damage: 10
};
