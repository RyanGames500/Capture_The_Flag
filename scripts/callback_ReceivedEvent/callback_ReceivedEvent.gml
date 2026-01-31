function callback_ReceivedEvent(eventName, theMessageStruct, senderClientId) {
    switch(eventName) {


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

		    // buscar pickup real en host
		    var pick = noone;
		    with (oGun) {
		        if (net_uid == uid) { pick = id; break; }
		    }
		    if (pick == noone) break;

		    // destruir pickup en host
		    with (pick) instance_destroy();

		    // si fue SWAP, dropear el arma vieja del cliente
		    if (theMessageStruct.mode == "swap")
		    {
		        var oldW = theMessageStruct.oldWeapon;
		        if (is_struct(oldW))
		        {
		            host_drop_weapon(oldW, theMessageStruct.dropX, theMessageStruct.dropY);
		        }
		    }

		    // confirmar al cliente que se borre su copia del pickup
		    SendEventToClient(senderClientId, "weapon_pickup_taken", { uid: uid });
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
		{
		    if (!oBrain.AmIPseudoHost) exit;

		    var uid = theMessageStruct.uid;

		    var pick = noone;
		    with (oAmmoPack) {
		        if (net_uid == uid) { pick = id; break; } // ✅ break aquí
		    }
		    if (pick == noone) exit;

		    with (pick) instance_destroy();

		    SendEventToClient(senderClientId, "ammo_taken", { uid: uid });
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

case "spawn_ammo_pack":
    var _uid = theMessageStruct.uid;
    var _xx  = theMessageStruct.x; // <--- DEBE USAR LA X DEL HOST
    var _yy  = theMessageStruct.y; // <--- DEBE USAR LA Y DEL HOST

    // Evitar duplicados por ID
    var exists = false;
    with (oAmmoPack) {
        if (net_uid == _uid) { exists = true; break; }
    }
    
    if (!exists) {
        var a = instance_create_layer(_xx, _yy, "Instances", oAmmoPack);
        a.net_uid = _uid;
        a.taken   = false;
        a.amount  = theMessageStruct.amount;
        show_debug_message("CLIENTE: Spawn ammo en " + string(_xx) + "," + string(_yy));
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

            // 1. Sumar puntos (Lógica simplificada para evitar fallos de texto)
            if (teamRequest == "AZUL") {
                global.puntos_azul++;
            } else if (teamRequest == "ROJA" || teamRequest == "SISTEMA") {
                // Si no es azul, asumimos que es el rival (Rojo)
                // Usamos SISTEMA para cuando solo devuelven la bandera sin anotar
                if (teamRequest != "SISTEMA") global.puntos_rojo++;
            }

            // 2. Reset físico de la bandera en el Host
            if (flagToReset == "ROJA") {
                with (oFlag) { x=spawnX; y=spawnY; has_flag=false; portador_instancia=noone; }
            } else {
                with (oFlag2){ x=spawnX; y=spawnY; has_flag=false; portador_instancia=noone; }
            }

            // 3. Notificación Sexy para el Host (Él ve que le anotaron)
            if (teamRequest != "SISTEMA") {
                var notif = instance_create_layer(0, 0, "Instances", oNotification);
                notif.target_scale = 1.5;
                notif.text = "EL ENEMIGO ANOTO!";
                notif.color = c_orange;
            }

            // 4. SYNC TOTAL: Esto es lo que saca al Player 2 del estado "esperando"
            with(oOtherPlayer) {
                SendEventToClient(id.clientId, "sync_score", {
                    azul: global.puntos_azul,
                    rojo: global.puntos_rojo,
                    resetFlag: flagToReset
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

			    if (flag_scored == "ROJA") {
			        with (oFlag) {
			            has_flag = false;
			            portador_instancia = noone;
			            x = spawnX; y = spawnY;
			            velocidad_caida = 0;
			        }
			    } else {
			        with (oFlag2) {
			            has_flag = false;
			            portador_instancia = noone;
			            x = spawnX; y = spawnY;
			            velocidad_caida = 0;
			        }
			    }


				// Si la bandera que se reseteó es la que yo traía, me aseguro de soltarla
			    var miObjetivo = (global.myTeam == "AZUL") ? "ROJA" : "AZUL";
			    if (flag_scored == miObjetivo) {
			        oPlayer.has_flag = false;
			    }
    
				// Solo le quitamos la bandera al oOtherPlayer si la bandera que se reseteó 
				// es la que ÉL traía.
				var objetivoRival = (global.myTeam == "AZUL") ? "AZUL" : "ROJA"; 
				if (flag_scored == objetivoRival && instance_exists(oOtherPlayer)) {
				    oOtherPlayer.has_flag = false;
				}

			// CREAR NOTIFICACIÓN PARA EL CLIENTE
			    var notif = instance_create_layer(0, 0, "Instances", oNotification);
			    notif.target_scale = 1.5;

			    // LÓGICA SEXY: 
			    // Si la bandera que se reseteó es la del ENEMIGO, significa que MI EQUIPO anotó.
			    var miBanderaEnemiga = (global.myTeam == "AZUL") ? "ROJA" : "AZUL";
    
			    if (flag_scored == miBanderaEnemiga) {
			        notif.text = "TU EQUIPO ANOTO!";
			        notif.color = c_lime;
			    } else {
			        notif.text = "EL ENEMIGO ANOTO!";
			        notif.color = c_orange;
			        //if(global.sfx) audio_play_sound(snd_goal_enemy, 10, false);
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