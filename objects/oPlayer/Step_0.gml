


// 1. Obtener Entradas
key_left  = keyboard_check(ord("A")) 
key_right = keyboard_check(ord("D")) 
key_jump  = keyboard_check_pressed(ord("W")) 
key_melee = keyboard_check_pressed(ord("X"));
 
if (melee_cd > 0) melee_cd--;
if (melee_active > 0) melee_active--;
if (crush_cd > 0) crush_cd--;

if (!mouse_check_button(mb_left)) {
    ak_recoil = max(0, ak_recoil - 0.6); // qué tan rápido se “calma”
}

// se va “recuperando” solo
recoil_kick *= 0.75;
recoil_angle *= 0.75;
recoil_x *= 0.7;
recoil_y *= 0.7;

if (reloading)
{
    reload_timer--;

    if (reload_timer <= 0)
    {
        var w = guns[weapon.index];
        var t = w.ammoType;

        var res  = reserve[$ t];
        var need = w.maxAmmo - w.ammo;
        var take = min(need, res);

        w.ammo += take;
        reserve[$ t] -= take;

        guns[weapon.index] = w;
        reloading = false;

        //if (global.sfx) audio_play_sound(snd_reload_done, 1, false);
    }
}

if (global.ONLINE && spawn_lock > 0)
{
    spawn_lock--;

    if (oBrain.AmIPseudoHost) { x = 51;  y = 400; }
    else { x = 591; y = 400; }

    if (variable_instance_exists(id, "latest_x")) latest_x = x;
    if (variable_instance_exists(id, "latest_y")) latest_y = y;
}

// se recalcula SIEMPRE
var canShoot = (!has_flag) && (state != PLAYERSTATE.DEAD);

// =========================
// MELEE SIEMPRE (tenga o no bandera)
// =========================
if (key_melee && melee_cd <= 0 && state != PLAYERSTATE.DEAD)
{
    melee_cd = room_speed div 3;
    melee_active = 6;

    if (global.sfx) audio_play_sound(snd_melee, 1, false);

    if (global.ONLINE && instance_exists(oOtherPlayer))
    {
        SendEventToClient(oOtherPlayer.clientId, "fx_melee", {
            x: x, y: y, dir: sign(image_xscale)
        });
    }
}

// daño melee mientras está activo
if (melee_active > 0)
{
    var range = 26;
    var hx = x + (range * sign(image_xscale));
    var hy = y - 10;

    var target = instance_place(hx, hy, oOtherPlayer);
    if (target != noone)
    {
        melee_active = 0;

	if (global.ONLINE)
	{
	    SendEventToClient(target.clientId, "hit", {
	        damage: melee_damage,
	        killer: global.myName,   // o global.myName
	        reason: "pvp"
	    });
	}
	else
	{
	    target.health -= melee_damage;
	}

    }
}


// 2. Aplicar Gravedad (Aplica para casi todos los estados)
if (state != PLAYERSTATE.DEAD) {
    vsp += grv;
}

// 3. Máquina de Estados
switch (state) {
    case PLAYERSTATE.IDLE:
if (canShoot && melee_active <= 0)
{
    scrPlayerWeaponUpdate();
}


        hsp = 0;
        sprite_index = spr_player_idle;
        if (key_jump && is_grounded) {is_grounded = false; vsp = jumpsp; state = PLAYERSTATE.JUMP; }
        if (key_right || key_left) state = PLAYERSTATE.WALK;
        break;

    case PLAYERSTATE.WALK:
if (canShoot && melee_active <= 0)
{
    scrPlayerWeaponUpdate();
}
		// Modifica la línea de hsp dentro de PLAYERSTATE.WALK:
		var _current_speed = has_flag ? walksp * 0.7 : walksp; // 30% más lento si tiene la bandera
		hsp = move * _current_speed;
        move = key_right - key_left;
        sprite_index = spr_player_walk;
        if (hsp != 0) image_xscale = sign(hsp) * 1.5;
        
        if (hsp == 0) state = PLAYERSTATE.IDLE;
        if (key_jump && is_grounded) {is_grounded = false;  vsp = jumpsp; state = PLAYERSTATE.JUMP; }
        
        break;

    case PLAYERSTATE.JUMP:
if (canShoot && melee_active <= 0)
{
    scrPlayerWeaponUpdate();
}


        move = key_right - key_left;
        hsp = move * walksp;
        if (hsp != 0) image_xscale = sign(hsp) * 1.5;
        // Aquí podrías poner sprite_index de salto
        if (is_grounded) state = PLAYERSTATE.IDLE;
        break;

    case PLAYERSTATE.SHOT:
        hsp = 0; // Se detiene para disparar
        sprite_index = spr_player_shot;
        image_speed = 0.8; // Velocidad controlada
        
        // Crear bala en Frame 1
        if (floor(image_index) == 1 && !bullet_created) 
		{
            var inst = instance_create_layer(x + (23 * sign(image_xscale)), y - 12, "Instances", oMyEntity);
				inst.speed = 10;
				inst.sprite_index = sprOtherMissile;
                inst.direction = (other.image_xscale > 0) ? 0 : 180;
                inst.image_xscale = other.image_xscale;
				bullet_created = true;			
        }
        
        // Volver a Idle al terminar
        if (image_index >= image_number - 1) {
            state = PLAYERSTATE.IDLE;
            image_speed = 1;
        }
        break;

    case PLAYERSTATE.HIT:
        // Lógica de recibir daño (ej: un pequeño salto hacia atrás)
        sprite_index = spr_player_hit;
        if (image_index >= image_number - 1) state = PLAYERSTATE.IDLE;
        break;

		case PLAYERSTATE.DEAD:
        hsp = 0;

        sprite_index = spr_player_dead;
        if (image_index >= image_number - 1) 
		{
			//image_speed = 0; 
			visible=false;
		}
        break;
}

var plat = instance_place(x, y + 1, oMovingPlatform);
if (plat != noone && vsp >= 0)
{
    // “pegarlo” arriba de la plataforma (evita que se vaya al centro)
    var my_bottom = bbox_bottom;
    var plat_top  = plat.bbox_top;
    y -= (my_bottom - plat_top);

    // subir/bajar con ella
    y += plat.dy;
}


//plataforma traspasable
if (vsp > 0)
{
    var plat = instance_place(x, y + vsp, oPlataformaPasable);
    if (plat != noone)
    {
        // evitar enganchar desde abajo
        if (bbox_bottom <= plat.bbox_top + vsp)
        {
            y = plat.bbox_top - (bbox_bottom - y);
            vsp = 0;
            is_grounded = true;

            if (state == PLAYERSTATE.JUMP)
                state = PLAYERSTATE.IDLE;
        }
		
    }
	
}





// 4. Colisiones (El código que ya teníamos)
if (place_meeting(x + hsp, y, obj_wall)) {
    while (!place_meeting(x + sign(hsp), y, obj_wall)) x += sign(hsp);
    hsp = 0;
}
x += hsp;

if (place_meeting(x, y + vsp, obj_wall)) {
    while (!place_meeting(x, y + sign(vsp), obj_wall)) {
        y += sign(vsp);
    }
    vsp = 0;
    is_grounded = true;
}
else
{
	is_grounded = false;
}

y += vsp;

if (health <= 0 && !isDead)
{
//Soltar arma equipada 
if (global.ONLINE) 
    {
        var _weapon_to_drop = guns[weapon.index];
        
        if (oBrain.AmIPseudoHost) 
        {
            // EL HOST MUERE: Llama a la función de drop directamente
            // Usamos x, y del jugador que acaba de morir
            scr_drop_on_death(_weapon_to_drop, x, y);
        } 
        else 
        {
            // EL CLIENTE MUERE: Le pide al host que haga el drop
            // IMPORTANTE: Asegúrate de que el Host sea el destino (oOtherPlayer en el cliente es el Host)
            if (instance_exists(oOtherPlayer)) {
                SendEventToClient(oOtherPlayer.clientId, "request_drop_on_death", {
                    weapon: _weapon_to_drop,
                    x: x,
                    y: y
                });
            }
        }
	}
    isDead = true;
    state = PLAYERSTATE.DEAD;
    invulnerable = true;
    alarm[1] = 120;

    var localText  = "";
    var remoteText = "";

    // =========================
    // 1) MUERTE POR MARTILLO
    // =========================
    if (death_reason == "crush")
    {
        // en tu pantalla:
        localText = "Moriste aplastado";

        // en la pantalla de los demás:
        remoteText = playerName + " murio aplastado";
    }
    // =========================
    // 2) MUERTE NORMAL (PVP)
    // =========================
    else
    {
        var killerName = (last_killer != "") ? last_killer : "Alguien";

        // en tu pantalla:
        localText = killerName + " te elimino";

        // en la pantalla de los demás:
        remoteText = killerName + " elimino a " + playerName;
    }

    // ====== mostrar local ======
    scrAddKillFeed(localText);

    // ====== mandar al remoto ======
    if (global.ONLINE && instance_exists(oOtherPlayer))
    {
        SendEventToClient(oOtherPlayer.clientId, "kill_feed", { msg: remoteText });
    }
}





if (state == PLAYERSTATE.DEAD && has_flag == true) 
{
    has_flag = false;
    
    // Identificamos qué bandera soltamos
    var bandera_a_soltar = (global.myTeam == "AZUL") ? oFlag : oFlag2;

    with (bandera_a_soltar) 
    {
        has_flag = false;
        portador_instancia = noone;
        // La dejamos exactamente donde estaba el jugador
        x = other.x;
        y = other.y;
        velocidad_caida = -2; // Un pequeño rebote hacia arriba para que se vea bien
    }
    
    // IMPORTANTE: Avisar a los demás que la bandera cayó al suelo
    if (instance_exists(oOtherPlayer)) {
        SendEventToClient(oOtherPlayer.clientId, "flag_dropped", { 
            team: global.myTeam, 
            dropX: x, 
            dropY: y 
        });
    }
}


// --- CÓDIGO DE CAPTURA DE BANDERA ---
// Identificamos cuál es la bandera que debo capturar (la del enemigo)
var objetivo = (global.myTeam == "AZUL") ? oFlag : oFlag2;

if (!score_pending && place_meeting(x, y, objetivo) && state != PLAYERSTATE.DEAD && !has_flag) 
{
    has_flag = true;
    with(objetivo) { 
        has_flag = true;
        portador_instancia = other.id;
    }

    if (instance_exists(oOtherPlayer)) {
        SendEventToClient(oOtherPlayer.clientId, "flag_capture", { team: global.myTeam });
    }
    //audio_play_sound(snd_flag_taken, 10, false); // Pon tu sonido de captura
}

// --- CÓDIGO DE ANOTACIÓN EN BASE ---
// Identificamos cuál es MI base
var miBase = (global.myTeam == "AZUL") ? obj_base_blue : obj_base_red;

if (place_meeting(x, y, miBase) && has_flag)
{
    // IMPORTANTE: NO resetees la bandera aquí en ONLINE
    has_flag = false;

	// DETACH LOCAL: para evitar recaptura en loop mientras llega la confirmación del host
	with (objetivo) {
	    has_flag = false;
	    portador_instancia = noone;
	    velocidad_caida = 0; // opcional
	}


    // Dime cuál bandera era la que yo traía (la del enemigo)
    var flag_scored = (global.myTeam == "AZUL") ? "ROJA" : "AZUL";

    if (oBrain.AmIPseudoHost) {
        // Host suma y aplica reset
        if (global.myTeam == "AZUL") global.puntos_azul++; else global.puntos_rojo++;

        // Reset solo de la bandera anotada (la del enemigo)
        if (flag_scored == "ROJA") {
            with (oFlag) { x=spawnX; y=spawnY; velocidad_caida=0; has_flag=false; portador_instancia=noone; }
        } else {
            with (oFlag2){ x=spawnX; y=spawnY; velocidad_caida=0; has_flag=false; portador_instancia=noone; }
        }

        // Enviar a cliente marcador + cuál bandera resetear
        if (instance_exists(oOtherPlayer)) {
            SendEventToClient(oOtherPlayer.clientId, "sync_score", {
                azul: global.puntos_azul,
                rojo: global.puntos_rojo,
                resetFlag: flag_scored
            });
        }


// 2. EL HOST CREA SU PROPIA NOTIFICACIÓN
        var notif = instance_create_layer(0, 0, "Instances", oNotification);
        notif.target_scale = 1.5;
        
        // LÓGICA PARA EL HOST:
        // flag_scored es la bandera que acaba de llegar a una base.
        // Si la bandera reseteada es la del enemigo, ¡Anotó el Host!
        var miObjetivo = (global.myTeam == "AZUL") ? "ROJA" : "AZUL";
        
        if (flag_scored == miObjetivo) {
            notif.text = "TU EQUIPO ANOTO!";
            notif.color = c_lime;
        } else {
            // Si se reseteó MI bandera, significa que el PLAYER 2 anotó en mi cara
            notif.text = "EL ENEMIGO ANOTO!";
            notif.color = c_orange;
        }
		
		
    } 
	else 
	{
		score_pending = true;
        // Cliente le pide al host el punto + cuál bandera anotó
        if (instance_exists(oOtherPlayer)) {
			// Asegúrate de que global.myTeam sea "ROJA" o cámbialo manualmente aquí para probar:
			SendEventToClient(oOtherPlayer.clientId, "request_point", {
			    team: (global.myTeam == "AZUL") ? "AZUL" : "ROJA", // Forzamos el nombre correcto
			    resetFlag: flag_scored
			});
        }
    }
}


// --- DEVOLVER MI BANDERA A BASE ---
var miBandera = (global.myTeam == "AZUL") ? oFlag2 : oFlag;

if (!score_pending && place_meeting(x, y, miBandera) && !miBandera.has_flag && (miBandera.x != miBandera.spawnX)) 
{
    score_pending = true; 

    if (oBrain.AmIPseudoHost) {
        // --- LÓGICA DIRECTA PARA EL HOST ---
        with(miBandera) { x = spawnX; y = spawnY; }
        
        // El Host crea su propia notificación de una vez
        var notif = instance_create_layer(0, 0, "Instances", oNotification);
        notif.text = "SALVASTE TU BANDERA!";
        notif.color = c_aqua;
        notif.target_scale = 1.2;
        
        // Avisa al cliente
        if (instance_exists(oOtherPlayer)) {
            SendEventToClient(oOtherPlayer.clientId, "sync_score", { 
                azul: global.puntos_azul, 
                rojo: global.puntos_rojo, 
                resetFlag: (global.myTeam == "AZUL") ? "AZUL" : "ROJA",
                reason: "RETORNO" 
            });
        }
        
        // IMPORTANTE: El Host se desbloquea a sí mismo
        score_pending = false; 
    } 
    else 
    {
        // EL CLIENTE PIDE AL HOST
        if (instance_exists(oOtherPlayer)) {
            SendEventToClient(oOtherPlayer.clientId, "request_point", { 
                team: "SISTEMA", 
                resetFlag: (global.myTeam == "AZUL") ? "AZUL" : "ROJA" 
            });
        }
    }
}

//Invulnerabilidad
	// Lógica del timer
	if (invul_timer > 0) {
	    invul_timer--;
	    invulnerable = true;
	    image_alpha = 0.5; // Efecto visual de transparencia
	} else {
if (!isDead) {
        invulnerable = false;
        image_alpha = 1;
    }
	}

//Compartir con los demas jugadores
global.sharedProperties = {
    _x : x,
    _y : y,
    _A : image_angle,
    _H : health,
	_IA: image_alpha,
    _IMYS: image_yscale,
    _IMXS: image_xscale,
    _ST: state,
    _SI: sprite_index,
    _II: (state == PLAYERSTATE.DEAD) ? -1 : image_index,
    _IS: image_speed,
    _BS: bullet_created, // Para que los otros "vean" cuando sale la bala de tu arma
	_KILLS: kills,
	_VIS: visible,
	_HF: has_flag,
	_INV: invulnerable,
	_NAME: playerName,
	_ANG: weapon.angle,              // Ángulo del mouse
    _WSI: guns[weapon.index]? guns[weapon.index].sprite : 0,
	_AMMO: (guns[weapon.index] != noone) ? guns[weapon.index].ammo : 0,
	_ATYPE: (guns[weapon.index] != noone) ? guns[weapon.index].ammoType : "",
	_REL: reloading,
	_RK: recoil_kick,
	_RA: recoil_angle,
	_MELEE: melee_active,
	_TEAM: team


};
	
	
	
	

