/// @description Put your other player code here
try{
if(sharedProperties!=-1){
var SP = json_parse(sharedProperties)

/*
This is every instance of another player in the room you are in
You can use the key-value pairs in shared properties
to do stuff here. For starters, try updating
x = SP._x
y = SP._y
or whatever you want to update in any way from
your sharedProperties
*/

		//the other player is moving
		x = lerp(x, real(SP._x),0.2)
		y = lerp(y, real(SP._y),0.2)
		image_xscale =real(SP._IMXS);
		image_yscale = real(SP._IMYS);
		enemyHealth = SP._H;
		sprite_index = real(SP._SI);
		if (SP._II != -1) {
		    image_index = real(SP._II);
		}
		image_speed = SP._IS;
		state = real(SP._ST);	
		has_flag = SP._HF;
		kills = SP._KILLS;
		invulnerable = real(SP._INV);
		image_alpha=real(SP._IA);
		visible=real(SP._VIS);







//DO NOT PUT YOUR CODE AFTER THIS LINE
}
}catch(e){

	show_debug_message("Error in oOtherPlayer Step. This can be temporary but if it keeps repeating, check your code!")
	show_debug_message(e)
}

// 2. "Fix de Muerte" para el títere
if (state == PLAYERSTATE.DEAD) 
{
    hsp = 0;
    vsp = 0;
    
    // Si ya llegó al final de la animación de muerte
    if (image_index >= image_number - 1) {
        image_speed = 0;   // Se detiene para que no parpadee el primer frame
        image_index = image_number - 1; // Se clava en el último frame (el de suelo)
        visible = false;   // Y desaparece
    }
}