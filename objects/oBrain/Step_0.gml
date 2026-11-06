// --- MUSICA: cual suena ahorita (scr_fx) ---
scr_musica_step();

// --- AVISO DE RED: revisa cuánto hace que el servidor no responde ---
scr_red_step();

// --- RELOJ DE PARTIDA (lo lleva el líder) ---
scr_reloj_step();

// --- BOTS DE LA SALA PRIVADA (scr_objetivo): el lider los mueve y le manda a todos como van ---
// Si el lider anterior se fue, ahora los muevo yo desde donde iban.
if (global.ONLINE && room != rm_menu && AmIPseudoHost) {
    with (oOtherPlayer) if (es_bot && !bot_local) scr_botnet_tomar();
    scr_botnet_enviar();
}

// --- BOT: si en partida rápida nadie entra en unos segundos, juegas contra un bot ---
if (scr_bot_esperando()) {
    if (bot_espera == 0) bot_espera_max = room_speed * irandom_range(BOT_ESPERA_MIN, BOT_ESPERA_MAX);
    bot_espera++;
    if (bot_espera >= bot_espera_max) scr_bot_empezar();
} else {
    bot_espera = 0;
}

// --- CONTRA EL BOT: selección de personaje e intro (igual que en línea) ---
scr_bot_selec_step();

// ======================================================
// 🏆 LÓGICA DE VICTORIA Y PAUSA (MODO OFFLINE Y ONLINE)
// ======================================================

// --- 1. ACTIVACIÓN DE PAUSA (ESC) ---
if (vkey_pressed(vk_escape) && !global.game_over && room != rm_menu)
{
    global.pausa = !global.pausa;
    if (global.pausa) {
        window_set_cursor(cr_arrow);
        pause_index = 0; 
    }
}

// --- 2. LÓGICA DEL MENÚ DE PAUSA ---
if (global.pausa) {
    var move = vkey_pressed(vk_down) - vkey_pressed(vk_up);
    var max_index = (global.ONLINE || global.bot_partida) ? 1 : 2;
    pause_index = clamp(pause_index + move, 0, max_index);

    if (vkey_pressed(vk_enter)) {
        if (global.ONLINE && scr_botq_activa()) {
            // Partida rapida contra el bot nuevo: CONTINUAR o SALIR (ya estas solo en tu sala)
            if (pause_index == 0) global.pausa = false;
            if (pause_index == 1) { global.pausa = false; scr_bot_salir(false); }
        } else if (global.ONLINE) {
            if (pause_index == 0) global.pausa = false;
            if (pause_index == 1) { 
                var _msg = string(global.myName) + " Abandono la Partida!";
                with(oOtherPlayer) { SendEventToClient(clientId, "player_left_msg", { texto: _msg }); }
                LeaveRoom();
            }
        } else if (global.bot_partida) {
            // Contra el bot: CONTINUAR o SALIR (sin reiniciar)
            if (pause_index == 0) global.pausa = false;
            if (pause_index == 1) { global.pausa = false; scr_bot_salir(false); }
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

    if (_ganador_local != 0) 
    {
        global.game_over = true;
        global.winner_team = _ganador_local;
        window_set_cursor(cr_arrow);

        // Contra el bot de partida rápida: copas y XP (menos que contra una persona)
        if (global.bot_partida && !puntos_procesados) {
            puntos_procesados = true;
            var _mi_eq = (global.myTeam == "ROJO") ? 1 : 2;
            scr_bot_premio(_ganador_local == _mi_eq);
        }
        with(oMouseIcon_falso) { window_set_cursor(cr_arrow); }
    }
}

// --- 4. LÓGICA PANTALLA DE VICTORIA (MODIFICADA) ---
// --- PUNTO GANADOR: festejo (camara se acerca, CAPTURA!, confeti) antes de los resultados (scr_fx) ---
scr_fin_festejo_step();

if (global.game_over == true && !abandono_activo && !scr_fin_festejo_activo()) {
    if (victory_alpha < 1) victory_alpha += 0.05; 

    if (victory_alpha >= 0.9) {
        
        if (AmIPseudoHost) {
            with(oOtherPlayer) {
                if (es_bot) continue;   // un bot no tiene tag para la solicitud de amistad
                SendEventToClient(clientId, "identificar_rival", { 
                    rival_tag: global.miFriendTag, 
                    rival_nombre: global.myName
                });
                global.ultimo_rival_tag = string(self.TAG); 
                global.ultimo_rival_nombre = string(self.Name);
            }
        }

        // --- NAVEGACION DE BOTONES (los botones dependen del modo: scr_fin_opciones) ---
        var _ops = scr_fin_opciones();
        var move = vkey_pressed(vk_right) - vkey_pressed(vk_left);
        victory_index = clamp(victory_index + move, 0, array_length(_ops) - 1);

        // --- ACCION AL PRESIONAR ENTER ---
        if (vkey_pressed(vk_enter)) {
            switch (_ops[victory_index]) {
                case "ENVIAR SOLICITUD": // partida rapida en linea
                    if (global.ultimo_rival_tag != "") {
                        ultimo_intento_busqueda = global.ultimo_rival_tag; 
                        estado_busqueda = "encontrado";
                        datos_busqueda_resultado = {}; 

                        if (is_struct(datos_busqueda_resultado)) {
                            var id_rival = string(ultimo_intento_busqueda); 
                            scr_enviar_solicitud_amistad(id_rival); 
                            
                            // Reset de variables de búsqueda
                            estado_busqueda = "idle";
                            friends_search_input = "";
                            datos_busqueda_resultado = -1; 
                            
                            mensaje_texto = "SOLICITUD ENVIADA!";
                            mensaje_alpha = 3;
                            
                            // Movemos el foco al botón SALIR automáticamente tras enviar
                            victory_index = 1; 
                        }
                    } else {
                        mensaje_texto = "No se encontro el Tag del rival";
                        mensaje_alpha = 2;
                    }
                break;

                case "BUSCAR RIVAL": // contra el bot de partida rapida
                    scr_bot_salir(true);
                break;

                case "REINTENTAR": // local
                    puntos_procesados = false;
                    global.puntos_azul = 0; 
                    global.puntos_rojo = 0;
                    global.game_over = false; 
                    room_restart();
                break;

                case "SALIR":
                    if (scr_botq_activa()) {
                        scr_bot_salir(false);   // partida rapida contra el bot nuevo
                    } else if (global.ONLINE) {
                        LeaveRoom();
                    } else if (global.bot_partida) {
                        scr_bot_salir(false);
                    } else {
                        scr_load_from_local();
                        puntos_procesados = false;
                        global.game_over = false; 
                        global.puntos_azul = 0;
                        global.puntos_rojo = 0;
                        global.winner_team = 0;
                        victory_alpha = 0; 
                        global.regresar_a_offline = true; 
                        room_goto(rm_menu);
                    }
                break;
            }
        }
        
        // Salir rápido con ESC
        if (vkey_pressed(vk_escape) && !abandono_activo){
            if (global.ONLINE) LeaveRoom(); else if (global.bot_partida) scr_bot_salir(false); else room_goto(rm_menu);
        }
    }
}
// --- LÓGICA DE SELECCIÓN Y INTRO ---
// Solo en el mapa: en el menú el contador no debe correr
// En línea el contador solo corre cuando ya hay rival (si estoy solo esperando, no arranca la partida sin nadie)
if (oBrain.AmIPseudoHost && !intro_disparada && room != rm_menu && global.ONLINE && instance_exists(oOtherPlayer)) {
    
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
        var listaAzul = (scr_my_team() == "AZUL") ? global.myName : "";   // mi equipo de esta sala (antes podia ser el de la partida anterior)
        var listaRojo = (scr_my_team() == "ROJO") ? global.myName : "";

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
        var _lim = scr_banderas_para_ganar();   // lo elige el líder en la sala (3 en partida rápida)
        if (global.puntos_rojo >= _lim) _ganador = 1;
        if (global.puntos_azul >= _lim) _ganador = 2;
        // Se acabó el tiempo: gana el que va arriba. Si van empatados, sigue (muerte súbita)
        // y la siguiente bandera rompe el empate.
        if (_ganador == 0 && reloj_fin && global.puntos_rojo != global.puntos_azul) {
            _ganador = (global.puntos_rojo > global.puntos_azul) ? 1 : 2;
        }

        if (_ganador != 0) 
        {
            global.game_over = true;
            global.winner_team = _ganador;

// EL HOST PROCESA SU PROPIO PROGRESO (Privado)
    if (!puntos_procesados) {
        puntos_procesados = true;
        var mi_equipo = (global.myTeam == "ROJO") ? 1 : 2;
        scr_botnet_premio(_ganador == mi_equipo);   // con bots en la sala, premio de partida contra bots (scr_objetivo)
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
    if (victory_alpha < 1 && !scr_fin_festejo_activo()) victory_alpha += 0.05;   // espera al festejo del punto ganador (scr_fx)

    if (victory_alpha >= 0.9) 
    {
        if (vkey_pressed(vk_escape)) 
        {
            LeaveRoom();
        }
    }
} 
else 
{
    victory_alpha = 0; 
}

// Las prensas (oHammer) ahora deciden solas cuándo caen y avisan con "hammer_go" (ver scr_prensa)
    
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
        // a) Las armas fuertes (nivel 3) esperan 20 segundos al empezar la partida
        if (primera_vez) {
            primera_vez = false;
            if (tipo_spawn == "weapon" && nivel == 3 && !ocupado) {
                cooldown = scr_spawn_primera_espera();
                cooldown_max = cooldown;
                scr_spawn_point_enviar(id);
            }
        }

        // b) ¿Se llevaron lo que puse? (lo agarraron o desapareció) -> el punto queda libre y empieza su reloj
        if (ocupado) {
            if (mi_item == noone) mi_item = scr_spawn_point_item_cerca();   // por si me tocó ser host a mitad de partida
            if (mi_item == noone || !instance_exists(mi_item)) {
                mi_item = noone;
                ocupado = false;
                cooldown = scr_spawn_frames(tipo_spawn, nivel);
                cooldown_max = cooldown;
                scr_spawn_point_enviar(id);
            }
        }

        // c) Libre: contar y, al llegar a cero, poner algo
        if (!ocupado) 
        {
            if (cooldown > 0) {
                cooldown--;
            } else {
                var _nuevo = noone;
                
				// --- SPAWN DE MUNICIÓN ---
				if (tipo_spawn == "ammo") {
				    // Crea el objeto en el host y le avisa a TODOS los clientes.
				    _nuevo = host_spawn_ammo(x, y, 25); 
				}
				// --- SPAWN DE ARMAS ---
                else if (tipo_spawn == "weapon") {
                    var _struct_a_usar = arma_struct;
                    if (_struct_a_usar == noone) {
                        // Según el nivel del punto (scr_armas): 1 pistolas/subfusiles, 2 rifles/escopetas, 3 fuertes, 0 de todo
                        _struct_a_usar = scr_arma_al_azar(nivel);
                    }
                    _nuevo = host_spawn_weapon(oGun, x, y, _struct_a_usar);

                    // Aviso arriba cuando sale un arma fuerte (a todos)
                    if (nivel == 3 && _nuevo != noone) {
                        var _txt = scr_arma_nombre(_struct_a_usar) + " EN EL CENTRO";
                        scrAddAlert(_txt, c_orange);
                        with(oOtherPlayer) SendEventToClient(clientId, "aviso_arma", { txt: _txt });
                    }
                }
				// --- SPAWN DE PODERES ---
				else if (tipo_spawn == "powerup") {
				    // Según el nivel del punto (scr_armas): 1 curación/velocidad, 2 escudo/daño/balas, 0 todos
				    _nuevo = scr_host_spawn_powerup(x, y, scr_poder_al_azar(nivel), myID);
				}

                if (_nuevo != noone && instance_exists(_nuevo)) {
                    mi_item = _nuevo;
                    ocupado = true;
                    cooldown = 0;
                    cooldown_max = 0;
                    // Avisar a todos que el punto se ocupó
                    scr_spawn_point_enviar(id);
                } else {
                    // No se pudo crear: probar otra vez en 1 segundo
                    cooldown = game_get_speed(gamespeed_fps);
                    cooldown_max = 0;
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

                // 4. Puntos de spawn (ocupados y los que van contando, para que vea los anillos)
                with(oSpawnPoint) scr_spawn_point_enviar(id, targetID);
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
// Solo en línea o contra el bot (en el modo local no hay selección de personaje)
if (!intro_disparada && room != rm_menu && (global.ONLINE || global.bot_partida)) {
    if (!global.mi_listo) {
        var move = vkey_pressed(vk_down) - vkey_pressed(vk_up);
        
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

if (global.bot_partida && !global.mi_listo && vkey_pressed(vk_enter)) {
    // Contra el bot: tu jugador ya está en el mapa, solo quedas listo
    global.mi_listo = true;
    if (global.sfx) audio_play_sound(snd_ready, 1, false);
}
else if (!global.mi_listo && vkey_pressed(vk_enter)) {
    global.mi_listo = true;
    
    // 1. DETERMINAR POSICIÓN SEGÚN EQUIPO
    var _spawnX, _spawnY;
    
    // Mi equipo de ESTA sala (global.myTeam podia traer el de la partida anterior y te ponia en la base equivocada)
    global.myTeam = scr_my_team();
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


// ======================================================
// 🚪 ABANDONO: si un equipo se queda sin jugadores, gana el otro
// ======================================================
if (abandono_check > 0) {
    abandono_check--;
    if (abandono_check == 0) {
        abandono_check = -1;

        if (global.ONLINE && room != rm_menu && !global.game_over && global.myTeam != "") {
            var _mios = 1;      // yo
            var _rivales = 0;
            with (oOtherPlayer) {
                if (team == global.myTeam) _mios++; else _rivales++;
            }

            // Solo si el equipo rival quedó VACÍO (1 vs 2 sigue siendo jugable)
            if (_rivales == 0) {
                var _empezada = intro_disparada; // ¿ya pasó la selección de personaje?

                global.game_over = true;
                global.pausa = false;
                global.winner_team = (global.myTeam == "ROJO") ? 1 : 2;

                abandono_gano = _empezada;
                if (_empezada && !puntos_procesados) {
                    puntos_procesados = true;
                    scr_botnet_premio(true); // mismos trofeos y XP que una victoria normal (con bots: premio contra bots)
                }

                if (_empezada) {
                    abandono_titulo = "VICTORIA";
                    abandono_texto  = (_mios > 1) ? "El equipo rival abandono la partida" : "Tu rival abandono la partida";
                } else {
                    abandono_titulo = "PARTIDA CANCELADA";
                    abandono_texto  = "El rival se fue antes de empezar";
                }

                abandono_activo = true;
                abandono_total  = room_speed * 5; // 5 segundos de aviso
                abandono_timer  = abandono_total;
                window_set_cursor(cr_arrow);
                if (global.sfx) audio_play_sound(snd_hit, 20, false, 0.6);
            }
        }
    }
}

if (abandono_activo && room != rm_menu) {
    abandono_timer--;
    // Enter o ESC para salir antes
    if (abandono_timer <= 0 || vkey_pressed(vk_enter) || vkey_pressed(vk_escape)) {
        abandono_activo = false;
        LeaveRoom();
    }
}

//efectos de paso, salto lo que sea perro
fx_step();

// Banners, anotación y avisos chicos (scr_feedback)
fb_step();


// 📦 Pedir munición/armas/power-ups al host después de cargar el mapa
if (variable_instance_exists(id, "resync_left") && resync_left > 0 && global.ONLINE && room != rm_menu) {
    if (AmIPseudoHost) {
        resync_left = 0;
    } else {
        resync_cd--;
        if (resync_cd <= 0) {
            var _h = scr_get_host_id();
            if (_h != -1) SendEventToClient(_h, "request_resync", {});
            resync_left--;
            resync_cd = 60;
        }
    }
}