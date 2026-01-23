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
		{
		    var uid = theMessageStruct.uid;

		    // evitar duplicados
		    var exists = false;
		    with (oAmmoPack) {
		        if (net_uid == uid) { exists = true;}
		    }
		    if (exists) exit;

		    var a = instance_create_layer(theMessageStruct.x, theMessageStruct.y, "Instances", oAmmoPack);
		    a.net_uid = uid;
		    a.taken   = false;
		    a.amount  = theMessageStruct.amount;
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

 
        case "hit":
		{
		// SI SOY INVULNERABLE, O ESTOY MUERTO, IGNORO EL GOLPE
		if (oPlayer.isDead || oPlayer.invulnerable) exit;
		
            if (oPlayer.state != PLAYERSTATE.DEAD) {
                oPlayer.state = PLAYERSTATE.HIT;
                if(global.sfx==true){audio_play_sound(snd_hit, 20, false, .9);}
                health -= theMessageStruct.damage;
                
                if(health <= 0) {
                    // Si morimos, avisamos a quien nos mató para que sume su kill
                    SendEventToClient(senderClientId, "i_died", {}); 
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
		    if (oBrain.AmIPseudoHost) 
		    {
		        var equipoQuePide = theMessageStruct.team;
		        var banderaAResetear = theMessageStruct.resetFlag;

		        // FILTRO DE SEGURIDAD:
		        // Si el ROJO pide punto, la bandera reseteada DEBE ser la AZUL.
		        // Si pide punto y dice que reseteó la ROJA (su propia bandera), lo ignoramos.
		        if (equipoQuePide == "ROJO" && banderaAResetear == "ROJA") exit; 
		        if (equipoQuePide == "AZUL" && banderaAResetear == "AZUL") exit;

		        // Si pasó el filtro, sumamos
		        if (equipoQuePide == "AZUL") global.puntos_azul++; 
		        else if (equipoQuePide == "ROJO") global.puntos_rojo++;

		        // Reset físico de la bandera
		        if (banderaAResetear == "ROJA") {
		            with (oFlag) { x=spawnX; y=spawnY; has_flag=false; portador_instancia=noone; }
		        } else {
		            with (oFlag2){ x=spawnX; y=spawnY; has_flag=false; portador_instancia=noone; }
		        }

		        var data = { azul: global.puntos_azul, rojo: global.puntos_rojo, resetFlag: banderaAResetear };
		        SendEventToClient(senderClientId, "sync_score", data);
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
			    // IMPORTANTE: NO hagas oPlayer.has_flag=false aquí a lo loco,
			    // solo si TÚ eras el que anotó (si no, le cortas la bandera al que no debe).
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


    }
}