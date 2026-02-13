function callback_ReceivedEvent(eventName, theMessageStruct, senderClientId) {
    switch(eventName) {

        case "spawn_granada":
            var _gx    = theMessageStruct.gx;
            var _gy    = theMessageStruct.gy;
            var _angle = theMessageStruct.angle;
            var gra = instance_create_layer(_gx, _gy, "Instances", oGranada);
            gra.hsp = lengthdir_x(8, _angle);
            gra.vsp = lengthdir_y(8, _angle) - 2;
        break;
        
        case "sync_names_teams":
            var _azules = theMessageStruct.azules;
            var _rojos = theMessageStruct.rojos;
            scr_trigger_intro(_azules, _rojos);
        break;

        // --- POWER UPS ---
		case "spawn_powerup":
            var uid = theMessageStruct.uid;
            var exists = false;
            
            // 1. Verificar si ya existe para no duplicar
            with (oPowerupPickup) { if (net_uid == uid) { exists = true; break; } }
            if (exists) break;

            // 2. Crear el objeto
            var p = instance_create_layer(theMessageStruct.x, theMessageStruct.y, "Instances", oPowerupPickup);
            
            // 3. ASIGNAR TODAS LAS VARIABLES (Aquí estaba el fallo)
            p.net_uid  = uid;
            p.taken    = false;
            p.tipo     = theMessageStruct.tipo;
            p.amount   = theMessageStruct.amount;
            p.duration = theMessageStruct.duration;
            
            // 🔥 ESTA LÍNEA ES VITAL:
            // Recibimos "spawnID" del mensaje y lo guardamos como "spawn_id" en el objeto
            p.spawn_id = theMessageStruct.spawnID;
        break;

case "request_powerup":
    if (!oBrain.AmIPseudoHost) break;
    var _uid = theMessageStruct.uid;
    var _sender = senderClientId; 

    with(oPowerupPickup) {
        if (net_uid == _uid && !taken) {
            taken = true;
            var _tipo = tipo; 
            var _px = x; // Guardamos la posición por si acaso
            var _py = y;
            
            // 1. BROADCAST a los clientes
            with(oOtherPlayer) {
                SendEventToClient(clientId, "powerup_taken", { uid: _uid });
                SendEventToClient(clientId, "powerup_fx", { tipo: _tipo, targetId: _sender });
            }

            // 2. EFECTO LOCAL EN EL HOST (Código directo)
            var _targetInst = noone;
            // ¿El que lo agarró es el Host? (poco probable aquí, pero por seguridad)
            if (global.clientId == _sender) { 
                _targetInst = oPlayer.id; 
            } 
            else { 
                // Buscamos al cliente que lo agarró para que las chispas salgan de su cuerpo
                with(oOtherPlayer) { if (clientId == _sender) _targetInst = id; } 
            }

            if (instance_exists(_targetInst)) {
                var _fxObj = (_tipo == "heal") ? oHealFX : oSpeedFX;
                repeat(8) { 
                    instance_create_layer(_targetInst.x + random_range(-20, 20), _targetInst.y + random_range(-10, 10), "Instances", _fxObj); 
                }
            }

            // 3. Limpieza
            scr_release_spawn_point(_px, _py);
            instance_destroy();
        }
    }
break;

        case "apply_powerup":
            var _is_pred = variable_struct_exists(theMessageStruct, "is_prediction") ? theMessageStruct.is_prediction : false;
            if (_is_pred) exit; 
            var _tipo = theMessageStruct.tipo; 
            with (oPlayer) {
                if (_tipo == "speed") { speed_timer = theMessageStruct.duration; walksp_mult = 1.5; } 
                else if (_tipo == "heal") { health = min(100, health + theMessageStruct.amount); }
            }
        break;

case "powerup_fx":
    var _targetId = theMessageStruct.targetId;
    var _tipo = theMessageStruct.tipo;
    var _targetInst = noone;

    // A. ¿El que lo agarró soy yo mismo (local)?
    if (global.clientId == _targetId) { 
        _targetInst = oPlayer.id; 
    } 
    // B. ¿El que lo agarró es otro jugador?
    else { 
        with(oOtherPlayer) { 
            if (clientId == _targetId) _targetInst = id; 
        } 
    }

    // C. Si encontramos al dueño, creamos las partículas
    if (instance_exists(_targetInst)) {
        var _obj = (_tipo == "heal") ? oHealFX : oSpeedFX;
        repeat(8) { 
            instance_create_layer(_targetInst.x + random_range(-20, 20), _targetInst.y + random_range(-10, 10), "Instances", _obj); 
        }
    }
break;

case "powerup_taken":
    var _uid = theMessageStruct.uid;
    with(oPowerupPickup) {
        if (net_uid == _uid) {
            instance_destroy();
        }
    }
break;

        // --- EXPLOSIVOS Y BARRRILES ---
        case "barrel_dead":
            var _bx = theMessageStruct.bx;
            var _by = theMessageStruct.by;
            var _inst = instance_nearest(_bx, _by, oExplosiveBarrel);
            if (_inst != noone && point_distance(_inst.x, _inst.y, _bx, _by) < 10) {
                instance_create_layer(_inst.x, _inst.y, "Weapons", oExplosionFX);
                if (global.sfx) audio_play_sound(sndMissileExplode, 10, false);
                instance_destroy(_inst);
            }
        break;

        case "request_fx_explosion":
            if (!oBrain.AmIPseudoHost) break;
            var _isNade = variable_struct_exists(theMessageStruct, "isNade") ? theMessageStruct.isNade : false;
            scrCreateRocketExplosion(theMessageStruct.ex, theMessageStruct.ey, _isNade);
            with(oOtherPlayer) {
                SendEventToClient(clientId, "fx_pearl_explosion", { ex: theMessageStruct.ex, ey: theMessageStruct.ey, isNade: _isNade });
            }
        break;

        case "fx_pearl_explosion":
            var _isNade = variable_struct_exists(theMessageStruct, "isNade") ? theMessageStruct.isNade : false;
            scrCreateRocketExplosion(theMessageStruct.ex, theMessageStruct.ey, _isNade);
        break;

        // --- ARMAS Y MUNICIÓN ---
		case "request_pickup_weapon":
            if (!oBrain.AmIPseudoHost) break;
            
            var _uid = theMessageStruct.uid;
            var _mode = theMessageStruct.mode;
            var _sender = senderClientId;
            var pick = noone;

            with (oGun) { if (net_uid == _uid && !taken) { pick = id; taken = true; break; } }
            
            if (pick != noone) {
                // 1. Guardar datos del arma antes de borrarla
                var _wData = pick.weapon;
                var _px = pick.x;
                var _py = pick.y;

                // 2. Avisar al que la pidió que la puede equipar
                SendEventToClient(_sender, "confirm_weapon_pickup", { 
                    weapon: _wData, 
                    mode: _mode 
                });

                // 3. BROADCAST: Avisar a los DEMÁS que el arma ya no está
                with(oOtherPlayer) {
                    SendEventToClient(clientId, "weapon_pickup_taken", { uid: _uid });
                }

                // 4. Limpieza en el Host
                scr_release_spawn_point(_px, _py);
                instance_destroy(pick);
            }
        break;

		case "confirm_weapon_pickup":
            var _wData = theMessageStruct.weapon;
            var _mode = theMessageStruct.mode;
            
            with(oPlayer) {
                if (_mode == "stack") {
                    // Solo sumamos munición
                    guns[weapon.index].ammo = min(guns[weapon.index].ammo + _wData.ammo, guns[weapon.index].maxAmmo);
                } else {
                    // Cambiamos el arma entera
                    guns[weapon.index] = _wData;
                }
                // Feedback visual o sonido opcional
                if (global.sfx) audio_play_sound(snd_pickup_weapon, 10, false);
            }
        break;

        case "weapon_pickup_taken":
            with (oGun) { if (net_uid == theMessageStruct.uid) { instance_destroy(); break; } }
        break;

        case "spawn_weapon_pickup":
            var uid = theMessageStruct.uid;
            var exists = false;
            with(oGun) { if (net_uid == uid) { exists = true; break; } }
            if (!exists) {
                var g = instance_create_layer(theMessageStruct.x, theMessageStruct.y, "Instances", oGun);
                g.net_uid = uid;
                g.weapon = theMessageStruct.weapon;
                g.taken = false;
            }
        break;

        case "request_ammo":
            if (!oBrain.AmIPseudoHost) exit;
            var _inst = noone;
            with (oAmmoPack) { if (net_uid == theMessageStruct.uid) { _inst = id; } }
            if (_inst != noone) {
                scr_release_spawn_point(_inst.x, _inst.y);
                instance_destroy(_inst);
                with(oOtherPlayer) { SendEventToClient(clientId, "ammo_taken", { uid: theMessageStruct.uid }); }
            }
        break;

        case "ammo_taken":
            with (oAmmoPack) { if (net_uid == theMessageStruct.uid) { instance_destroy(); break; } }
        break;

        case "spawn_ammo_pack":
            var uid = theMessageStruct.uid;
            var exists = false;
            with (oAmmoPack) { if (variable_instance_exists(id, "net_uid") && net_uid == uid) { exists = true; break; } }
            if (!exists) {
                var a = instance_create_layer(theMessageStruct.x, theMessageStruct.y, "Instances", oAmmoPack);
                a.net_uid = uid;
                a.amount = theMessageStruct.amount;
                a.taken = false;
            }
        break;

        case "sync_spawn_point":
            with(oSpawnPoint) { if (myID == theMessageStruct.pID) ocupado = theMessageStruct.isOcupado; }
        break;

        // --- DAÑO Y COMBATE ---
        case "request_hit":
            if (oBrain.AmIPseudoHost) {
                SendEventToClient(theMessageStruct.victimId, "hit", {
                    damage: theMessageStruct.damage, killer: theMessageStruct.killer, reason: theMessageStruct.reason
                });
            }
        break;

        case "hit":
            if (!instance_exists(oPlayer)) break;
            with (oPlayer) {
                if (isDead || invulnerable) exit;
                health -= real(theMessageStruct.damage);
                last_killer = theMessageStruct.killer;
                death_reason = theMessageStruct.reason;
                if (state != PLAYERSTATE.DEAD) {
                    state = PLAYERSTATE.HIT;
                    if (global.sfx) audio_play_sound(snd_hit, 20, false, .9);
                }
            }
        break;

        case "fx_shot":
            var spr = sprMuzzle_gun;
            if (theMessageStruct.muzzle == "smg") spr = sprMuzzle_smg;
            if (theMessageStruct.muzzle == "escop") spr = sprMuzzle_escop;
            var m = instance_create_layer(theMessageStruct.x, theMessageStruct.y, "Instances", oMuzzleFlash);
            m.sprite_index = spr; m.image_angle = theMessageStruct.ang;
            var t = instance_create_layer(theMessageStruct.x, theMessageStruct.y, "Instances", oTracer);
            t.direction = theMessageStruct.ang;
        break;

        case "fx_melee":
            var fx = instance_create_layer(theMessageStruct.x, theMessageStruct.y, "Instances", oMeleeFX);
            fx.image_xscale = theMessageStruct.dir;
        break;

        case "hammer_attack":
            with(oHammer) { if (myHammerId == theMessageStruct._id) { ataca = true; image_index = 0; image_speed = 1; } }
        break;

        case "kill_event":
            scrOnKillEvent(theMessageStruct);
        break;

        case "i_died":
            oPlayer.kills++;
        break;

        // --- SISTEMA DE BANDERAS (CTF) ---
        case "flag_capture":
            var eq = theMessageStruct.team;
            var bandera = (eq == "AZUL") ? oFlag : oFlag2;
            with(bandera) {
                has_flag = true;
                sprite_index = spr_mano;
                portador_instancia = noone;
                if (eq == global.myTeam) portador_instancia = oPlayer.id;
                else with(oOtherPlayer) { if (team == eq) other.portador_instancia = id; }
            }
            var notif = instance_create_layer(0, 0, "Instances", oNotification);
            notif.text = (eq == global.myTeam) ? "TIENES LA BANDERA ENEMIGA!" : "CUIDADO! ROBARON TU BANDERA";
            notif.color = (eq == global.myTeam) ? c_aqua : c_red;
        break;

        case "flag_dropped":
            var bandera = (theMessageStruct.team == "AZUL") ? oFlag : oFlag2;
            with(bandera) {
                has_flag = false;
                sprite_index = spr_suela;
                portador_instancia = noone;
                x = theMessageStruct.dropX; y = theMessageStruct.dropY;
                velocidad_caida = -2;
            }
            if (instance_exists(oOtherPlayer)) oOtherPlayer.has_flag = false;
        break;

        case "request_point":
            if (oBrain.AmIPseudoHost) {
                var tr = theMessageStruct.team;
                var fr = theMessageStruct.resetFlag;
                if (tr != "SISTEMA") { if (tr == "AZUL") global.puntos_azul++; else global.puntos_rojo++; }
                if (fr == "ROJA") with(oFlag) { x=spawnX; y=spawnY; has_flag=false; portador_instancia=noone; }
                else with(oFlag2) { x=spawnX; y=spawnY; has_flag=false; portador_instancia=noone; }
                
                with(oOtherPlayer) {
                    SendEventToClient(clientId, "sync_score", { azul: global.puntos_azul, rojo: global.puntos_rojo, resetFlag: fr, reason: (tr=="SISTEMA"?"RETORNO":"PUNTO") });
                }
                callback_ReceivedEvent("sync_score", { azul: global.puntos_azul, rojo: global.puntos_rojo, resetFlag: fr, reason: (tr=="SISTEMA"?"RETORNO":"PUNTO") }, -1);
            }
        break;

        case "sync_score":
            global.puntos_azul = theMessageStruct.azul;
            global.puntos_rojo = theMessageStruct.rojo;
            var obj = (theMessageStruct.resetFlag == "ROJA") ? oFlag : oFlag2;
            with(obj) { has_flag=false; portador_instancia=noone; x=spawnX; y=spawnY; velocidad_caida=0; sprite_index = spr_suela; }
            
            var notif = instance_create_layer(0, 0, "Instances", oNotification);
            if (theMessageStruct.reason == "RETORNO") {
                notif.text = (theMessageStruct.resetFlag == (global.myTeam=="AZUL"?"AZUL":"ROJA")) ? "SALVASTE TU BANDERA!" : "BANDERA RECUPERADA";
                notif.color = c_gray;
            } else {
                var ganoMiEquipo = (theMessageStruct.resetFlag == (global.myTeam=="AZUL"?"ROJA":"AZUL"));
                notif.text = ganoMiEquipo ? "TU EQUIPO ANOTO!" : "EL ENEMIGO ANOTO!";
                notif.color = ganoMiEquipo ? c_lime : c_orange;
            }
        break;

        // --- SISTEMA Y POSICIONAMIENTO ---
        case "init_pos_color":
            oPlayer.x = theMessageStruct.x; oPlayer.y = theMessageStruct.y;
            oPlayer.latest_x = oPlayer.x; oPlayer.latest_y = oPlayer.y;
            global.myTeam = theMessageStruct.team;
        break;

        case "request_drop_on_death":
            if (oBrain.AmIPseudoHost) scr_drop_on_death(theMessageStruct.weapon, theMessageStruct.x, theMessageStruct.y);
        break;

        case "finalizar_partida":
            global.game_over = true;
            global.winner_team = theMessageStruct.winner;
        break;
            
        case "host_abandono":
            LeaveRoom(); 
        break;
    }
}