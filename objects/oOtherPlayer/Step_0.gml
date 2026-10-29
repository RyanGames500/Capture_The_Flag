
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
		var target_x = SP._x;
		var target_y = SP._y;


// Movimiento suavizado (Lerp)
	if(x!=0){
		//the bullet is moving
		x = lerp(x, target_x,0.5)
		y = lerp(y, target_y,0.5)
	}else{
		//the bullet was just created
		x = real(SP._x);
		y = real(SP._y);
	}
		image_xscale =real(SP._IMXS);
		image_yscale = real(SP._IMYS);
		// --- VIDA CON PREDICCIÓN ---
		var _net = real(SP._H);
		enemyHealth_net = _net;
		if (pred_timer > 0) {
		    pred_timer--;
		    if (_net < pred_base) {
		        pred_dmg -= (pred_base - _net);
		        pred_base = _net;
		        if (pred_dmg <= 0) { pred_dmg = 0; pred_timer = 0; }
		    }
		} else {
		    pred_dmg = 0;
		}
		enemyHealth = max(0, _net - pred_dmg);

		// --- SPRITE: durante el golpe mostramos su sprite de HIT local ---
		if (hit_bloqueo_timer > 0) {
		    var _hits = [spr_player_hit, spr_player2_hit, spr_player3_hit, spr_player4_hit];
		    sprite_index = _hits[clamp(mySelectedPJ, 0, 3)];
		} else {
		    sprite_index = real(SP._SI);
		}		
        var _st_net = real(SP._ST);
		var _sx_net = sign(real(SP._IMXS));
		if (!variable_instance_exists(id, "fx_prev_st")) { fx_prev_st = _st_net; fx_prev_sx = _sx_net; }
		if (_st_net == PLAYERSTATE.JUMP && fx_prev_st != PLAYERSTATE.JUMP) fx_dust(x, bbox_bottom, 6, 0);
		if (fx_prev_st == PLAYERSTATE.JUMP && (_st_net == PLAYERSTATE.IDLE || _st_net == PLAYERSTATE.WALK)) fx_dust(x, bbox_bottom, 10, 0);
		if (_st_net == PLAYERSTATE.WALK && fx_prev_sx != 0 && _sx_net != fx_prev_sx) fx_dust(x, bbox_bottom, 6, -_sx_net);
		fx_prev_st = _st_net;
		fx_prev_sx = _sx_net;
    
		if (SP._II != -1 && hit_bloqueo_timer <= 0) {
		    image_index = real(SP._II);
		}
		image_speed = SP._IS;
		// Si el cronómetro de golpe está activo, ignoramos el estado de la red
		if (hit_bloqueo_timer > 0) {
		    hit_bloqueo_timer--;
		    state = PLAYERSTATE.HIT; // Forzamos el estado visual de dolor
		} else {
		    state = real(SP._ST);    // Si no hay golpe, seguimos a la red
		}	
		has_flag = SP._HF;
		kills = SP._KILLS;
		invulnerable = real(SP._INV);
		image_alpha=real(SP._IA);
		visible=real(SP._VIS);
		Name = string(SP._NAME);
		weapon.angle = real(SP._ANG)
		WSI = (SP._WSI);
		ammo = SP._AMMO;
		reloading = SP._REL;
		recoil_kick = real(SP._RK);
		recoil_angle = real(SP._RA);
		has_shield = real(SP._SH)
		team = string(SP._TEAM);
		max_health = real(SP._MH);

		var net_melee = real(SP._MELEE);

		// Detectar inicio de golpe: cuando el net sube (ej: 0 -> 6)
		if (net_melee > melee_prev_net)
		{
		    melee_active = 6; // arrancamos animación local suave
		}
		melee_prev_net = net_melee;

		// Animación local (suave, 1 frame por step)
		if (melee_active > 0) melee_active--;

		

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
