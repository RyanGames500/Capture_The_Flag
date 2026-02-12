function callback_ReceivedEvent(eventName, theMessageStruct, senderClientId) {
    switch(eventName) {

	case "spawn_granada":
	    // 1. Extraer los datos del paquete
	    var _gx    = theMessageStruct.gx;
	    var _gy    = theMessageStruct.gy;
	    var _angle = theMessageStruct.angle;

	    // 2. Crear la granada visual para el cliente
	    // Usamos el mismo objeto oGranada, pero hay que darle velocidad
	    var gra = instance_create_layer(_gx, _gy, "Instances", oGranada);
    
	    // Calculamos la misma trayectoria para que se vea igual en ambas pantallas
	    gra.hsp = lengthdir_x(8, _angle);
	    gra.vsp = lengthdir_y(8, _angle) - 2;
    
	    // IMPORTANTE: Si la granada hace daño por colisión, 
	    // asegúrate de que solo el dueño o el host valide el daño para no duplicarlo.
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
    if (exists) break;

    var p = instance_create_layer(
        theMessageStruct.x,
        theMessageStruct.y,
        "Instances",
        oPowerupPickup
    );

    p.net_uid = uid;
    p.taken   = false;
    p.tipo    = theMessageStruct.tipo;
    p.amount  = theMessageStruct.amount;
    p.duration = theMessageStruct.duration;
}
break;

case "request_powerup":
{
    if (!oBrain.AmIPseudoHost) break;

    var _uid = theMessageStruct.uid;
    var _already = variable_struct_exists(theMessageStruct, "already_applied") ? theMessageStruct.already_applied : false;
    var _fx_ya_hecho = variable_struct_exists(theMessageStruct, "fx_done") ? theMessageStruct.fx_done : false;
    
    var _inst = noone;
    with (oPowerupPickup) { if (net_uid == _uid) { _inst = id; break; } }

    if (_inst != noone) {
        var _tipo_item = _inst.tipo;
        var _item_x = _inst.x;
        var _item_y = _inst.y;

        // 1. Confirmar poder al que lo pidió
        SendEventToClient(senderClientId, "apply_powerup", {
            tipo: _tipo_item,
            is_prediction: _already
        });

        // 2. REPARTIR EL EFECTO VISUAL (Powerup_fx)
        var fxData = { tipo: _tipo_item, targetId: senderClientId };

        // Al que lo tomó: Solo si no lo ha hecho ya
        if (!_fx_ya_hecho) {
            SendEventToClient(senderClientId, "powerup_fx", fxData);
        }

        // Al Host: El Host ejecuta el efecto localmente para ver al cliente brillar
        callback_ReceivedEvent("powerup_fx", fxData, -1);

        // A otros clientes (si tuvieras más de 2 jugadores):
        // Aquí mandarías el fxData a los demás IDs.

        scr_release_spawn_point(_item_x, _item_y);
        instance_destroy(_inst);
    }
}
break;

case "apply_powerup":
{
    // Si el mensaje viene marcado como 'is_prediction', ignoramos la aplicación
    // porque el oPlayer ya lo hizo en la colisión instantáneamente.
    var _is_pred = variable_struct_exists(theMessageStruct, "is_prediction") ? theMessageStruct.is_prediction : false;
    
    if (_is_pred) {
        show_debug_message("Confirmación recibida: El Host validó mi predicción.");
        exit; // Salimos, no aplicamos el efecto dos veces
    }

    var _tipo = theMessageStruct.tipo; 
    var _amount = theMessageStruct.amount;
    var _duration = theMessageStruct.duration;

    with (oPlayer) 
    {
        if (_tipo == "speed") {
            speed_timer = _duration;
            walksp_mult = 1.5;
        } 
        else if (_tipo == "heal") {
            health = min(100, health + _amount);
        }
    }
}
break;

case "powerup_fx":
{
    var _tipo = theMessageStruct.tipo;
    var _targetId = theMessageStruct.targetId;
    var _targetInst = noone;

    // ¿El efecto es para MÍ? (Mi ID local vs el ID del objetivo)
    // Nota: Usa la variable donde guardes TU propio ID de red, 
    // si no tienes global.clientId, usa la que uses para identificarte.
    if (global.clientId == _targetId) { 
        _targetInst = oPlayer.id;
    } else {
        // ¿El efecto es para el OTRO?
        if (instance_exists(oOtherPlayer) && oOtherPlayer.clientId == _targetId) {
            _targetInst = oOtherPlayer.id;
        }
    }

    if (instance_exists(_targetInst)) {
        var _obj = (_tipo == "heal") ? oHealFX : oSpeedFX;
        repeat(8) {
            instance_create_layer(_targetInst.x + random_range(-20, 20), _targetInst.y + random_range(-10, 10), "Instances", _obj);
        }
    }
}
break;

case "powerup_taken":
{
    var uid = theMessageStruct.uid;

    with (oPowerupPickup)
    {
        if (net_uid == uid)
        {
            instance_destroy();
            break;
        }
    }
}
break;

		case "barrel_dead":
		{
		    var _bx = theMessageStruct.bx;
		    var _by = theMessageStruct.by;

		    // Buscamos el barril más cercano a esa posición (con un margen de error pequeño)
		    var _inst = instance_nearest(_bx, _by, oExplosiveBarrel);
    
		    if (_inst != noone) {
		        // Verificamos que sea el barril correcto por distancia (por si hay varios cerca)
		        if (point_distance(_inst.x, _inst.y, _bx, _by) < 5) {
		            // Creamos la explosión visual para este jugador también
		            instance_create_layer(_inst.x, _inst.y, "Weapons", oExplosionFX);
		            if (global.sfx) audio_play_sound(sndMissileExplode, 10, false);
            
		            // Lo destruimos sin ejecutar su código de daño otra vez (porque ya se procesó)
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

		    // 🔥 HOST CREA SU FX
		    scrCreateRocketExplosion(ex, ey);

		    // 🔁 HOST LA REENVÍA
		    if (instance_exists(oOtherPlayer))
		    {
		        SendEventToClient(
		            oOtherPlayer.clientId,
		            "fx_pearl_explosion",
		            { ex: ex, ey: ey }
		        );
		    }
		}
		break;

case "request_fx_explosion":
{
    if (!oBrain.AmIPseudoHost) break;

    var ex = theMessageStruct.ex;
    var ey = theMessageStruct.ey;
    var _isNade = variable_struct_exists(theMessageStruct, "isNade") ? theMessageStruct.isNade : false;

    // Host la crea
    scrCreateRocketExplosion(ex, ey, _isNade);

    // Host la reenvía al cliente incluyendo el dato
    SendEventToClient(senderClientId, "fx_pearl_explosion", {
        ex: ex,
        ey: ey,
        isNade: _isNade
    });
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

		    // ✅ cooldown sincronizado (si no viene, lo dejamos 0)
		    w.no_pickup_timer = (variable_struct_exists(theMessageStruct, "npt")) ? theMessageStruct.npt : 0;
		}
		break;

		case "request_pickup_weapon":
		{
		    if (!oBrain.AmIPseudoHost) break;

		    var uid = theMessageStruct.uid;

		    // Buscar el pickup real en el mundo del host
		    var pick = noone;
		    with (oGun) {
		        if (net_uid == uid) { pick = id; break; }
		    }
    
		    if (pick != noone) 
		    {
		        // 1. Liberamos el punto de spawn para que empiece el cooldown
		        scr_release_spawn_point(pick.x, pick.y);
        
		        // 2. Lo destruimos (Ya NO dropeamos nada, la vieja desaparece)
		        instance_destroy(pick);

		        // 3. Confirmamos al cliente que lo borre de su pantalla
		        SendEventToClient(senderClientId, "weapon_pickup_taken", { uid: uid });
		    }
		}
		break;

		case "weapon_pickup_taken":
		{
		    var uid = theMessageStruct.uid;

		    with (oGun) { // <-- tu objeto pickup real
		        if (net_uid == uid) { instance_destroy(); break; }
		    }
		}
		break;

		case "request_ammo":
		{    if (!oBrain.AmIPseudoHost) exit;
		    var _uid = theMessageStruct.uid;
		    var _inst = noone;

		    with (oAmmoPack) {
		        if (net_uid == _uid) { _inst = id; break; }
		    }

		    if (_inst != noone) {
		        // Liberamos el punto usando la nueva función
		        scr_release_spawn_point(_inst.x, _inst.y);
        
		        // Destruimos y avisamos que se la dio
		        instance_destroy(_inst);
		        SendEventToClient(senderClientId, "ammo_taken", { uid: _uid });
			}
		}
		break;

		case "ammo_taken":
		{
		    var uid = theMessageStruct.uid;

		    with (oAmmoPack) {
		        if (net_uid == uid) { instance_destroy(); break; } // ✅ break aquí
		    }
		}
		break;

		case "sync_spawn_point":
		{    var _id = theMessageStruct.pID;
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
		    // Esto lo ejecuta el CLIENTE al recibir la orden del HOST
		    var uid = theMessageStruct.uid;
		    show_debug_message("--- CLIENTE RECIBIÓ SPAWN: " + string(uid) + " ---");

		    // Evitar duplicados
		    var exists = false;
		    with (oAmmoPack) {
		        if (variable_instance_exists(id, "net_uid") && net_uid == uid) { 
		            exists = true; 
		            break; 
		        }
		    }
    
		    if (!exists) {
		        // IMPORTANTE: Verifica que los nombres (x, y, amount) sean iguales a los que envías
		        var _x = theMessageStruct.x;
		        var _y = theMessageStruct.y;
		        var _amt = theMessageStruct.amount;

		        var a = instance_create_layer(_x, _y, "Instances", oAmmoPack);
		        a.net_uid = uid;
		        a.taken   = false;
		        a.amount  = _amt;
		        show_debug_message("+++ MUNICIÓN CREADA EN CLIENTE EN: " + string(_x) + "," + string(_y));
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
	        var dmg      = theMessageStruct.damage;
	        var killer   = string(theMessageStruct.killer);
	        var reason   = string(theMessageStruct.reason);

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
		    if (!instance_exists(oPlayer)) break;

		    with (oPlayer)
		    {
		        if (isDead || invulnerable) exit;

		        var dmg = real(theMessageStruct.damage);

		        // guardar killer/reason
		        if (is_string(theMessageStruct.killer)) last_killer = theMessageStruct.killer;
		        if (is_string(theMessageStruct.reason)) death_reason = theMessageStruct.reason;
		
		        else death_reason = "pvp";

		        health -= dmg;

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
    
		    // REGLA DE ORO: 
		    // Si captura el AZUL -> Se mueve la ROJA (oFlag)
		    // Si captura el ROJO -> Se mueve la AZUL (oFlag2)
		    var banderaObjetivo = (equipoCapturador == "AZUL") ? oFlag : oFlag2;

		    with(banderaObjetivo) {
		        has_flag = true;
				sprite_index = spr_mano; //Cambio a sprite pequeño
		        // Si el que capturó NO soy yo, el portador es el otro
		        if (equipoCapturador != global.myTeam) {
		            if (instance_exists(oOtherPlayer)) portador_instancia = oOtherPlayer.id;
		        } else {
		            portador_instancia = oPlayer.id;
		        }
		    }
			
			var teamWhoCaptured = theMessageStruct.team;
		    var notif = instance_create_layer(0, 0, "Instances", oNotification);

		    if (teamWhoCaptured == global.myTeam) {
		        // MI EQUIPO capturó la bandera enemiga (Mensaje Sexy de éxito)
		        notif.text = "TIENES LA BANDERA ENEMIGA!";
		        notif.color = c_aqua; // Azul neón
		    } else {
		        // EL ENEMIGO capturó mi bandera (Mensaje Sexy de peligro)
		        notif.text = "CUIDADO! ROBARON TU BANDERA";
		        notif.color = c_red; // Rojo sangre/neón
        
		        //Sonido de alarma
		        //if(global.sfx) audio_play_sound(snd_alarm, 10, false);
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
            if (teamRequest == "AZUL") global.puntos_azul++; else global.puntos_rojo++;
        }

        // Reset físico
        if (flagToReset == "ROJA") with (oFlag) { x=spawnX; y=spawnY; has_flag=false; portador_instancia=noone; }
        else with (oFlag2){ x=spawnX; y=spawnY; has_flag=false; portador_instancia=noone; }

        // El Host crea su propia notificación aquí si él es el que recibe el pedido
        var notif = instance_create_layer(0, 0, "Instances", oNotification);
        if (isSystem) {
            // Si el host es el mismo equipo de la bandera que regresó
            var miColor = (global.myTeam == "AZUL") ? "AZUL" : "ROJA";
            if (flagToReset == miColor) {
                notif.text = "SALVASTE TU BANDERA!";
                notif.color = c_aqua;
            } else {
                notif.text = "EL ENEMIGO RECUPERO SU BANDERA";
                notif.color = c_gray;
            }
        } else {
            notif.text = "EL ENEMIGO ANOTO!";
            notif.color = c_orange;
            notif.target_scale = 1.5;
        }

        // MANDAR SYNC AL CLIENTE
        if (instance_exists(oOtherPlayer)) {
            SendEventToClient(oOtherPlayer.clientId, "sync_score", {
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
    global.puntos_azul = theMessageStruct.azul;
    global.puntos_rojo = theMessageStruct.rojo;
    oPlayer.score_pending = false;
    
    var flag_scored = theMessageStruct.resetFlag; // "ROJA" o "AZUL"
    var reason = variable_struct_exists(theMessageStruct, "reason") ? theMessageStruct.reason : "PUNTO";

    // --- 1. RESET FÍSICO (Para todos) ---
    if (flag_scored == "ROJA") {
        with (oFlag) { has_flag = false; portador_instancia = noone; x = spawnX; y = spawnY; velocidad_caida = 0; }
    } else {
        with (oFlag2) { has_flag = false; portador_instancia = noone; x = spawnX; y = spawnY; velocidad_caida = 0; }
    }

    // --- 2. LÓGICA DE PORTADORES ---
    var miObjetivo = (global.myTeam == "AZUL") ? "ROJA" : "AZUL";
    if (flag_scored == miObjetivo) oPlayer.has_flag = false;
    var objetivoRival = (global.myTeam == "AZUL") ? "AZUL" : "ROJA"; 
    if (flag_scored == objetivoRival && instance_exists(oOtherPlayer)) oOtherPlayer.has_flag = false;

    // --- 3. NOTIFICACIONES DIFERENCIADAS ---
    var notif = instance_create_layer(0, 0, "Instances", oNotification);

    if (reason == "RETORNO") 
    {
        // ¿La bandera que volvió es la de MI equipo?
        var miColor = (global.myTeam == "AZUL") ? "AZUL" : "ROJA";
        
        if (flag_scored == miColor) {
            // FUE MI EQUIPO
            notif.text = "SALVASTE TU BANDERA!";
            notif.color = c_aqua; // Un color que represente éxito aliado
            notif.target_scale = 1.2;
        } else {
            // FUE EL ENEMIGO (Mensaje informativo discreto)
            notif.text = "EL ENEMIGO RECUPERO SU BANDERA";
            notif.color = c_gray;
            notif.target_scale = 0.8;
        }
    } 
    else // CASO: ANOTACIÓN (PUNTO)
    {
        notif.target_scale = 1.5;
        var miBanderaEnemiga = (global.myTeam == "AZUL") ? "ROJA" : "AZUL";
        
        if (flag_scored == miBanderaEnemiga) {
            notif.text = "TU EQUIPO ANOTO!";
            notif.color = c_lime;
        } else {
            notif.text = "EL ENEMIGO ANOTO!";
            notif.color = c_orange;
        }
    }
}
break;

		case "flag_dropped":
		{
		    var equipoQueLaSolto = theMessageStruct.team;
		    var dropX = theMessageStruct.dropX;
		    var dropY = theMessageStruct.dropY;
    
		    // Si el equipo que la soltó es el Azul, la bandera es la Roja (oFlag) y viceversa
		    var bandera = (equipoQueLaSolto == "AZUL") ? oFlag : oFlag2;
    
		    with(bandera) {
		        has_flag = false;
				sprite_index = spr_suela; // ✅ Cambio a sprite grande
		        portador_instancia = noone;
		        x = dropX;
		        y = dropY;
		        velocidad_caida = -2;
		    }
    
		    // También reseteamos el has_flag del otro jugador en nuestra pantalla
		    if (instance_exists(oOtherPlayer)) oOtherPlayer.has_flag = false;
			}
		break;

			// --- Dentro del switch(eventName) ---
		case "finalizar_partida":
		{
			  global.game_over = true;
			  // Cambiamos "data" por "theMessageStruct" que es como se llama en tu función
			  global.winner_team = theMessageStruct.winner;
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

			    // MAPEAR ID → SPRITE (LOCAL)
			    var spr = sprMuzzle_gun;
			    switch (mid)
			    {
			        case "gun":  spr = sprMuzzle_gun; break;
			        case "smg":     spr = sprMuzzle_smg; break;
			        case "escop": spr = sprMuzzle_escop; break;
			    }

			    // crear muzzle flash
			    var m = instance_create_layer(fx_x, fx_y, "Instances", oMuzzleFlash);
			    m.sprite_index = spr;
			    m.image_angle  = ang;

			    // tracer (opcional)
			    var t = instance_create_layer(fx_x, fx_y, "Instances", oTracer);
			    t.direction = ang;
			}
			break;

			case "fx_melee":
			{
			    // Datos que manda el atacante
			    var xx  = theMessageStruct.x;
			    var yy  = theMessageStruct.y;
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




    }
}