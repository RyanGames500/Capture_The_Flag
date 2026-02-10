//textos de aviso de bajas
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

// --- 1. LÓGICA MIENTRAS SE JUEGA (SOLO HOST) ---
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

            // Avisamos al cliente
            var _data = { winner: _ganador };
            if (instance_exists(oOtherPlayer)) {
                SendEventToClient(oOtherPlayer.clientId, "finalizar_partida", _data);
            }
        }
    }
}

// --- 2. LÓGICA DE PANTALLA DE VICTORIA (PARA TODOS) ---
if (global.game_over == true) 
{
    // Aparecer suavemente (fade in)
    if (victory_alpha < 1) {
        victory_alpha += 0.05; 
    }

    // Acciones cuando la pantalla ya es visible
    if (victory_alpha >= 0.9) 
    {
        if (keyboard_check_pressed(vk_escape)) 
        {
            /* Si soy el Host, le aviso al cliente que nos vamos
            if (oBrain.AmIPseudoHost && instance_exists(oOtherPlayer)) {
                SendEventToClient(oOtherPlayer.clientId, "host_abandono", {});
            }*/
            
            // Ambos ejecutan esto para cerrar su socket y limpiar
            LeaveRoom();
        }
    }
} 
else 
{
    victory_alpha = 0; // Reset si no hay game over
}


if (oBrain.AmIPseudoHost) {
    with(oHammer) {
        // Si el martillo está quieto, hay una pequeña chance de que ataque
        if (!ataca && irandom(200) == 1) { 
            ataca = true;
            image_speed = 1;
            
            // AVISAR A LOS DEMÁS
            var hammerData = { _id: myHammerId };
            with(oOtherPlayer) {
                SendEventToClient(id.clientId, "hammer_attack", hammerData);
            }
        }
    }
}
	
//Alertas Actualizar animacioes (Flag Capture etc)
for (var i = array_length(alerts)-1; i >= 0; i--)
{
    var it = alerts[i];
    it.t++;

    var tin  = alert_in_frames;
    var th   = alert_hold_frames;
    var tout = alert_out_frames;

    if (it.t <= tin)
    {
        var p = it.t / tin;
        it.a = p;
        it.yoff = lerp(-18, 0, p);
    }
    else if (it.t <= tin + th)
    {
        it.a = 1;
        it.yoff = 0;
    }
    else if (it.t <= tin + th + tout)
    {
        var p2 = (it.t - (tin + th)) / tout;
        it.a = 1 - p2;
        it.yoff = lerp(0, -12, p2);
    }
    else
    {
        array_delete(alerts, i, 1);
        continue;
    }

    alerts[i] = it;
}

// --- SISTEMA DE GENERACIÓN DE ARMAS Y MUNICIÓN (Solo Host) ---
if (oBrain.AmIPseudoHost) 
{
    // 1. LÓGICA DE LOS PUNTOS DE SPAWN
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
				        // Subimos a irandom(4) porque ahora tenemos 5 opciones (0, 1, 2, 3, 4)
				        var _pick = irandom(4);                        
        
				        if (_pick == 0)      _struct_a_usar = other.weapon_struct_pistola;
				        else if (_pick == 1) _struct_a_usar = other.weapon_struct_escopeta;
				        else if (_pick == 2) _struct_a_usar = other.weapon_struct_smg;
				        else if (_pick == 3) _struct_a_usar = other.weapon_struct_bazooka;
				        else                 _struct_a_usar = other.weapon_struct_m4; // <--- LA NUEVA M4
				    }
    
				    host_spawn_weapon(oGun, x, y, _struct_a_usar);
				}
				else if (tipo_spawn == "powerup")
				{

				    var pick = irandom(1); // 0 o 1
				    var tipo1 = (pick == 0) ? "speed" : "heal";

				    scr_host_spawn_powerup(x, y, tipo1, myID);
				}



                if (instance_exists(oOtherPlayer)) {
                    SendEventToClient(oOtherPlayer.clientId, "sync_spawn_point", { 
                        pID: myID, 
                        isOcupado: true 
                    });
                }
            }
        }
    }

    // 2. RE-SINCRONIZACIÓN INICIAL
    if (instance_exists(oOtherPlayer)) 
    {
        if (!variable_instance_exists(id, "sync_done")) sync_done = false;

        if (!sync_done) {
            sync_done = true;
            
            with(oAmmoPack) {
                SendEventToClient(oOtherPlayer.clientId, "spawn_ammo_pack", {
                    uid: net_uid, x: x, y: y, amount: amount
                });
            }
            
            with(oGun) {
                SendEventToClient(oOtherPlayer.clientId, "spawn_weapon_pickup", {
                    uid: net_uid, x: x, y: y, weapon: weapon
                });
            }
            
            with(oSpawnPoint) {
                if (ocupado) {
                    SendEventToClient(oOtherPlayer.clientId, "sync_spawn_point", { 
                        pID: myID, isOcupado: true 
                    });
                }
            }
			with (oPowerupPickup)
			{
			    SendEventToClient(oOtherPlayer.clientId, "spawn_powerup", {
			        uid: net_uid,
			        x: x,
			        y: y,
			        tipo: tipo,
			        duration: duration,
			        amount: amount,
			        spawnID: spawn_id
			    });
			}

			
        }
    } else {
        sync_done = false;
    }
}