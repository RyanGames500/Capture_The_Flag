function callback_ReceivedEvent(eventName, theMessageStruct, senderClientId) {
    switch(eventName) {

//Partiva Privada

case "SYNC_LIMIT":
    global.max_players_allowed = theMessageStruct.max;
break;
case "SALA_LLENA":
            // 1. El Host me dijo que me fuera, así que me salgo a mi propia sala sola
            ChangeRoom(string(global.clientId)); 
            
            // 2. Regresamos el menú al estado privado para que pueda intentar otro código
            if (instance_exists(oMenu)) {
                oMenu.menu_state = "private";
                show_message_async("¡SALA LLENA! El límite para este modo es " + string(global.max_players_allowed));
            }
        break;

case "sync_lobby_name":
    var _n = theMessageStruct.nombre;
    // Usamos el nombre que viene, si no viene nada ponemos "Jugador"
    if (is_undefined(_n)) _n = "Jugador..."; 

    var _soyHost = variable_struct_exists(theMessageStruct, "soyHost") ? theMessageStruct.soyHost : false;

    // Actualizar el objeto visual
    with(oOtherPlayer) {
        if (clientId == senderClientId) {
            Name = _n;
            isHost = _soyHost;
        }
    }
    
    // ACTUALIZAR EL MAPA (Para que no salga el nombre viejo de la partida pasada)
    global.playerNames[? string(senderClientId)] = _n;

    // Si yo soy el Host, le respondo al nuevo para que me vea bien
    if (oBrain.AmIPseudoHost && senderClientId != global.clientId) {
        SendEventToClient(senderClientId, "sync_lobby_name", { 
            nombre: global.myName, 
            soyHost: true 
        });
    }
break;

case "sync_names":

    var _cid = theMessageStruct.clientId;
    var _name = theMessageStruct.name;

    global.playerNames[? _cid] = _name;

break;

case "KICK_FROM_ROOM":
    // 1. Salir de la sala actual (pero NO del servidor)
    LeaveRoom(); 
    
    // 2. Resetear variables de sala para que pueda entrar a otra
    global.roomId = -1;
    global.myRoomCode = "";
    
    // 3. Cambiar el estado del menú para que vuelva a la pantalla de "PRIVATE"
    if (instance_exists(oMenu)) {
        oMenu.menu_state = "private"; 
    }
    
    // 4. Limpiar los otros jugadores que veía en ese lobby
    with(oOtherPlayer) instance_destroy();
    
    show_message_async("El líder te ha sacado de la sala.");
break;

case "GO_TO_BATTLE":
    room_goto(rm_stage1);
break;

case "player_left_msg":
    // Extraemos el texto desde theMessageStruct
    var _txt_abandono = variable_struct_exists(theMessageStruct, "texto") ? theMessageStruct.texto : "Alguien abandono";
    
    // Lo mandamos al feed de muertes
    scrAddKillFeed(_txt_abandono);
break;



//Granada crear
case "spawn_granada":
    var _gx    = theMessageStruct.gx;
    var _gy    = theMessageStruct.gy;
    var _angle = theMessageStruct.angle;

    var gra = instance_create_layer(_gx, _gy, "Instances", oGranada);
    
    // Usamos variables consistentes
    gra.direction = _angle;
    gra.speed = 8; 
    gra.gravity = 0.2; // Si tu granada usa gravedad física
    
    // Si usas hsp/vsp manual:
    gra.hsp = lengthdir_x(8, _angle);
    gra.vsp = lengthdir_y(8, _angle) - 2;
    
    // Marcamos que es una granada remota para que no procese daño (solo el dueño daña)
    gra.is_remote = true; 
break;
	
case "sync_names_teams":
{
    var _azules = theMessageStruct.azules;
    var _rojos = theMessageStruct.rojos;

    // Usamos una función para no repetir código
    scr_trigger_intro(_azules, _rojos);
}
break;

//CREAR POWER UPS
case "spawn_powerup":
{
    var uid = theMessageStruct.uid;

    // evitar duplicados
    var exists = false;
    with (oPowerupPickup)
    {
        if (net_uid == uid) { exists = true; break; }
    }
    //if (exists) break;

    var p = instance_create_layer(
        theMessageStruct.x,
        theMessageStruct.y,
        "Instances",
        oPowerupPickup
    );

    p.net_uid = uid;
    p.taken   = false;
    p.tipo    = theMessageStruct.tipo;
    p.amount  = theMessageStruct.amount;
    p.duration = theMessageStruct.duration;
}
break;

case "request_powerup":
{
    if (!oBrain.AmIPseudoHost) break;

    var _uid = theMessageStruct.uid;
    var _sender = senderClientId; // El ID del que hizo la petición
    
    var _inst = noone;
    with (oPowerupPickup) { if (net_uid == _uid) { _inst = id; break; } }

    if (_inst != noone) {
        var _tipo = _inst.tipo;
        var _amt  = _inst.amount;
        var _dur  = _inst.duration;

        // A) Confirmar efecto al cliente que lo pidió
        SendEventToClient(_sender, "apply_powerup", {
            tipo: _tipo,
            amount: _amt,   
            duration: _dur,  
            is_prediction: true
        });

        // B) Avisar a TODOS los demás
        with(oOtherPlayer) {
            // Todos borran el objeto físicamente
            SendEventToClient(clientId, "powerup_taken", { uid: _uid });
            
            // 🔥 El efecto visual debe salir de quien lo agarró (_sender)
            // Se le manda a todos, incluso al que lo agarró (aunque él ya lo hizo local, 
            // su código de apply_powerup o colisión lo maneja)
            SendEventToClient(clientId, "powerup_fx", { tipo: _tipo, targetId: _sender });
        }

        // C) El Host también debe ver el efecto visual del cliente en su pantalla
        // Ejecutamos la lógica de FX manualmente para el Host
        var _host_target = noone;
        with(oOtherPlayer) { if (clientId == _sender) _host_target = id; }
        if (instance_exists(_host_target)) {
             var _obj_fx = oHealFX;
             if (_tipo == "speed")  _obj_fx = oSpeedFX;
             if (_tipo == "shield") _obj_fx = oSpeedFX;
             if (_tipo == "damage") _obj_fx = oSpeedFX;
             if (_tipo == "ammo")   _obj_fx = oSpeedFX;
             repeat(8) {
                 instance_create_layer(_host_target.x + random_range(-20, 20), _host_target.y + random_range(-10, 10), "Instances", _obj_fx);
             }
        }

        scr_release_spawn_point(_inst.x, _inst.y);
        instance_destroy(_inst);
    }
}
break;

case "powerup_fx":
{
    var _tipo = theMessageStruct.tipo;
    var _targetId = theMessageStruct.targetId;
    var _targetInst = noone;

    // 1. ¿El efecto es para MÍ (el cliente que recibe este mensaje)?
    if (global.clientId == _targetId) { 
        _targetInst = oPlayer.id;
    } else {
        // 2. ¿Es para otro jugador?
        with(oOtherPlayer) {
            if (clientId == _targetId) {
                _targetInst = id;
            }
        }
    }

    // 3. Crear partículas
    if (instance_exists(_targetInst)) {
        var _obj = oHealFX;
        if (_tipo == "speed")  _obj = oSpeedFX;
        if (_tipo == "shield") _obj = oSpeedFX;
        if (_tipo == "damage") _obj = oSpeedFX;
        if (_tipo == "ammo")   _obj = oSpeedFX;
        
        repeat(8) {
            instance_create_layer(_targetInst.x + random_range(-20, 20), _targetInst.y + random_range(-10, 10), "Instances", _obj);
        }
    }
}
break;

case "powerup_taken":
{
    var uid = theMessageStruct.uid;
    with (oPowerupPickup) {
        if (net_uid == uid) {
            instance_destroy();

        }
    }
}
break;

case "apply_powerup":
{
    // Si es predicción, a veces es mejor ignorarlo porque oPlayer YA lo hizo en la colisión
    var _is_pred = variable_struct_exists(theMessageStruct, "is_prediction") ? theMessageStruct.is_prediction : false;
    
    // Si eres el que lo recogió, ya tienes el efecto puesto por la colisión local
    if (_is_pred) {
        show_debug_message("Host confirmó mi PowerUp");
    }

    // Si llegas aquí, es porque el Host te ordena aplicarlo (y no fue por colisión local)
    var _tipo = theMessageStruct.tipo;
    var _amount = variable_struct_exists(theMessageStruct, "amount") ? theMessageStruct.amount : 25;
    var _duration = variable_struct_exists(theMessageStruct, "duration") ? theMessageStruct.duration : 300;

    with (oPlayer) {
        if (_tipo == "speed") { speed_timer = _duration; walksp_mult = 1.5; } 
        else if (_tipo == "heal") { health = min(100, health + _amount); }
		else if (_tipo == "shield") { has_shield = true; shield_timer = _duration; }
        else if (_tipo == "damage") { damage_boost = 2; damage_timer = _duration; }
        else if (_tipo == "ammo")   { infinite_ammo = true; ammo_timer = _duration; }
    }
}
break;

case "barrel_dead":
{
    var _bx = theMessageStruct.bx;
    var _by = theMessageStruct.by;

    // Si oBarrilSmall es HIJO de oExplosiveBarrel, 
    // esta línea encontrará a CUALQUIERA de los dos.
    var _inst = instance_nearest(_bx, _by, oExplosiveBarrel); 
    
    if (_inst != noone) {
        if (point_distance(_inst.x, _inst.y, _bx, _by) < 15) {
            
            instance_create_layer(_inst.x, _inst.y, "Weapons", oExplosionFX);
            scrCamShake(10);
            if (global.sfx) audio_play_sound(sndMissileExplode, 10, false);
            
            _inst.hp = 0;
            _inst.exploded = true; 
            instance_destroy(_inst);
        }
    }
}
break;

case "request_rocket_explosion":
{
    if (!oBrain.AmIPseudoHost) break;
    var ex = theMessageStruct.ex;
    var ey = theMessageStruct.ey;
    scrCreateRocketExplosion(ex, ey);

    with(oOtherPlayer) {
        SendEventToClient(clientId, "fx_pearl_explosion", { ex: ex, ey: ey });
    }
}
break;

case "request_fx_explosion":
{
    if (!oBrain.AmIPseudoHost) break;

    var ex = theMessageStruct.ex;
    var ey = theMessageStruct.ey;
    var _isNade = variable_struct_exists(theMessageStruct, "isNade") ? theMessageStruct.isNade : false;
    var _sender = senderClientId;

    // 1. El Host crea su propio efecto
    scrCreateRocketExplosion(ex, ey, _isNade);

    // 2. 🔥 BROADCAST: El Host le avisa a todos los demás clientes
    with(oOtherPlayer) {
        if (clientId != _sender) { // No se lo mandamos al que disparó, él ya lo creó localmente
            SendEventToClient(clientId, "fx_pearl_explosion", {
                ex: ex,
                ey: ey,
                isNade: _isNade
            });
        }
    }
}
break;


case "fx_pearl_explosion":
{
    // Si 'isNade' no existe en el mensaje, nos devuelve 'false' automáticamente
    var _isNade = variable_struct_exists(theMessageStruct, "isNade") ? theMessageStruct.isNade : false;

    scrCreateRocketExplosion(
        theMessageStruct.ex,
        theMessageStruct.ey,
        _isNade 
    );
}
break;

case "fx_shield_hit":
{
    var _ex = theMessageStruct.ex;
    var _ey = theMessageStruct.ey;

    // Todos los que reciben esto crean el efecto visual
    instance_create_layer(_ex, _ey, "Instances", oShieldSparkFX);
    
    // Opcional: Sonido de impacto para los demás
    if (global.sfx) audio_play_sound(snd_shield_impact, 10, false, 1.8);
}
break;

case "spawn_weapon_pickup":
{
    var uid = theMessageStruct.uid;
    var exists = false;
    with (oGun) { if (net_uid == uid) { exists = true; break; } }
    if (exists) break;

    var w = instance_create_layer(theMessageStruct.x, theMessageStruct.y, "Instances", oGun);
    w.net_uid = uid;
    w.taken = false;
    w.weapon = theMessageStruct.weapon;

    if (is_struct(w.weapon)) {
        w.sprite_index = w.weapon.sprite;
        w.image_index  = w.weapon.subimage;
    }

    w.no_pickup_timer = (variable_struct_exists(theMessageStruct, "npt")) ? theMessageStruct.npt : 0;
}
break;

case "request_pickup_weapon":
{
    if (!oBrain.AmIPseudoHost) break;

    var uid = theMessageStruct.uid;
    var pick = noone;
    with (oGun) { if (net_uid == uid) { pick = id; break; } }
    
    if (pick == noone) break;

    // 1. Liberar el spawn point para que pueda reaparecer otra arma después
    scr_release_spawn_point(pick.x, pick.y);
    
    // 2. Destruir pickup en el mundo del host
    instance_destroy(pick);

    // 3. Si fue SWAP, dropear el arma vieja del cliente
    //if (theMessageStruct.mode == "swap")
    //{
    //    var oldW = theMessageStruct.oldWeapon;
    //    if (is_struct(oldW))
    //    {
    //        // Nota: He usado host_drop_weapon porque es el que tenías en tu 1vs1
    //        host_drop_weapon(oldW, theMessageStruct.dropX, theMessageStruct.dropY);
    //    }
    //}

    // 4. 🔥 EL CAMBIO CLAVE: Avisar a TODOS los clientes que borren su copia
    with(oOtherPlayer) {
        SendEventToClient(clientId, "weapon_pickup_taken", { uid: uid });
    }
}
break;

case "weapon_pickup_taken":
{
    var uid = theMessageStruct.uid;
    with (oGun) { 
        if (net_uid == uid) { instance_destroy(); break; } 
    }
}
break;

case "request_ammo":
{
    if (!oBrain.AmIPseudoHost) exit;
    
    var _uid = theMessageStruct.uid;
    var _sender = senderClientId; // El ID del que recogió la munición
    var _inst = noone;

    // 1. Buscar el pack de munición en el Host
    with (oAmmoPack) {
        if (variable_instance_exists(id, "net_uid") && net_uid == _uid) { 
            _inst = id; 
            break; 
        }
    }

    if (_inst != noone) {
        // 2. Liberar el spawn point para que el sistema de respawn sepa que está libre
        scr_release_spawn_point(_inst.x, _inst.y);
        
        // 3. Destruirlo en el Host
        instance_destroy(_inst);
        
        // 4. 🔥 BROADCAST A TODOS MENOS AL QUE LO AGARRÓ
        // (Porque el que lo agarró ya lo borró en su pantalla para evitar lag)
        with(oOtherPlayer) {
            if (clientId != _sender) {
                SendEventToClient(clientId, "ammo_taken", { uid: _uid });
            }
        }
    }
}
break;

case "ammo_taken":
{
    var uid = theMessageStruct.uid;

    // Buscamos y destruimos la copia visual en los demás clientes
    with (oAmmoPack) {
        if (variable_instance_exists(id, "net_uid") && net_uid == uid) { 
            instance_destroy(); 
            break; 
        }
    }
}
break;

		case "sync_spawn_point":
		{    var _id = theMessageStruct.pID;
		    var _state = theMessageStruct.isOcupado;
    
		    with(oSpawnPoint) {
		        if (myID == _id) {
		            ocupado = _state;
		            // IMPORTANTE: El cliente NO debe tocar el cooldown, 
		            // solo esperar a que el host le mande el "spawn_ammo_pack"
		        }
			 }
			}
		break;

		case "point_occupied":
		    // ERROR CORREGIDO: Usamos theMessageStruct en lugar de data
		    var _id = theMessageStruct.pointID; 
		    with(oSpawnPoint) {
		        if (myID == _id) ocupado = true;
		    }
		break;

		case "point_free":
		    // ERROR CORREGIDO: Usamos theMessageStruct en lugar de data
		    var _id = theMessageStruct.pointID;
		    with(oSpawnPoint) {
		        if (myID == _id) {
		            ocupado = false;
		            cooldown = 600; // Ajusta este tiempo igual que en el host
		        }
		    }
		break;

		case "spawn_ammo_pack":
		{
		    var uid = theMessageStruct.uid;
		    show_debug_message("--- CLIENTE RECIBIÓ SPAWN: " + string(uid) + " ---");

		    var exists = false;
		    with (oAmmoPack) {
		        if (variable_instance_exists(id, "net_uid") && net_uid == uid) { exists = true; break; }
		    }
    
		    if (!exists) {
		        var _x = theMessageStruct.x;
		        var _y = theMessageStruct.y;
		        var _amt = theMessageStruct.amount;
		        // Leemos si el Host dijo que es granada (por defecto false si no viene)
		        var _isG = variable_struct_exists(theMessageStruct, "is_grenade") ? theMessageStruct.is_grenade : false;

		        var a = instance_create_layer(_x, _y, "Instances", oAmmoPack);
		        a.net_uid = uid;
		        a.taken   = false;
		        a.amount  = _amt;
		        a.is_grenade_pack = _isG; // Guardamos el estado

		        // Cambiar sprite visualmente en el cliente
		        if (_isG) {
		            a.sprite_index = spr_pack_granadas; 
		        }

		        show_debug_message("+++ MUNICIÓN CREADA (" + (_isG ? "GRANADAS" : "BALAS") + ") EN: " + string(_x) + "," + string(_y));
		    }
		}
		break;

		case "request_drop_on_death":
		{
		    // Solo el host procesa esto
		    if (!oBrain.AmIPseudoHost) break;

		    var _wStruct = theMessageStruct.weapon;
		    var _xx = theMessageStruct.x;
		    var _yy = theMessageStruct.y;

		    // El host ejecuta la función de drop en la posición del cliente
		    scr_drop_on_death(_wStruct, _xx, _yy);
		}
		break;

		case "init_pos_color":
		{
		    var ordered_x = theMessageStruct.x;
		    var ordered_y = theMessageStruct.y;

		    oPlayer.x = ordered_x;
		    oPlayer.y = ordered_y;

		    oPlayer.latest_x = ordered_x;
		    oPlayer.latest_y = ordered_y;

		    // opcional: si usas sharedProperties para publicar
		    if (is_struct(global.sharedProperties)) {
		        global.sharedProperties._x = ordered_x;
		        global.sharedProperties._y = ordered_y;
		    }
		}	
		break;

		case "request_hit":
		{
		    // Solo el Host procesa peticiones de daño
		    if (oBrain.AmIPseudoHost) 
		    {
		        var victimId = theMessageStruct.victimId;
		        var dmg      = theMessageStruct.damage;
		        var killer   = string(theMessageStruct.killer);
		        var reason   = string(theMessageStruct.reason);

		        // El Host le ordena a la víctima que reciba el golpe
		        // (Esto disparará el caso "hit" en la pantalla de la víctima)
		        SendEventToClient(victimId, "hit", {
		            damage: dmg,
		            killer: killer,
		            reason: reason
		        });
        
		        // Opcional: El Host también podría avisarle al atacante que el golpe fue válido
		        // SendEventToClient(senderClientId, "hit_confirmed", {});
		    }
		}
		break;

		case "hit":
		{
		    if (!instance_exists(oPlayer)) exit;

		    with (oPlayer)
		    {
		        if (isDead || invulnerable) exit;

		        var dmg = real(theMessageStruct.damage);

		        // --- 1. LÓGICA DEL ESCUDO (El "Freno") ---
		        if (has_shield) {
		            has_shield = false; // El escudo se rompe
		            shield_timer = 0;   // Reseteamos el timer para que desaparezca la UI
            
		            // Efecto visual de escudo (Impacto azul claro en lugar de rojo)
		            impact_alpha = 0.6;
		            impact_color = c_aqua; 
		            scrCamShake(12); // Sacudida de impacto de escudo
            
		            if (global.sfx) audio_play_sound(snd_hit, 20, false, 1.5); // Sonido más agudo para el escudo
            
		            exit; // <--- IMPORTANTE: Aquí cortamos el código. 
		                  // No se resta vida, no hay flash rojo, ni estado de HIT.
		        }

		        // --- 2. LÓGICA DE DAÑO NORMAL (Si no había escudo) ---
		        if (is_string(theMessageStruct.killer)) last_killer = theMessageStruct.killer;
		        if (is_string(theMessageStruct.reason)) death_reason = theMessageStruct.reason;
		        else death_reason = "pvp";

		        damage_alpha = 0.4; // Flash rojo sexy
		        health -= dmg;

				if(health<=0) and oPlayer.t2=0
				{
				oPlayer.t2=1;
					//if global.sfx = true {audio_play_sound(sndPlayer_Dead,1,0);}
					SendMessageToClient(senderClientId ,  "point")
			
				}

		        if (state != PLAYERSTATE.DEAD)
		        {
		            state = PLAYERSTATE.HIT;
		            if (global.sfx) audio_play_sound(snd_hit, 20, false, .9);
		        }
		    }
		}
		break;

        case "i_died":
		{
            // "kills" es una variable local, esto está bien para el marcador visual
            oPlayer.kills++; 
            show_debug_message("¡Confirmación de baja recibida!");
		}
        break;

		case "flag_capture":
		{
		    var equipoCapturador = theMessageStruct.team;
		    var idDelQueCapturo = senderClientId; // <--- USAMOS EL ID ÚNICO DEL EMISOR
		    var banderaObjetivo = (equipoCapturador == "AZUL") ? oFlag : oFlag2;

		    with(banderaObjetivo) {
		        has_flag = true;
		        sprite_index = spr_mano;
        
		        // ¿Quién la capturó?
		        if (idDelQueCapturo == global.clientId) {
		            // Fui yo mismo (Local)
		            portador_instancia = oPlayer.id;
		        } else {
		            // Fue alguien más. Buscamos EXACTAMENTE a quién entre todos los "Others"
		            var elPortadorReal = noone;
		            with(oOtherPlayer) {
		                if (clientId == idDelQueCapturo) elPortadorReal = id;
		            }
		            portador_instancia = elPortadorReal;
		        }
		    }
    
		    // --- Tus notificaciones se quedan igual ---
		    var notif = instance_create_layer(0, 0, "Instances", oNotification);
		    if (equipoCapturador == global.myTeam) {
		        notif.text = "¡TU EQUIPO TIENE LA BANDERA!";
		        notif.color = c_aqua;
		    } else {
		        notif.text = "¡CUIDADO! ROBARON TU BANDERA";
		        notif.color = c_red;
		    }
		}
		break;

        case "flag_return":
		{
            with(oFlag2) {
                x = spawnX;
                y = spawnY;
                velocidad_caida = 0;
                has_flag = false;
                portador_instancia = noone; // Limpiamos el portador
            }
            show_debug_message("¡Bandera regresada a la base!");
		}
            break;
            
        case "point":
		{
            // Si recibes este evento, significa que el enemigo admite que lo mataste
            // o que anotaste. Úsalo para actualizar marcadores globales.
            if (oBrain.AmIPseudoHost) {
                // El Host decide el puntaje oficial
                global.puntos_azul++;
                // Aquí podrías mandar un SendEventToClient(..., "sync_score", ...)
            }
		}
			break;

case "request_point":
{
    if (oBrain.AmIPseudoHost) {
        var teamRequest = theMessageStruct.team;
        var flagToReset = theMessageStruct.resetFlag;
        var isSystem = (teamRequest == "SISTEMA");

        if (!isSystem) {
            if (teamRequest == "AZUL") {
                global.puntos_azul++;
                // --- EFECTO SEXY PARA EL HOST ---
                with(oBrain) { marcador_escala_azul = 3; marcador_shake = 15; }
            } else {
                global.puntos_rojo++;
                // --- EFECTO SEXY PARA EL HOST ---
                with(oBrain) { marcador_escala_rojo = 3; marcador_shake = 15; }
            }
        }

        // Reset físico de banderas
        if (flagToReset == "ROJA") with (oFlag) { x=spawnX; y=spawnY; has_flag=false; portador_instancia=noone; }
        else with (oFlag2){ x=spawnY; y=spawnY; has_flag=false; portador_instancia=noone; }

        var miObjetivoHost = (global.myTeam == "AZUL") ? "ROJA" : "AZUL";
        if (flagToReset == miObjetivoHost) {
            oPlayer.has_flag = false;
            oPlayer.score_pending = false;
        }

        // Notificaciones...
        var notif = instance_create_layer(0, 0, "Instances", oNotification);
        if (isSystem) {
            var miColor = (global.myTeam == "AZUL") ? "AZUL" : "ROJA";
            if (flagToReset == miColor) { notif.text = "SALVASTE TU BANDERA!"; notif.color = c_blue; }
            else { notif.text = "EL ENEMIGO RECUPERO SU BANDERA"; notif.color = c_gray; }
        } else {
            notif.text = "EL ENEMIGO ANOTO!";
            notif.color = c_red;
            notif.target_scale = 1.5;
        }

        // SYNC A TODOS LOS CLIENTES
        with(oOtherPlayer){
            SendEventToClient(clientId, "sync_score", {
                azul: global.puntos_azul,
                rojo: global.puntos_rojo,
                resetFlag: flagToReset,
                reason: (isSystem) ? "RETORNO" : "PUNTO"
            });
        }
    }
}
break;



case "sync_score":
{
    var flag_scored = theMessageStruct.resetFlag; 
    var reason = variable_struct_exists(theMessageStruct, "reason") ? theMessageStruct.reason : "PUNTO";
    var miObjetivo = (global.myTeam == "AZUL") ? "ROJA" : "AZUL";
    var miColor = (global.myTeam == "AZUL") ? "AZUL" : "ROJA";

    // --- ACTIVAR EFECTO SEXY SEGÚN QUIÉN ANOTÓ ---
    with(oBrain) {
        marcador_shake = 15;
        if (theMessageStruct.azul > global.puntos_azul) marcador_escala_azul = 3;
        if (theMessageStruct.rojo > global.puntos_rojo) marcador_escala_rojo = 3;
    }

    global.puntos_azul = theMessageStruct.azul;
    global.puntos_rojo = theMessageStruct.rojo;

    // Resetear si yo la llevaba
    if (flag_scored == miObjetivo) {
        oPlayer.has_flag = false;
        oPlayer.score_pending = false;
    }
    
    if (flag_scored == miColor) {
        oPlayer.score_pending = false;
    }

    // Reset físico de banderas
    if (flag_scored == "ROJA") {
        with (oFlag) { has_flag = false; portador_instancia = noone; x = spawnX; y = spawnY; velocidad_caida = 0; sprite_index = spr_suela; }
    } else {
        with (oFlag2) { has_flag = false; portador_instancia = noone; x = spawnX; y = spawnY; velocidad_caida = 0; sprite_index = spr_suela; }
    }

    // Notificaciones (lo que ya tenías)
    var notif = instance_create_layer(0, 0, "Instances", oNotification);
    if (reason == "RETORNO") {
        if (flag_scored == miColor) { notif.text = "SALVASTE TU BANDERA!"; notif.color = c_aqua; }
        else { notif.text = "EL ENEMIGO RECUPERO SU BANDERA"; notif.color = c_gray; }
    } else {
        notif.target_scale = 1.5;
        if (flag_scored == miObjetivo) { notif.text = "¡TU EQUIPO ANOTO!"; notif.color = c_lime; }
        else { notif.text = "¡EL ENEMIGO ANOTO!"; notif.color = c_red; }
    }
}
break;

case "flag_dropped":
{
    var equipoQueLaSolto = theMessageStruct.team;
    var dropX = theMessageStruct.dropX;
    var dropY = theMessageStruct.dropY;
    
    // 1. Identificar la bandera (Azul suelta Roja, Rojo suelta Azul)
    var banderaAUsar = (equipoQueLaSolto == "AZUL") ? oFlag : oFlag2;

    if (instance_exists(banderaAUsar)) {
        // Quitamos el IF de seguridad que la bloqueaba y usamos la lógica de limpieza total
        with(banderaAUsar) {
            has_flag = false;
            portador_instancia = noone;
            x = dropX;
            y = dropY;
            velocidad_caida = -2;
            sprite_index = spr_suela;
            
            // Debug por si acaso (puedes quitarlo luego)
            show_debug_message("Bandera soltada por equipo: " + equipoQueLaSolto);
        }
    }

    // 2. 🔥 IMPORTANTÍSIMO: Limpiar a TODOS los oOtherPlayer
    // Si no hacemos esto, el objeto del jugador en la pantalla de los demás
    // sigue pensando que tiene la bandera y la sigue dibujando.
    with(oOtherPlayer) {
        if (variable_instance_exists(id, "thisPlayerTeam") && thisPlayerTeam == equipoQueLaSolto) {
            has_flag = false;
        }
    }
    
    // 3. Si yo soy el que la soltó, me aseguro de estar limpio
    if (global.myTeam == equipoQueLaSolto) {
        oPlayer.has_flag = false;
    }
}
break;

// --- Dentro del switch(eventName) ---
case "finalizar_partida":
{
    global.game_over = true;
    // Usamos theMessageStruct que es tu variable de red
    global.winner_team = theMessageStruct.winner;
    
    // 🏆 PROCESO DE PROGRESO PERSONAL (CLIENTE)
    // El seguro "puntos_procesados" evita que esto se repita
    if (!puntos_procesados) 
    {
        puntos_procesados = true;
        
        var mi_equipo_num = (global.myTeam == "ROJO") ? 1 : 2;
        
        if (global.winner_team == mi_equipo_num) {
            scr_add_victory(); // El cliente suma sus +25 copas y XP
        } else {
            scr_add_loss();    // El cliente resta sus -15 copas
        }
        
        show_debug_message(">>> CLIENTE: Progreso personal actualizado.");
    }
}
break;
			
			case "host_abandono":
		    // El host se fue, así que nos desconectamos nosotros también
		    LeaveRoom(); 
			break;
			
case "fx_shot":
{
    var fx_x = theMessageStruct.x;
    var fx_y = theMessageStruct.y;
    var ang  = theMessageStruct.ang;
    var mid  = theMessageStruct.muzzle;

    // Mapeo de Sprites
    var spr = sprMuzzle_smg;
    switch (mid) {
        case "gun":   spr = sprMuzzle_gun; break;
        case "smg":   spr = sprMuzzle_smg; break;
        case "escop": spr = sprMuzzle_escop; break;
        case "m4":    spr = sprMuzzle_smg; break; // Puedes usar el de smg
    }

    var m = instance_create_layer(fx_x, fx_y, "Instances", oMuzzleFlash);
    m.sprite_index = spr;
    m.image_angle  = ang;
    if (mid == "bazooka") m.image_xscale = 2; // Efecto más grande para bazooka

    // Tracer corregido: necesita x1, y1, x2, y2 para dibujarse
    var len = 60;
    var t = instance_create_layer(fx_x, fx_y, "Instances", oTracer);
    t.x1 = fx_x;
    t.y1 = fx_y;
    t.x2 = fx_x + lengthdir_x(len, ang);
    t.y2 = fx_y + lengthdir_y(len, ang);
}
break;

			case "fx_melee":
			{
			    // Datos que manda el atacante
			    var xx  = theMessageStruct.x;
			    var yy  = theMessageStruct.y;
			    var dir = theMessageStruct.dir; // -1 o 1

			    // Creamos SOLO el efecto visual
			    var fx = instance_create_layer(xx, yy, "Instances", oMeleeFX);
			    fx.image_xscale = dir;
			}
			break;

			case "hammer_attack":
			    var _hid = theMessageStruct._id;
    
			    // Buscamos el martillo que tenga ese ID de posición
			    with(oHammer) {
			        if (myHammerId == _hid) {
			            ataca = true;
			            image_index = 0; // Reiniciamos para que empiecen igualitos
			            image_speed = 1;
			        }
			    }
			break;

case "kill_event":
{
    scrOnKillEvent(theMessageStruct);
}
break;


case "player_emote":
{
    var _oid = theMessageStruct.ownerId;
    var _idx = theMessageStruct.emoteIndex;
    var _inst = noone;

    // Buscar quién lo envió
    with(oOtherPlayer) {
        if (clientId == _oid) _inst = id;
    }
    
    // Si lo encontramos (y no somos nosotros), lo creamos
    if (_inst != noone) {
        var _e = instance_create_layer(_inst.x, _inst.y - 40, "Instances", oEmote);
        _e.image_index = _idx;
        _e.owner = _inst;
    }
}
break;

    }
}