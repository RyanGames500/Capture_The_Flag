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
		// Cada dato solo si llego (una version vieja del juego o una entidad distinta puede no mandarlos todos)
		if (variable_struct_exists(EP, "_IA"))   image_angle = real(EP._IA);
		if (variable_struct_exists(EP, "_IMXS")) image_xscale = real(EP._IMXS);
		if (variable_struct_exists(EP, "_IMYS")) image_yscale = real(EP._IMYS);
		if (variable_struct_exists(EP, "_SI"))   sprite_index = EP._SI;
		if (variable_struct_exists(EP, "_A"))    direction = EP._A;
		is_rocket = variable_struct_exists(EP, "_IR") ? EP._IR : false;
		is_box    = variable_struct_exists(EP, "_IB") ? EP._IB : false;
		x_base_remote = variable_struct_exists(EP, "_XB") ? real(EP._XB) : x; // Guardamos la base
		y_base_remote = variable_struct_exists(EP, "_YB") ? real(EP._YB) : y; // Guardamos la base
		efecto = variable_struct_exists(EP, "_EF") ? string(EP._EF) : "";   // armas con efecto (scr_armas)
}
}catch(e){

	show_debug_message("Error in oOtherPlayersEntity Step. This can be temporary but if it keeps repeating, check your code!")
	show_debug_message(e)
}
//DO NOT PUT YOUR CODE AFTER THIS LINE



// ======================================================
// 🚀 TRAIL DEL ROCKET (SE VE EN TODAS LAS PANTALLAS)
// ======================================================
if (is_rocket)
{
    // cada cliente crea su propio humo
    if (irandom(2) == 0)
    {
        var sm = instance_create_layer(x, y, "Instances", oSmokeTrail);
        sm.color = c_gray;
    }

    image_angle = direction;
}

