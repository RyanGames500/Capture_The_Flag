// --- LÓGICA DE INTRO ESTILO BRAWL STARS (Solo Host) ---
if (oBrain.AmIPseudoHost && !intro_disparada) {
    if (timer_intro > 0) {
        timer_intro--;
    } 
    else if (timer_intro == 0) {
        timer_intro = -1; // Desactivar timer
        intro_disparada = true; // No repetir esto en la misma partida

        var listaAzul = (global.myTeam == "AZUL") ? global.myName : "";
        var listaRojo = (global.myTeam == "ROJO") ? global.myName : "";

        with(oOtherPlayer) {
            var nameStr = "Jugador"; 
            if (is_struct(sharedProperties) && variable_struct_exists(sharedProperties, "name")) {
                nameStr = sharedProperties.name;
            } else if (variable_instance_exists(id, "Name") && Name != "") {
                nameStr = Name;
            }
            
            if (team == "AZUL") {
                listaAzul += (listaAzul == "" ? "" : " & ") + nameStr;
            } else {
                listaRojo += (listaRojo == "" ? "" : " & ") + nameStr;
            }
        }

        // MANDAR EL GRITO FINAL A TODOS LOS CLIENTES
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

            // 🔥 CAMBIO: Avisamos a TODOS los clientes que terminó la partida
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

// ======================================================
// 🔨 3. LÓGICA DE MARTILLOS (SOLO HOST)
// ======================================================
if (oBrain.AmIPseudoHost) {
    with(oHammer) {
        if (!ataca && irandom(200) == 1) { 
            ataca = true;
            image_speed = 1;
            
            // 🔥 CAMBIO: Avisar a TODOS los clientes del ataque
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
                // --- SPAWN DE POWERUPS ---
				else if (tipo_spawn == "powerup") {
				    var pick = irandom(1); 
				    var tipo1 = (pick == 0) ? "speed" : "heal";
				    // La función ya se encarga de crear y avisar a todos
				    scr_host_spawn_powerup(x, y, tipo1, myID);
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