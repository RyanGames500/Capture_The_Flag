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
// 📦 4. SISTEMA DE GENERACIÓN DE ARMAS/MUNICIÓN (Solo Host)
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
                
                if (tipo_spawn == "ammo") {
                    host_spawn_ammo(x, y, 25); 
                } 
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
                    host_spawn_weapon(oGun, x, y, _struct_a_usar);
                }
                else if (tipo_spawn == "powerup") {
                    var pick = irandom(1); 
                    var tipo1 = (pick == 0) ? "speed" : "heal";
                    scr_host_spawn_powerup(x, y, tipo1, myID);
                }

                // 🔥 CAMBIO: Avisar a TODOS que este punto se ocupó
                with(oOtherPlayer) {
                    SendEventToClient(clientId, "sync_spawn_point", { 
                        pID: other.myID, 
                        isOcupado: true 
                    });
                }
            }
        }
    }

    // ======================================================
    // 🔄 5. RE-SINCRONIZACIÓN INICIAL (PARA NUEVOS JUGADORES)
    // ======================================================
    if (instance_exists(oOtherPlayer)) 
    {
        if (!variable_instance_exists(id, "sync_done")) sync_done = false;

        if (!sync_done) {
            sync_done = true;
            
            // 🔥 CAMBIO CLAVE: Para cada cliente conectado, mandamos todo lo que ya existe
            with(oOtherPlayer) {
                var targetID = clientId; // Guardamos el ID del cliente al que le hablamos
                
                // Sincronizar Packs de Munición
                with(oAmmoPack) {
                    SendEventToClient(targetID, "spawn_ammo_pack", { uid: net_uid, x: x, y: y, amount: amount });
                }
                
                // Sincronizar Armas en el suelo
                with(oGun) {
                    SendEventToClient(targetID, "spawn_weapon_pickup", { uid: net_uid, x: x, y: y, weapon: weapon });
                }
                
                // Sincronizar puntos de spawn ocupados
                with(oSpawnPoint) {
                    if (ocupado) {
                        SendEventToClient(targetID, "sync_spawn_point", { pID: myID, isOcupado: true });
                    }
                }
                
                // Sincronizar Powerups
                with (oPowerupPickup) {
                    SendEventToClient(targetID, "spawn_powerup", {
                        uid: net_uid, x: x, y: y, tipo: tipo, duration: duration, amount: amount, spawnID: spawn_id
                    });
                }
            }
        }
    } else {
        sync_done = false;
    }
}