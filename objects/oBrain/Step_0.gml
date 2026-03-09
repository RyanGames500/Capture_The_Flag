// ======================================================
// 🏆 LÓGICA DE VICTORIA Y PAUSA (MODO OFFLINE Y ONLINE)
// ======================================================

// --- 1. ACTIVACIÓN DE PAUSA (ESC) ---
if (keyboard_check_pressed(vk_escape) && !global.game_over && room != rm_menu)
{
    global.pausa = !global.pausa;
    if (global.pausa) {
        window_set_cursor(cr_arrow);
        pause_index = 0; 
    }
}

// --- 2. LÓGICA DEL MENÚ DE PAUSA ---
if (global.pausa) {
    var move = keyboard_check_pressed(vk_down) - keyboard_check_pressed(vk_up);
    var max_index = (global.ONLINE) ? 1 : 2;
    pause_index = clamp(pause_index + move, 0, max_index);

    if (keyboard_check_pressed(vk_enter)) {
        if (global.ONLINE) {
            if (pause_index == 0) global.pausa = false;
            if (pause_index == 1) { 
                var _msg = string(global.myName) + " abandonó la partida!";
                with(oOtherPlayer) { SendEventToClient(clientId, "player_left_msg", { texto: _msg }); }
                LeaveRoom();
            }
        } else {
            switch(pause_index) {
                case 0: global.pausa = false; break;
                case 1: // REINICIAR
                    global.pausa = false;
                    global.puntos_azul = 0; global.puntos_rojo = 0;
                    room_restart();
                break;
                case 2: // SALIR
                    global.pausa = false;
                    global.regresar_a_offline = true;
                    room_goto(rm_menu);
                break;
            }
        }
    }
}


// --- 3. DETECCIÓN DE GANADOR (SOLO OFFLINE) ---
if (global.ONLINE == false && global.game_over == false) {
    // Usamos el valor del menú (6, o el que elijas)
    var limite_off = variable_global_exists("off_flags") ? global.off_flags : 3;
    
    var _ganador_local = 0;
    if (global.puntos_rojo >= limite_off) _ganador_local = 1; 
    if (global.puntos_azul >= limite_off) _ganador_local = 2; 

    if (_ganador_local != 0) {
        global.game_over = true;
        global.winner_team = _ganador_local;
        window_set_cursor(cr_arrow);
        with(oMouseIcon_falso) { window_set_cursor(cr_arrow); }
    }
}

// --- 4. LÓGICA PANTALLA DE VICTORIA (GAME OVER ACTIVO) ---
if (global.game_over == true) {
    if (victory_alpha < 1) victory_alpha += 0.05; 

    if (victory_alpha >= 0.9) {
        if (global.ONLINE) {
            // En Online solo esperamos Enter para salir
            if (keyboard_check_pressed(vk_enter) || keyboard_check_pressed(vk_escape)) {
                LeaveRoom(); // O room_goto(rm_menu)
            }
        } else {
            // En Offline usamos el índice de Reintentar/Salir
            var move = keyboard_check_pressed(vk_down) - keyboard_check_pressed(vk_up);
            victory_index = clamp(victory_index + move, 0, 1);

            if (keyboard_check_pressed(vk_enter)) {
                if (victory_index == 0) {
					// REINTENTAR
					puntos_procesados = false;
                    global.puntos_azul = 0; 
                    global.puntos_rojo = 0;
                    global.game_over = false; 
                    room_restart();
                } else {
					#region Carga local
					scr_load_from_local();
					#endregion
					puntos_procesados = false;
					global.game_over = false; 
                    global.puntos_azul = 0;
                    global.puntos_rojo = 0;
                    global.winner_team = 0;
                    victory_alpha = 0; 
                    
                    global.regresar_a_offline = true; 
                    room_goto(rm_menu);
                }
            }
        }
    }
}
// --- LÓGICA DE SELECCIÓN Y INTRO ---
if (oBrain.AmIPseudoHost && !intro_disparada) {
    
    // 🔥 CAMBIO PARA MULTIJUGADOR: Verificar si ABSOLUTAMENTE TODOS están listos
    var todos_ready = global.mi_listo; // Empezamos asumiendo que yo estoy listo
    
    with(oOtherPlayer) {
        // Si tan solo uno de los otros no ha dado Enter, todos_ready se vuelve falso
        if (variable_instance_exists(id, "isReady")) {
            if (!isReady) todos_ready = false;
        } else {
            // Si por alguna razón no tiene la variable, asumimos que no está listo
            todos_ready = false;
        }
    }

    // Si todos están listos (o el tiempo se acabó), empezamos
    if (todos_ready && timer_intro > 0) { 
        timer_intro = 0; 
    } 

    // 1. Manejo del Cronómetro 
    if (timer_intro > 0) {
        timer_intro--;
        if (timer_intro % 10 == 0) {
            with(oOtherPlayer) {
                SendEventToClient(clientId, "sync_timer", { tiempo: oBrain.timer_intro });
            }
        }
    }
    else if (timer_intro == 0) {
        timer_intro = -1; 
        intro_disparada = true; 

        // --- Recopilar nombres para la Intro (Esto ya te sirve para varios) ---
        var listaAzul = (global.myTeam == "AZUL") ? global.myName : "";
        var listaRojo = (global.myTeam == "ROJO") ? global.myName : "";

        with(oOtherPlayer) {
            var nameStr = (variable_instance_exists(id, "Name")) ? Name : "Jugador";
            if (team == "AZUL") {
                listaAzul += (listaAzul == "" ? "" : " & ") + nameStr;
            } else {
                listaRojo += (listaRojo == "" ? "" : " & ") + nameStr;
            }
        }

        // MANDAR EL GRITO FINAL A TODOS
        with(oOtherPlayer) {
            SendEventToClient(clientId, "sync_names_teams", { 
                azules: listaAzul, 
                rojos: listaRojo 
            });
        }
        
        // El Host activa su intro
        scr_trigger_intro(listaAzul, listaRojo);
    }
}
// ======================================================
// 📜 TEXTOS DE AVISO DE BAJAS (KILL FEED)
// ======================================================
for (var i = array_length(kill_feed)-1; i >= 0; i--)
{
    var it = kill_feed[i];
    it.t++;

    var tin  = kf_in;
    var th   = kf_hold;
    var tout = kf_out;

    if (it.t <= tin)
    {
        var p = it.t / tin;
        it.a = p;
        it.xoff = lerp(-80, 0, p);
        it.yoff = 0;
    }
    else if (it.t <= tin + th)
    {
        it.a = 1;
        it.xoff = 0;
        it.yoff = 0;
    }
    else
    {
        var p2 = (it.t - (tin + th)) / tout;
        it.a = 1 - p2;
        it.xoff = lerp(0, -20, p2);
        it.yoff = lerp(0, -10, p2);
    }

    kill_feed[i] = it;
    if (it.t >= it.life) array_delete(kill_feed, i, 1);
}

// ======================================================
// 🏆 1. LÓGICA MIENTRAS SE JUEGA (SOLO HOST)
// ======================================================
if (global.game_over == false) 
{

	if (oBrain.AmIPseudoHost) 
    {
        var _ganador = 0;
        if (global.puntos_rojo >= 3) _ganador = 1;
        if (global.puntos_azul >= 3) _ganador = 2;

        if (_ganador != 0) 
        {
            global.game_over = true;
            global.winner_team = _ganador;

// EL HOST PROCESA SU PROPIO PROGRESO (Privado)
    if (!puntos_procesados) {
        puntos_procesados = true;
        var mi_equipo = (global.myTeam == "ROJO") ? 1 : 2;
        if (_ganador == mi_equipo) scr_add_victory(); else scr_add_loss();
    }

            // CAMBIO: Avisamos a TODOS los clientes que terminó la partida
            var _data = { winner: _ganador };
            with(oOtherPlayer) {
                SendEventToClient(clientId, "finalizar_partida", _data);
            }
        }
    }
}

// ======================================================
// 📺 2. LÓGICA DE PANTALLA DE VICTORIA (PARA TODOS)
// ======================================================
if (global.game_over == true) 
{
	with(oMouseIcon_falso){window_set_cursor(cr_arrow);}
    if (victory_alpha < 1) victory_alpha += 0.05; 

    if (victory_alpha >= 0.9) 
    {
        if (keyboard_check_pressed(vk_escape)) 
        {
            LeaveRoom();
        }
    }
} 
else 
{
    victory_alpha = 0; 
}

if (oBrain.AmIPseudoHost) {
    with(oHammer) {
        if (!ataca && irandom(200) == 1) { 
            ataca = true;
            image_speed = 1;
            
            // CAMBIO: Avisar a TODOS los clientes del ataque
            var hammerData = { _id: myHammerId };
            with(oOtherPlayer) {
                SendEventToClient(clientId, "hammer_attack", hammerData);
            }
        }
    }
}
    
// ======================================================
// 🔔 ALERTAS (CAPTURA DE BANDERA, ETC)
// ======================================================
for (var i = array_length(alerts)-1; i >= 0; i--)
{
    var it = alerts[i];
    it.t++;

    var tin  = alert_in_frames;
    var th   = alert_hold_frames;
    var tout = alert_out_frames;

    if (it.t <= tin) {
        var p = it.t / tin;
        it.a = p;
        it.yoff = lerp(-18, 0, p);
    }
    else if (it.t <= tin + th) {
        it.a = 1;
        it.yoff = 0;
    }
    else if (it.t <= tin + th + tout) {
        var p2 = (it.t - (tin + th)) / tout;
        it.a = 1 - p2;
        it.yoff = lerp(0, -12, p2);
    }
    else {
        array_delete(alerts, i, 1);
        continue;
    }
    alerts[i] = it;
}

// ======================================================
// 📦 4. SISTEMA DE GENERACIÓN (Solo Host - Tiempo Real)
// ======================================================
if (oBrain.AmIPseudoHost) 
{
    with(oSpawnPoint) 
    {
        if (!ocupado) 
        {
            if (cooldown > 0) {
                cooldown--;
            } else {
                ocupado = true;
                
				// --- SPAWN DE MUNICIÓN ---
				if (tipo_spawn == "ammo") {
				    // Solo llamas a la función. 
				    // Ella crea el objeto en el servidor y le avisa a TODOS los clientes.
				    host_spawn_ammo(x, y, 25); 
				}
				// --- SPAWN DE ARMAS ---
                else if (tipo_spawn == "weapon") {
                    var _struct_a_usar = arma_struct;
                    if (_struct_a_usar == noone) {
                        var _pick = irandom(4);                                         
                        if (_pick == 0)      _struct_a_usar = other.weapon_struct_pistola;
                        else if (_pick == 1) _struct_a_usar = other.weapon_struct_escopeta;
                        else if (_pick == 2) _struct_a_usar = other.weapon_struct_smg;
                        else if (_pick == 3) _struct_a_usar = other.weapon_struct_bazooka;
                        else                 _struct_a_usar = other.weapon_struct_m4;
                    }
                    
                    // Ahora solo llamamos a la función. 
                    // Ella se encarga de crear el objeto Y avisar a todos los clientes.
                    host_spawn_weapon(oGun, x, y, _struct_a_usar);
                }
				//SPAWN DE POWERUPS
				else if (tipo_spawn == "powerup") {
				    // 0: Speed, 1: Heal, 2: Shield, 3: Damage, 4: Ammo
				    var pick = irandom(4); 
				    var tipo_final = "heal";
    
				    if (pick == 0) tipo_final = "speed";
				    if (pick == 1) tipo_final = "heal";
				    if (pick == 2) tipo_final = "shield";
				    if (pick == 3) tipo_final = "damage";
				    if (pick == 4) tipo_final = "ammo";

				    // La función se encarga del resto
				    scr_host_spawn_powerup(x, y, tipo_final, myID);
				}

                // Avisar a todos que el punto se ocupó
                with(oOtherPlayer) {
                    SendEventToClient(clientId, "sync_spawn_point", { pID: other.myID, isOcupado: true });
                }
            }
        }
    }

// ======================================================
    // 🔄 5. RE-SINCRONIZACIÓN (Para jugadores que recién entran)
    // ======================================================
    if (instance_exists(oOtherPlayer)) 
    {
        with(oOtherPlayer) 
        {
            if (!variable_instance_exists(id, "i_am_synced")) 
            {
                i_am_synced = true; 
                var targetID = clientId; 
                
                // 1. Municiones
                with(oAmmoPack) {
                    SendEventToClient(targetID, "spawn_ammo_pack", { uid: net_uid, x: x, y: y, amount: amount });
                }
                
                // 2. Armas
                with(oGun) {
                    if (variable_instance_exists(id, "weapon") && is_struct(weapon)) {
                        SendEventToClient(targetID, "spawn_weapon_pickup", { uid: net_uid, x: x, y: y, weapon: weapon });
                    }
                }
                
                // 3. Powerups (CORREGIDO PARA EVITAR EL CRASH)
                with (oPowerupPickup) {
                    // Verificamos si existe la variable antes de mandarla
                    var _sid = variable_instance_exists(id, "spawn_id") ? id.spawn_id : -1;
                    
                    SendEventToClient(targetID, "spawn_powerup", {
                        uid: net_uid, 
                        x: x, 
                        y: y, 
                        tipo: tipo, 
                        duration: duration, 
                        amount: amount, 
                        spawnID: _sid  // Usamos la variable segura
                    });
                }

                // 4. Spawns ocupados
                with(oSpawnPoint) {
                    if (ocupado) {
                        SendEventToClient(targetID, "sync_spawn_point", { pID: myID, isOcupado: true });
                    }
                }
            }
        }
    }
}

//Guardado en la nube
// --- PROCESADOR DE GUARDADO INVISIBLE ---
if (save_state == "prepare") {
    save_timer--;
    if (save_timer <= 0) {
        save_state = "sending";
    }
}

if (save_state == "sending") {
    // Solo entramos aquí UNA VEZ para disparar el proceso
    if (!variable_instance_exists(id, "nube_guardada") || nube_guardada2 == false) {
        nube_guardada2 = true; // Marcamos que ya empezamos
        
        
        
        alarm[3] = 60; // 2 segundos (si vas a 30fps) o 1 segundo (si vas a 60fps)
        show_debug_message(">>> Guardando en la nube... Alarma 1 iniciada.");
        
        save_state = "waiting"; // <--- CAMBIAMOS A UN ESTADO DE ESPERA
    }
}

// --- LÓGICA DE SELECCIÓN VERTICAL (Actualizada para 4 personajes) ---
if (!intro_disparada && room != rm_menu) {
    if (!global.mi_listo) {
        var move = keyboard_check_pressed(vk_down) - keyboard_check_pressed(vk_up);
        
        if (move != 0) {
            // CAMBIO AQUÍ: Sumamos 4 y usamos % 4 para que el ciclo sea 0, 1, 2, 3
            global.pj_selected = (global.pj_selected + move + 4) % 4; 
            
            // Sonido de cambio (opcional)
            if (global.sfx) audio_play_sound(snd_scroll, 1, false);

            with(oOtherPlayer) {
                SendEventToClient(clientId, "pj_cambiando", { 
                    pj: global.pj_selected, 
                    fromId: global.clientId 
                });
            }
        }

// oBrain - Step Event (Lógica de selección)

if (!global.mi_listo && keyboard_check_pressed(vk_enter)) {
    global.mi_listo = true;
    
    // 1. DETERMINAR POSICIÓN SEGÚN EQUIPO
    var _spawnX, _spawnY;
    
    if (global.myTeam == "AZUL") {
        // Si existe el objeto base, spawnea ahí. Si no, usa una coordenada segura.
        _spawnX = instance_exists(obj_base_blue) ? obj_base_blue.x : 100;
        _spawnY = instance_exists(obj_base_blue) ? obj_base_blue.y : 400;
    } else {
        _spawnX = instance_exists(obj_base_red) ? obj_base_red.x : room_width - 100;
        _spawnY = instance_exists(obj_base_red) ? obj_base_red.y : 400;
    }

    // 2. CREAR AL JUGADOR EN SU BASE
    var myPj = instance_create_layer(_spawnX, _spawnY, "Instances", oPlayer);
    
    // 3. EFECTO VISUAL (Opcional pero recomendado para que no aparezca de golpe)
    var _col = (global.myTeam == "AZUL") ? c_aqua : c_red;
    effect_create_above(ef_ring, _spawnX, _spawnY, 1, _col);

    // 4. AVISAR A LA RED
    if (global.ONLINE) {
        with(oOtherPlayer) {
            SendEventToClient(clientId, "pj_listo", { 
                pj: global.pj_selected, 
                fromId: global.clientId 
            });
        }
    }
    
    if (global.sfx) audio_play_sound(snd_ready, 1, false);
}
    }
}

// Auto-selección al acabarse el tiempo
if (timer_intro == 0 && !global.mi_listo) {
    global.mi_listo = true;
    with(oOtherPlayer) {
        SendEventToClient(clientId, "pj_listo", { 
            pj: global.pj_selected, 
            fromId: global.clientId 
        });
    }
}
	