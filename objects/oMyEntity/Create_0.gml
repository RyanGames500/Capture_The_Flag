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
life = 0;
tipo="";
//cuando es tipo arma
weapon = {
	sprite: sprite_index,
	object: object_index,
	subimage: 1,
	ammo: 10,//10
	maxAmmo: 10,//10
	frequency: room_speed / 1.5,
	type2: "gun",
};
// oMyEntity Create
damage = 10; // default por si alguien olvida setearlo
ownerClientId = -1; // opcional, si quieres rastrear atacante

MessageStruct = { damage: damage };
