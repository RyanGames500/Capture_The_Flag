/// @description Do something with this persistent object

try{
if(persistentObjectProperties!=-1){
var pOp = json_parse(persistentObjectProperties)

/*
This is every instance of a persistent server object  in the room you are in
You can use the key-value pairs in these properties
to do stuff here. For starters, try updating
x = pOp._x
y = pOp._x
or whatever you want to update in any way 

Maybe someone left a ball in the room? This object can represent the ball.
The difference in a persistent object from normal entities is that
pO exist in the room even after the player exists the room or disconnects the server.
They are purely server side objects  which will stay unless you delete them

To create and edit these special objects use the CreatePersistentObject(), EditPersistentObject()!!
*/


x = pOp._x;
y = pOp._y;
sprite_index = pOp._sprite
_type = pOp._type;
state = pOp._state
carrier = pOp._carrier;
	
	
	
	
	
	
	
	
	
	
	
	


}
}catch(e){

	show_debug_message("Error in oPersistentObject Step. This can be temporary but if it keeps repeating, check your code!")
	show_debug_message(e)
}
//DO NOT PUT YOUR CODE AFTER THIS LINE

// Evento Step de oPersistentObject
if (persistentObjectProperties.type == "flag") {
    var owner_id = persistentObjectProperties.carrier;

    if (owner_id == -1) {
        // NADIE LA LLEVA: Se queda quieta en sus coordenadas guardadas
        x = 100;
        y = 100;
    } else {
        // ALGUIEN LA LLEVA: Buscamos al jugador con ese ID y nos pegamos a él
        with(oOtherPlayer) { // O como se llame tu objeto de jugador
            if (clientId == owner_id) { // Debes comparar con el ID de red
                other.x = x;
                other.y = y;
            }
        }
    }
}