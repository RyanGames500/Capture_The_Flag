/// @description Do something with this entity
try{
if(entityProperties!=-1){
var EP = json_parse(entityProperties)

/*
This is every instance of another entity in the room you are in
You can use the key-value pairs in these properties
to do stuff here. For starters, try updating
x = SP._x
y = SP._y
or whatever you want to update in any way from
your entityProperties
*/

var target_x = EP._x;
var target_y = EP._y;

// Movimiento suavizado (Lerp)
	if(x!=0){
		//the bullet is moving
		x = lerp(x, target_x,0.5)
		y = lerp(y, target_y,0.5)
	}else{
		//the bullet was just created
		x = real(EP._x);
		y = real(EP._y);
	}
        image_angle = real(EP._A);
        image_xscale = real(EP._IMXS);
        sprite_index = EP._SI;
		is_rocket = EP._IR;
}
}catch(e){

	show_debug_message("Error in oOtherPlayersEntity Step. This can be temporary but if it keeps repeating, check your code!")
	show_debug_message(e)
}
//DO NOT PUT YOUR CODE AFTER THIS LINE




