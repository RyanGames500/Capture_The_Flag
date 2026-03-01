// CONGELAR ACCIONES AL FINAL
if (global.game_over) 
{
    hsp = 0;
    vsp = 0; 
    exit;
}

// ======================================================
// 💬 LÓGICA DE EMOTES (Con Anti-Spam)
// ======================================================

// Reducir el timer cada frame
if (emote_cd > 0) emote_cd--;

var _emote_to_send = -1;

// Solo detectamos teclas si el cooldown llegó a cero
if (emote_cd <= 0) 
{
    if (keyboard_check_pressed(ord("1"))) _emote_to_send = 0;
    if (keyboard_check_pressed(ord("2"))) _emote_to_send = 1;
    if (keyboard_check_pressed(ord("3"))) _emote_to_send = 2;
    if (keyboard_check_pressed(ord("4"))) _emote_to_send = 3;

    if (_emote_to_send != -1) 
    {
        // 1. Crearlo localmente
        // (Ajusté la Y a -75 para que coincida con tu nuevo pop)
        var _e = instance_create_layer(x, y - 75, "Instances", oEmote);
        _e.image_index = _emote_to_send;
        _e.owner = id;

        // 2. Avisar a la red
        if (global.ONLINE) {
            with(oOtherPlayer) {
                SendEventToClient(clientId, "player_emote", { 
                    ownerId: global.clientId, 
                    emoteIndex: _emote_to_send 
                });
            }
        }

        // 3. PONER EL COOLDOWN (Ejemplo: 120 frames = 2 segundos)
        emote_cd = 120; 
    }
}

// --- TIMERS DE POWERUPS ---
if (shield_timer > 0) {
    shield_timer--;
    if (shield_timer <= 0) has_shield = false;
}

if (damage_timer > 0) {
    damage_timer--;
    if (damage_timer <= 0) damage_boost = 1;
}

if (ammo_timer > 0) {
    ammo_timer--;
    if (ammo_timer <= 0) infinite_ammo = false;
}

if (shield_timer > 0) {
    shield_timer--;
    
    // Si quedan menos de 2 segundos (120 frames), que el alfa del HUD parpadee
    if (shield_timer < 120) {
        // Esto crea un parpadeo sexy
        shield_alpha_hud = abs(sin(current_time / 100)); 
    }

    if (shield_timer <= 0) {
        has_shield = false;
        // Sonido de "se acabó el poder" (opcional)
        if (global.sfx) audio_play_sound(snd_powerdown, 5, false);
    }
}

if(place_meeting(x,y+1,obj_wall) || place_meeting(x,y+1,oPlataformaPasable))
{
	is_grounded=true;	
}
else
{
	is_grounded=false;	
}

// 1. Obtener Entradas
key_left  = keyboard_check(ord("A")) 
key_right = keyboard_check(ord("D")) 
key_jump  = keyboard_check_pressed(ord("W")) 
key_melee = mouse_check_button_pressed(mb_right);
 
if (melee_cd > 0) melee_cd--;
if (melee_active > 0) melee_active--;
if (crush_cd > 0) crush_cd--;
// --- LÓGICA DE VELOCIDAD ---
if (speed_timer > 0) 
{
	//Rastro Fantasma
	if !alarm[0] and global.EffectTrial
	alarm[0] = TimeAlarmEffectTrail;
	//timer
    speed_timer--;
	//multiplo de velocidad
    walksp_mult = 1.5; // El multiplicador del Power-Up
} 
else 
{
    walksp_mult = 1.0; // VELOCIDAD NORMAL (1 = sin cambios)
}

// Ahora sí, se calcula la velocidad final
walksp = walksp_base * walksp_mult;


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
        
        // 🔥 FILTRO DE SEGURIDAD: Si el arma no existe, abortamos
        if (w == noone || !is_struct(w)) {
            reloading = false;
            exit; 
        }

        var t = w.ammoType;
        var res  = reserve[$ t];
        
        // Verificamos que el tipo de munición exista en la reserva
        if (res == undefined) { reloading = false; exit; }

        var need = w.maxAmmo - w.ammo;
        var take = min(need, res);

        w.ammo += take;
        reserve[$ t] -= take;

        guns[weapon.index] = w;
        reloading = false;
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



// daño melee mientras está activo
if (melee_active > 0)
{
    var range = 26;
    var hx = x + (range * sign(image_xscale));
    var hy = y - 10;

	if(can_sfx=false)
	{
    // --- SOLO ESTO PARA EL EFECTO ---
    var _slash = instance_create_layer(hx, hy, "Instances", oMeleeFX);
    _slash.image_xscale = sign(image_xscale);
    _slash.depth = depth - 10; 
    // -------------------------------
	can_sfx=true;
	alarm[4]=10;
	}

    // Buscamos a alguien en el área
    var target = instance_place(hx, hy, oOtherPlayer);
    
    if (target != noone)
    {
        // 🔥 FILTRO DE EQUIPO: Solo dañamos si el equipo es distinto al nuestro
        // Asumiendo que oOtherPlayer tiene una variable 'team' o la lee de sharedProperties
        if (target.team != global.myTeam) 
        {
            melee_active = 0; // Consumimos el ataque para no dañar 2 veces

            if (global.ONLINE)
            {
                SendEventToClient(target.clientId, "hit", {
                    damage: melee_damage,
                    killer: global.myName,
                    reason: "pvp"
                });
            }
            else
            {
                target.health -= melee_damage;
            }
        }
    }
}

if (mouse_check_button_pressed(mb_right)) 
{
    
    // CASO A: TIENE GRANADAS
// --- LANZAMIENTO HACIA EL MOUSE ---
if (granadas > 0) {
    granadas -= 1;
    melee_cd = room_speed div 3;
	melee_active = 6;
    // Ángulo hacia el mouse desde el jugador
    var dir = point_direction(x, y - 16, mouse_x, mouse_y); 
    var fuerza = 8; // Qué tan fuerte la lanza

    var gx = x + lengthdir_x(15, dir);
    var gy = y - 16 + lengthdir_y(15, dir);
    
    var nade = instance_create_layer(gx, gy, "Instances", oMyEntity);
    
    // Variables base
    nade.owner_name = global.myName;
    nade.sprite_index = spr_granada; 
    nade.damage = 40;
    nade.owner_team = global.myTeam;
    nade.owner_id = id;
    
    // --- AQUÍ ESTÁ EL TRUCO PARA LA DIRECCIÓN ---
    nade.is_granada = true;
    nade.is_rocket = true;
    
    // Calculamos hsp y vsp según la dirección del mouse
    nade.hsp = lengthdir_x(fuerza, dir);
    nade.vsp = lengthdir_y(fuerza, dir) - 2; // El "-2" le da un poco de arco hacia arriba siempre
    
}
    
    // CASO B: NO TIENE GRANADAS -> ATAQUE MELEE NORMAL
    else {
	// =========================
	// MELEE SIEMPRE (tenga o no bandera)
	// =========================
	if (melee_cd <= 0 && state != PLAYERSTATE.DEAD)
	{
	    melee_cd = room_speed div 3;
	    melee_active = 6;

	    if (global.sfx) audio_play_sound(snd_melee, 1, false);

		with(oOtherPlayer) {
	        SendEventToClient(clientId, "fx_melee", {
	            x: other.x, y: other.y, dir: sign(other.image_xscale)
	        });
		}
	}
    }
}

// 2. Aplicar Gravedad (Aplica para casi todos los estados)
if (state != PLAYERSTATE.DEAD) {
    vsp += grv;
}

// 3. Máquina de Estados
switch (state) {

    case PLAYERSTATE.INTRO:

    break;

case PLAYERSTATE.IDLE:
if (canShoot && melee_active <= 0)
{
    scrPlayerWeaponUpdate();
}


        //hsp = 0;
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

if (abs(push_h) > 0.8) {
    hsp = push_h; // AQUÍ SÍ: Sobreescribe el hsp que puso el WALK o JUMP
    push_h = lerp(push_h, 0, 0.1); 
} else {
    push_h = 0;
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
    
}


y += vsp;

if (health <= 0 && !isDead)
{
    reloading = false;
    reload_timer = 0;

    // ==========================================
    // 🔫 SOLTAR ARMA EQUIPADA
    // ==========================================
    if (global.ONLINE) 
    {
        var _weapon_to_drop = guns[weapon.index];
        
        if (oBrain.AmIPseudoHost) 
        {
            // EL HOST MUERE: Llama a la función de drop directamente
            scr_drop_on_death(_weapon_to_drop, x, y);
        } 
        else 
        {
            // EL CLIENTE MUERE: Avisa a todos (el Host procesará el request)
            if (instance_exists(oOtherPlayer)) {
                with(oOtherPlayer) {
                    SendEventToClient(clientId, "request_drop_on_death", {
                        weapon: _weapon_to_drop,
                        x: other.x,
                        y: other.y
                    });
                }
            }
        }
    }

    // ==========================================
    // ESTADO DE MUERTE Y TIMERS
    // ==========================================
    isDead = true;
    state = PLAYERSTATE.DEAD;
    invulnerable = true;
    alarm[1] = 120; // Timer para el Respawn

    var localText  = "";
    var remoteText = "";

    // 1) MUERTE POR MARTILLO
    if (death_reason == "crush")
    {
        localText = "Moriste aplastado";
        remoteText = playerName + " murio aplastado";
    }
    // 2) MUERTE NORMAL (PVP)
    else
    {
        var killerName = (last_killer != "") ? last_killer : "Alguien";
        localText = killerName + " te elimino";
        remoteText = killerName + " elimino a " + playerName;
    }

    // ====== MOSTRAR EN MI PANTALLA ======
    scrAddKillFeed(localText);

    // ====== MANDAR A TODOS LOS DEMÁS (Broadcast Killfeed) ======
    if (global.ONLINE && instance_exists(oOtherPlayer))
    {
        with(oOtherPlayer) {
            SendEventToClient(clientId, "kill_feed", { msg: remoteText });
        }
    }
}

// --- SOLTAR BANDERA AL MORIR (ÚNICA Y DEFINITIVA) ---
if (state == PLAYERSTATE.DEAD && has_flag == true) 
{
    has_flag = false;
    var bandera_robada = (global.myTeam == "AZUL") ? oFlag : oFlag2;
    var drop_x = x; 
    var drop_y = y;

    with (bandera_robada) 
    {
        has_flag = false;
        portador_instancia = noone;
        x = drop_x;
        y = drop_y;
        velocidad_caida = -2; 
        sprite_index = spr_suela;
    }
    
    // HUD: La bandera sigue "robada" (fuera de base), así que no apagamos la alerta aún.

    if (global.ONLINE && instance_exists(oOtherPlayer)) 
    {
        with(oOtherPlayer) {
            SendEventToClient(clientId, "flag_dropped", { 
                team: global.myTeam, 
                dropX: drop_x, 
                dropY: drop_y  
            });
        }
    }
}

// --- CÓDIGO DE CAPTURA MEJORADO ---
var objetivo = (global.myTeam == "AZUL") ? oFlag : oFlag2;

if (!score_pending && place_meeting(x, y, objetivo) && state != PLAYERSTATE.DEAD && !has_flag && !objetivo.has_flag) 
{
    has_flag = true;
    with(objetivo) { 
        has_flag = true;
        portador_instancia = other.id;
    }

    // --- HUD: ACTIVAR ALERTA ---
    if (global.myTeam == "AZUL") global.bandera_roja_robada = true; 
    else global.bandera_azul_robada = true;

    if (instance_exists(oOtherPlayer)) {
        with(oOtherPlayer) {
            SendEventToClient(clientId, "flag_capture", { team: global.myTeam });
        }
    }
}


// --- CÓDIGO DE ANOTACIÓN EN BASE ---
var miBase = (global.myTeam == "AZUL") ? obj_base_blue : obj_base_red;

if (place_meeting(x, y, miBase) && has_flag && !score_pending) 
{
// --- NUEVO: SUMAR A ESTADISTICAS PERSONALES ---
    global.flags_captured += 1; // Sumas una bandera a tu historial
    global.xp += 25;            // Te damos XP por anotar

	#region --- PREPARAR GUARDADO EN LA NUBE ---
	with(oBrain){
	save_state = "prepare";
	save_timer = room_speed; // 1 segundo de espera para no chocar con el input
	}
	#endregion	
	
    score_pending = true; 
    has_flag = false;

    with (objetivo) {
        has_flag = false;
        portador_instancia = noone;
        velocidad_caida = 0;
    }

    if (global.myTeam == "AZUL") global.bandera_roja_robada = false;
    else global.bandera_azul_robada = false;

    var flag_scored = (global.myTeam == "AZUL") ? "ROJA" : "AZUL";

    if (oBrain.AmIPseudoHost) {
        // --- LOGICA DEL HOST ---
        if (global.myTeam == "AZUL") {
            global.puntos_azul++;
            with(oBrain) { marcador_escala_azul = 3; marcador_shake = 15; } // EFECTO SEXY
        } else {
            global.puntos_rojo++;
            with(oBrain) { marcador_escala_rojo = 3; marcador_shake = 15; } // EFECTO SEXY
        }

        has_flag = false; score_pending = false;

        // Reset de banderas (tu código original)
        if (flag_scored == "ROJA") {
            with (oFlag) { x=spawnX; y=spawnY; velocidad_caida=0; has_flag=false; portador_instancia=noone; }
        } else {
            with (oFlag2){ x=spawnX; y=spawnY; velocidad_caida=0; has_flag=false; portador_instancia=noone; }
        }

        with(oOtherPlayer) {
            SendEventToClient(clientId, "sync_score", {
                azul: global.puntos_azul,
                rojo: global.puntos_rojo,
                resetFlag: flag_scored,
            });
        }
        
        score_pending = false;
        var notif = instance_create_layer(0, 0, "Instances", oNotification);
        notif.target_scale = 1.5;
        var miObjetivo = (global.myTeam == "AZUL") ? "ROJA" : "AZUL";
        if (flag_scored == miObjetivo) {
            notif.text = "TU EQUIPO ANOTO!";
            notif.color = c_lime;
        } else {
            notif.text = "EL OTRO EQUIPO ANOTO!";
            notif.color = c_orange;
        }
    } 
    else {
        // --- LOGICA DEL CLIENTE (Envía petición al Host) ---
        with(oOtherPlayer) {
            SendEventToClient(clientId, "request_point", {
                team: (global.myTeam == "AZUL") ? "AZUL" : "ROJA",
                resetFlag: flag_scored
            });
        }
    }
}

// --- DEVOLVER MI BANDERA A BASE ---
var miBandera = (global.myTeam == "AZUL") ? oFlag2 : oFlag;

if (!score_pending && place_meeting(x, y, miBandera) && !miBandera.has_flag && (miBandera.x != miBandera.spawnX)) 
{
	// --- NUEVO: SUMAR A ESTADISTICAS PERSONALES ---
    global.flags_returned += 1; // Sumas una defensa a tu historial
    global.xp += 15;            // Te damos XP por salvarla
	#region --- PREPARAR GUARDADO EN LA NUBE ---
	with(oBrain){
	save_state = "prepare";
	save_timer = room_speed; // 1 segundo de espera para no chocar con el input
	}
	#endregion	
    score_pending = true; 

    if (oBrain.AmIPseudoHost) {
        with(miBandera) { x = spawnX; y = spawnY; }
        
        var notif = instance_create_layer(0, 0, "Instances", oNotification);
        notif.text = "¡SALVASTE TU BANDERA!";
        notif.color = c_aqua;
        notif.target_scale = 1.2;

        with(oOtherPlayer) {
            SendEventToClient(clientId, "sync_score", { 
                azul: global.puntos_azul, 
                rojo: global.puntos_rojo, 
                resetFlag: (global.myTeam == "AZUL") ? "AZUL" : "ROJA",
                reason: "RETORNO" 
            });
        }
        score_pending = false; 
    } 
    else {
        with(oOtherPlayer) {
            SendEventToClient(clientId, "request_point", { 
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
	_TEAM: team,
	_SH: has_shield

};
	
	
	

//Subida de nivel
if (global.xp >= 100) 
{
    global.lvl += 1;
    global.xp -= 100; // Mantiene el sobrante (si tenías 110 XP, te quedas con 10 XP para el siguiente nivel)
    
    // Crear la notificación visual
    if (instance_exists(oNotification)) {
        var notif = instance_create_layer(0, 0, "Instances", oNotification);
        notif.text = "SUBISTE AL NIVEL " + string(global.lvl) + "!";
        notif.color = c_yellow;
        notif.target_scale = 2; // Para que se vea más grande que las de puntos
    }
    
    // --- GUARDADO AUTOMÁTICO AL SUBIR DE NIVEL ---
    ini_open("data.ini");
    ini_write_real("user", "lvl", global.lvl);
    ini_write_real("user", "xp", global.xp);
    ini_close();
    
    //sonido
    if(global.sfx)audio_play_sound(snd_levelup, 1, false);
}
