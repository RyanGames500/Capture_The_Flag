/// @description Entity Updater

if (!is_string(entities)) { alarm[0] = 3; exit; }
var E;
try { E = json_parse(entities); } catch(_e) { alarm[0] = 3; exit; }
var oldKeys = variable_struct_get_names(oldE);

var keys = variable_struct_get_names(E);

//DELETE OLD ENTITIES
for(var i =0 ; i<array_length(oldKeys) ;i++){

	if(!array_contains(keys , oldKeys[i])){
		try{
			with(oOtherPlayersEntity){
				if(entityId == real(oldKeys[i])){
                    if (!is_rocket && !is_box && (collision_circle(x, y, 12, obj_wall, false, true) != noone || collision_circle(x, y, 12, oPlayer, false, true) != noone)) 
                    {
					    fx_sparks(x, y, direction + 180, 6, false);
					}
					instance_destroy(id)
				}
			}
		}
	}
}






for (var i = array_length(keys)-1; i >= 0; --i) {
    var thisEntityId = keys[i];
    var thisEntityProperties = variable_struct_get(E , thisEntityId);
	
	var found = false;
	with(oOtherPlayersEntity){
		if(entityId == real(thisEntityId)){
		//found entities belonging to this player
		found = true;
		entityProperties = thisEntityProperties
		
		}
	}
	
	
	if(!found){
		show_debug_message("creating a new entity")
		var new_entity = instance_create_layer(0,0,global.OtherPlayersLayerName,oOtherPlayersEntity);
		new_entity.clientId = real(clientId);
		new_entity.entityId = real(thisEntityId)
		new_entity.entityProperties = thisEntityProperties
	}
	
}





oldE = E
alarm[0] = 3;