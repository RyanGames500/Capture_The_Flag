function callback_ReceivedEvent(eventName, theMessageStruct, senderClientId) {
    switch(eventName) {
        
        case "hit":
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
        break;

        case "i_died":
            // "kills" es una variable local, esto está bien para el marcador visual
            oPlayer.kills++; 
            show_debug_message("¡Confirmación de baja recibida!");
        break;

		case "flag_capture":
		    var equipoCapturador = theMessageStruct.team;
		    // oFlag = Roja (Enemiga para Azul), oFlag2 = Azul (Enemiga para Rojo)
		    var banderaObjetivo = (equipoCapturador == "AZUL") ? oFlag : oFlag2;
    
		    with(banderaObjetivo) {
		        has_flag = true;
        
		        // BUSCAMOS AL DUEÑO REAL:
		        // Si el que capturó NO soy yo (oPlayer), entonces el dueño es oOtherPlayer
		        if (equipoCapturador != global.myTeam) {
		            if (instance_exists(oOtherPlayer)) {
		                portador_instancia = oOtherPlayer.id;
		            }
		        } else {
		            // Si el que capturó SOY YO, el portador es mi oPlayer local
		            portador_instancia = oPlayer.id;
		        }
		    }
		    show_debug_message("Captura sincronizada para equipo: " + equipoCapturador);
		break;

        case "flag_return":
            with(oFlag2) {
                x = spawnX;
                y = spawnY;
                velocidad_caida = 0;
                has_flag = false;
                portador_instancia = noone; // Limpiamos el portador
            }
            show_debug_message("¡Bandera regresada a la base!");
            break;
            
        case "point":
            // Si recibes este evento, significa que el enemigo admite que lo mataste
            // o que anotaste. Úsalo para actualizar marcadores globales.
            if (oBrain.AmIPseudoHost) {
                // El Host decide el puntaje oficial
                global.puntos_azul++;
                // Aquí podrías mandar un SendEventToClient(..., "sync_score", ...)
            }
			break;

			case "request_point":
			    if (oBrain.AmIPseudoHost) 
			    {
			        if (theMessageStruct.team == "AZUL") global.puntos_azul++; else global.puntos_rojo++;

			        var flag_scored = theMessageStruct.resetFlag; // "ROJA" o "AZUL"

			        // Reset SOLO la bandera con la que anotaron
			        if (flag_scored == "ROJA") {
			            with (oFlag) { x=spawnX; y=spawnY; velocidad_caida=0; has_flag=false; portador_instancia=noone; }
			        } else {
			            with (oFlag2){ x=spawnX; y=spawnY; velocidad_caida=0; has_flag=false; portador_instancia=noone; }
			        }

			        // Enviar a cliente score + qué bandera resetear
			        var data = { azul: global.puntos_azul, rojo: global.puntos_rojo, resetFlag: flag_scored };
			        SendEventToClient(senderClientId, "sync_score", data);
			    }
			break;



			case "sync_score":
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
    
			    // Y por seguridad, el otro jugador en mi pantalla también la suelta
			    if (instance_exists(oOtherPlayer)) {
			        oOtherPlayer.has_flag = false;
			    }
			    // IMPORTANTE: NO hagas oPlayer.has_flag=false aquí a lo loco,
			    // solo si TÚ eras el que anotó (si no, le cortas la bandera al que no debe).
			break;

			case "flag_dropped":
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
			break;

			// --- Dentro del switch(eventName) ---
			case "finalizar_partida":
			    global.game_over = true;
			    // Cambiamos "data" por "theMessageStruct" que es como se llama en tu función
			    global.winner_team = theMessageStruct.winner; 
			break;
			
			case "host_abandono":
		    // El host se fue, así que nos desconectamos nosotros también
		    LeaveRoom(); 
			break;
			
			

    }
}