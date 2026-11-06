
/// @description Put your other player code here
// Bot de la sala privada que muevo yo (soy el lider): se mueve solo (scr_objetivo)
if (bot_local) { scr_botnet_step(); exit; }
try{
if(sharedProperties!=-1){
var SP = json_parse(sharedProperties)
// Todavia no tiene personaje en el mapa (sala de espera o eligiendo): sus datos llegan sin
// posicion. Antes eso daba el error "_x not set" muchisimas veces; ahora solo no se mueve.
if (is_struct(SP) && variable_struct_exists(SP, "_x")) {

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
		net_x = lerp(net_x, target_x,0.5)
		net_y = lerp(net_y, target_y,0.5)
	}else{
		//the bullet was just created
		net_x = real(SP._x);
		net_y = real(SP._y);
	}

		// --- EMPUJE CON PREDICCIÓN ---
		if (pp_timer > 0) {
		    pp_timer--;
		    // 1. Simulo el mismo empuje que hace el que recibe el golpe
		    if (abs(pp_h) > 0.8) {
		        if (place_meeting(pp_start_x + pp_dx + pp_h, pp_start_y + pp_dy, obj_wall)) pp_h = 0;
		        else pp_dx += pp_h;
		        pp_h = lerp(pp_h, 0, 0.1);
		    } else {
		        pp_h = 0;
		    }
		    pp_vy += 0.5;
		    var _sim_y = min(0, pp_dy + pp_vy);
		    if (place_meeting(pp_start_x + pp_dx, pp_start_y + _sim_y, obj_wall)) pp_vy = 0;
		    else pp_dy = _sim_y;
		    if (pp_dy >= 0) pp_vy = 0;

		    // 2. Lo que ya llegó de verdad por la red se lo quito a la predicción
		    var _nx = net_x - pp_start_x;
		    var _ny = net_y - pp_start_y;
		    var _mx = (sign(_nx) == sign(pp_dx)) ? sign(pp_dx) * min(abs(_nx), abs(pp_dx)) : 0;
		    if (_ny < -5) pp_seen_up = true;
		    pp_off_x = pp_dx - _mx;
		    pp_off_y = pp_dy - _ny;   // en vertical manda la predicción (así no salta dos veces)

		    // 3. Si el empuje real ya llegó completo (subió y volvió a caer), termino
		    if (pp_h == 0 && pp_dy >= 0 && abs(pp_off_x) < 1 && pp_seen_up && _ny >= -1) pp_timer = 0;
		} else if (pp_off_x != 0 || pp_off_y != 0) {
		    // Nunca llegó el empuje real (escudo, invulnerable...): lo regreso suave
		    pp_off_x = lerp(pp_off_x, 0, 0.25);
		    pp_off_y = lerp(pp_off_y, 0, 0.25);
		    if (abs(pp_off_x) < 0.5 && abs(pp_off_y) < 0.5) { pp_off_x = 0; pp_off_y = 0; }
		}

		x = net_x + pp_off_x;
		y = net_y + pp_off_y;
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

		// --- ECO DEL GOLPE ---
		// En mi pantalla el golpe se adelanta (scr_predict_hit). Cuando termina, llega por la red
		// el golpe real del rival (con retraso) y antes se volvia a reproducir: se veia DOS veces.
		// Ahora ese eco se queda en el ultimo cuadro del golpe hasta que la red diga que ya acabo.
		var _st_eco = real(SP._ST);
		if (hit_bloqueo_timer > 0) {
		    if (hit_eco <= 0) hit_eco_visto = false;   // golpe nuevo
		    hit_eco = 45;                               // espero hasta 0.75 s el eco
		    if (_st_eco == PLAYERSTATE.HIT) hit_eco_visto = true;
		} else if (hit_eco > 0) {
		    hit_eco--;
		    if (_st_eco == PLAYERSTATE.HIT) hit_eco_visto = true;
		    else if (hit_eco_visto) hit_eco = 0;        // la red ya salio del golpe: listo
		}
		var _eco = (hit_bloqueo_timer <= 0 && hit_eco > 0 && _st_eco == PLAYERSTATE.HIT);

		// --- SPRITE: durante el golpe mostramos su sprite de HIT local ---
		if (hit_bloqueo_timer > 0 || _eco) {
		    var _hits = [spr_player_hit, spr_miguel_hit, spr_marina_hit, spr_sargento_hit];
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
    
		if (SP._II != -1 && hit_bloqueo_timer <= 0 && !_eco) {
		    image_index = real(SP._II);
		}
		image_speed = SP._IS;
		if (_eco) {
		    // Quieto en el ultimo cuadro del golpe (no lo repite)
		    image_index = sprite_get_number(sprite_index) - 1;
		    image_speed = 0;
		}
		// Hit-stop: el que recibió el golpe también se congela en mi pantalla
		if (variable_global_exists("hitstop") && global.hitstop > 0 && hit_bloqueo_timer > 0) image_speed = 0;
		// Si el cronómetro de golpe está activo, ignoramos el estado de la red
		if (hit_bloqueo_timer > 0) {
		    hit_bloqueo_timer--;
		    state = PLAYERSTATE.HIT; // Forzamos el estado visual de dolor
		} else if (_eco) {
		    state = PLAYERSTATE.HIT;
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
		efx_vis = variable_struct_exists(SP, "_EF") ? real(SP._EF) : 0;      // efecto encima (scr_armas)
		WTI = variable_struct_exists(SP, "_WT") ? real(SP._WT) : c_white;    // color del arma
		ammo = SP._AMMO;
		reloading = SP._REL;
		recoil_kick = real(SP._RK);
		recoil_angle = real(SP._RA);
		has_shield = real(SP._SH)
		team = string(SP._TEAM);
		max_health = real(SP._MH);
		// Habilidad (scr_personajes). Si viene de una versión vieja no trae nada.
		hab_co = variable_struct_exists(SP, "_HCO") ? real(SP._HCO) : false;
		hab_da = variable_struct_exists(SP, "_HDA") ? real(SP._HDA) : false;
		hab_gf = variable_struct_exists(SP, "_HGF") ? real(SP._HGF) : 0;
		hab_gx = variable_struct_exists(SP, "_HGX") ? real(SP._HGX) : x;
		hab_gy = variable_struct_exists(SP, "_HGY") ? real(SP._HGY) : y;

		var net_melee = real(SP._MELEE);

		// Detectar inicio de golpe: cuando el net sube (ej: 0 -> 6)
		if (net_melee > melee_prev_net)
		{
		    melee_active = 6; // arrancamos animación local suave
		}
		melee_prev_net = net_melee;

		// Animación local (suave, 1 frame por step)
		if (melee_active > 0) melee_active--;

		

}   // fin: ya tiene personaje
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
