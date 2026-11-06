function callback_ReceivedEvent(eventName, theMessageStruct, senderClientId) {
    switch(eventName) {


case "pedir_revancha":
    // El rival ve que quieres revancha
    global.revancha_rival = true; 
    scrAddKillFeed(theMessageStruct.nombre + " QUIERE REVANCHA!");
break;

case "aceptar_revancha":
    // ¡Aquí ocurre la magia! Ambos ejecutan el reset al mismo tiempo
    scr_reset_game_data();
break;

case "identificar_rival":
	var tag_rival = theMessageStruct.rival_tag;
	var name_rival = theMessageStruct.rival_nombre;
	
    global.ultimo_rival_tag = string(tag_rival);
    global.ultimo_rival_nombre = string(name_rival);
    show_debug_message("!!! RIVAL IDENTIFICADO DESDE LA DB/HOST: " + global.ultimo_rival_tag);
break;
// --- DENTRO DE TU SWITCH DE EVENTOS DE RED (callback_ReceivedEvent) ---
case "ENTRA_AL_DUELO":
    var _sala = theMessageStruct.sala_destino;
    
    show_debug_message(">>> ¡Reto aceptado! Moviendo a la arena...");
    
    // El retador ahora sí se mueve
    ChangeRoom(_sala);
    // El salto al room lo hará tu callback_ChangeRoom automáticamente
break;
// --- RECIBIR INVITACIÓN DE DUELO ---
case "reto_duelo":
    var _nombre_retador = theMessageStruct.nombre;
    var _clientId_retador = senderClientId; 

    if (show_question(_nombre_retador + " te reta a un duelo 1vs1. ¿Aceptas?")) {
        
        // 1. Le avisamos que vamos para allá
        SendEventToClient(_clientId_retador, "reto_aceptado", {
            nombre_que_acepta: global.myName
        });

        // 2. Nos unimos a su sala privada usando SU ID de cliente
        // Esto los separa del resto de la gente
        ChangeRoom("duelo_" + string(_clientId_retador));
        
        // 3. ¡A la batalla! (duelo = partida normal: 5 min, 3 banderas)
        // Mapa sacado del nombre de la sala del duelo: el retador saca el mismo
        scr_ajustes_default();
        global.match_mapa = scr_mapa_desde_codigo("duelo_" + string(_clientId_retador));
        room_goto(scr_mapa_room(global.match_mapa));
        
    } else {
        SendEventToClient(_clientId_retador, "reto_rechazado", { nombre: global.myName });
    }
break;

case "reto_aceptado":
    var _quien = theMessageStruct.nombre_que_acepta;
    
    // Como tú eres el retador, la sala se llama con TU ID
    // Así el otro sabe exactamente a dónde entrar
    ChangeRoom("duelo_" + string(global.clientId));
    
    // También nos vamos a la room de pelea (duelo = partida normal, mismo mapa que el otro)
    scr_ajustes_default();
    global.match_mapa = scr_mapa_desde_codigo("duelo_" + string(global.clientId));
    room_goto(scr_mapa_room(global.match_mapa));
    
    show_debug_message(">>> DUELO: " + _quien + " aceptó. Iniciando sala privada.");
break;

case "reto_rechazado":
    var _quien = theMessageStruct.nombre;
    mensaje_texto = _quien + " ha rechazado el duelo.";
    mensaje_alpha = 2;
break;

//case "pj_cambiando":
//    global.pj_rival = theMessageStruct.pj; // Actualiza la cara del rival en mi pantalla
//break;

case "hammer_go":
    // El host avisa que una prensa va a caer: empiezo el aviso ya, descontando medio ping
    var _hid = theMessageStruct.hid;
    var _menos = round((max(0, global.ping) / 2) / (1000 / room_speed));
    with (oHammer) {
        if (myHammerId == _hid) hammer_empezar(max(8, PRENSA_AVISO - _menos));
    }
break;

case "sync_timer":
    oBrain.timer_intro = theMessageStruct.tiempo;
break;

//case "pj_listo":
//{
//    // El rival nos avisa qué personaje eligió
//    global.rival_listo = true;
//    global.pj_rival = theMessageStruct.pj;
//    show_debug_message(">>> Rival listo con personaje: " + string(global.pj_rival));
//}
//break;

case "pj_cambiando":
    with(oOtherPlayer) {
        if (clientId == theMessageStruct.fromId) {
            mySelectedPJ = theMessageStruct.pj; // Guardamos el PJ individualmente
        }
    }
break;

case "pj_listo":
    with(oOtherPlayer) {
        if (clientId == theMessageStruct.fromId) {
            mySelectedPJ = theMessageStruct.pj;
            isReady = true; // Marcamos a esta persona como lista
        }
    }
break;

//Partiva Privada

case "SYNC_LIMIT":
    global.max_players_allowed = theMessageStruct.max;
break;
case "SALA_LLENA":
            // 1. El Host me dijo que me fuera, así que me salgo a mi propia sala sola
            ChangeRoom(string(global.clientId)); 
            
            // 2. Regresamos el menú al estado privado para que pueda intentar otro código
            if (instance_exists(oMenu)) {
                oMenu.menu_state = "private";
                show_message_async("¡SALA LLENA! El límite para este modo es " + string(global.max_players_allowed));
            }
        break;

case "voz":
    // Voz de alguien de la sala privada (scr_objetivo, CHAT DE VOZ)
    scr_voz_recibir(theMessageStruct, senderClientId);
break;

case "chat_sala":
    // Mensaje del chat de la sala privada (scr_objetivo)
    scr_chat_recibir(theMessageStruct);
break;

case "SALA_EN_PARTIDA":
    // Entre con el codigo pero la partida ya empezo: me salgo a mi propia sala
    ChangeRoom(string(global.clientId));
    if (instance_exists(oMenu)) oMenu.menu_state = "private";
    show_message_async("LA PARTIDA YA EMPEZO. Espera a que termine para entrar a la sala.");
break;

case "sync_lobby_name":
    var _n = theMessageStruct.nombre;
    // Usamos el nombre que viene, si no viene nada ponemos "Jugador"
    if (is_undefined(_n)) _n = "Jugador..."; 

    var _soyHost = variable_struct_exists(theMessageStruct, "soyHost") ? theMessageStruct.soyHost : false;

    // Actualizar el objeto visual
    with(oOtherPlayer) {
        if (clientId == senderClientId) {
            Name = _n;
            isHost = _soyHost;
            // Su equipo de verdad, para la selección de personaje
            if (variable_struct_exists(theMessageStruct, "team") && is_string(theMessageStruct.team) && theMessageStruct.team != "") lobby_team = theMessageStruct.team;
        }
    }
    
    // ACTUALIZAR EL MAPA (Para que no salga el nombre viejo de la partida pasada)
    global.playerNames[? string(senderClientId)] = _n;

    // Si yo soy el Host, le respondo al nuevo para que me vea bien
    if (oBrain.AmIPseudoHost && senderClientId != global.clientId) {
        SendEventToClient(senderClientId, "sync_lobby_name", { 
            nombre: global.myName, 
            soyHost: true,
            team: scr_my_team()
        });
    }
break;

case "sync_names":

    var _cid = theMessageStruct.clientId;
    var _name = theMessageStruct.name;

    global.playerNames[? _cid] = _name;

break;

case "KICK_FROM_ROOM":
    // 1. Salir de la sala actual (pero NO del servidor)
    LeaveRoom(); 
    
    // 2. Resetear variables de sala para que pueda entrar a otra
    global.roomId = -1;
    global.myRoomCode = "";
    
    // 3. Cambiar el estado del menú para que vuelva a la pantalla de "PRIVATE"
    if (instance_exists(oMenu)) {
        oMenu.menu_state = "private"; 
    }
    
    // 4. Limpiar los otros jugadores que veía en ese lobby
    with(oOtherPlayer) instance_destroy();
    
    show_message_async("El líder te ha sacado de la sala.");
break;

case "GO_TO_BATTLE":
    // El líder manda los ajustes de la sala (tiempo, mapa, banderas). Si no vienen, partida normal.
    if (is_struct(theMessageStruct) && variable_struct_exists(theMessageStruct, "m")) scr_ajustes_aplicar(theMessageStruct);
    else scr_ajustes_default();
    scr_sala_roster_fijar(theMessageStruct);   // quienes juegan (scr_objetivo)
    // Seleccion de personaje desde cero (si quedo algo de antes, no te salia la seleccion)
    scr_partida_estado_nuevo();   // scr_objetivo
    room_goto(scr_mapa_room(global.match_mapa));
break;

case "sync_ajustes":
    // Ajustes que va cambiando el líder en la sala de espera
    if (!oBrain.AmIPseudoHost) scr_ajustes_aplicar(theMessageStruct);
break;

case "sync_reloj":
    // Reloj de la partida: lo lleva el líder
    if (!oBrain.AmIPseudoHost && room != rm_menu && is_struct(theMessageStruct) && variable_struct_exists(theMessageStruct, "s") && is_numeric(theMessageStruct.s)) {
        oBrain.reloj_seg = max(0, theMessageStruct.s);
        oBrain.reloj_fin = (oBrain.reloj_seg <= 0);
    }
break;

// --- BOTS DE LA SALA PRIVADA (scr_objetivo) ---
case "bots_sp":
    // El lider manda como van sus bots
    scr_botnet_recibir(theMessageStruct);
break;

case "bot_hit":
    // Alguien le pego a un bot: el lider aplica el dano
    if (oBrain.AmIPseudoHost && is_struct(theMessageStruct) && variable_struct_exists(theMessageStruct, "b") && variable_struct_exists(theMessageStruct, "m")) {
        scr_botnet_dano(scr_botnet_buscar(theMessageStruct.b), theMessageStruct.m, senderClientId);
    }
break;

case "bot_flag_capture":
{
    // Un bot agarro la bandera (igual que "flag_capture", pero el portador es el bot)
    if (!is_struct(theMessageStruct) || !variable_struct_exists(theMessageStruct, "b")) break;
    var _bt_eq  = string(theMessageStruct.team);
    var _bt_inst = scr_botnet_buscar(theMessageStruct.b);
    var _bt_flag = (_bt_eq == "AZUL") ? oFlag : oFlag2;
    with (_bt_flag) {
        has_flag = true;
        sprite_index = spr_mano;
        portador_instancia = _bt_inst;
    }
    var _bt_nom = (_bt_inst != noone) ? _bt_inst.Name : "UN BOT";
    if (_bt_eq == global.myTeam) fb_banner_aliado(_bt_nom);
    else fb_banner_robada(_bt_nom);
}
break;

case "player_left_msg":
    // Extraemos el texto desde theMessageStruct
    var _txt_abandono = variable_struct_exists(theMessageStruct, "texto") ? theMessageStruct.texto : "Alguien abandono";
    
    // Lo mandamos al feed de muertes
    scrAddKillFeed(_txt_abandono);
break;



//Granada crear
case "spawn_granada":
    var _gx    = theMessageStruct.gx;
    var _gy    = theMessageStruct.gy;
    var _angle = theMessageStruct.angle;

    var gra = instance_create_layer(_gx, _gy, "Instances", oGranada);
    
    // Usamos variables consistentes
    gra.direction = _angle;
    gra.speed = 8; 
    gra.gravity = 0.2; // Si tu granada usa gravedad física
    
    // Si usas hsp/vsp manual:
    gra.hsp = lengthdir_x(8, _angle);
    gra.vsp = lengthdir_y(8, _angle) - 2;
    
    // Marcamos que es una granada remota para que no procese daño (solo el dueño daña)
    gra.is_remote = true; 
break;
	
case "sync_names_teams":
{
    var _azules = theMessageStruct.azules;
    var _rojos = theMessageStruct.rojos;
    // El cliente recibe esto del host y activa su propia intro
    global.fase_seleccion = false;
    oBrain.intro_disparada = true;
    oBrain.timer_intro = -1;
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
    p.taken   = false;
    p.tipo    = theMessageStruct.tipo;
    p.amount  = theMessageStruct.amount;
    p.duration = theMessageStruct.duration;
}
break;

case "request_powerup":
{
    if (!oBrain.AmIPseudoHost) break;

    var _uid = theMessageStruct.uid;
    var _sender = senderClientId; // El ID del que hizo la petición
    
    var _inst = noone;
    with (oPowerupPickup) { if (net_uid == _uid) { _inst = id; break; } }

    if (_inst != noone) {
        var _tipo = _inst.tipo;
        var _amt  = _inst.amount;
        var _dur  = _inst.duration;

        // A) Confirmar efecto al cliente que lo pidió
        SendEventToClient(_sender, "apply_powerup", {
            tipo: _tipo,
            amount: _amt,   
            duration: _dur,  
            is_prediction: true
        });

        // B) Avisar a TODOS los demás
        with(oOtherPlayer) {
            // Todos borran el objeto físicamente
            SendEventToClient(clientId, "powerup_taken", { uid: _uid });
            
            // 🔥 El efecto visual debe salir de quien lo agarró (_sender)
            // Se le manda a todos, incluso al que lo agarró (aunque él ya lo hizo local, 
            // su código de apply_powerup o colisión lo maneja)
            SendEventToClient(clientId, "powerup_fx", { tipo: _tipo, targetId: _sender });
        }

        // C) El Host también debe ver el efecto visual del cliente en su pantalla
        // Ejecutamos la lógica de FX manualmente para el Host
        var _host_target = noone;
        with(oOtherPlayer) { if (clientId == _sender) _host_target = id; }
        if (instance_exists(_host_target)) {
             var _obj_fx = oHealFX;
             if (_tipo == "speed")  _obj_fx = oSpeedFX;
             if (_tipo == "shield") _obj_fx = oSpeedFX;
             if (_tipo == "damage") _obj_fx = oSpeedFX;
             if (_tipo == "ammo")   _obj_fx = oSpeedFX;
             repeat(8) {
                 instance_create_layer(_host_target.x + random_range(-20, 20), _host_target.y + random_range(-10, 10), "Instances", _obj_fx);
             }
        }

        scr_release_spawn_point(_inst.x, _inst.y);
        instance_destroy(_inst);
    }
}
break;

case "powerup_fx":
{
    var _tipo = theMessageStruct.tipo;
    var _targetId = theMessageStruct.targetId;
    var _targetInst = noone;

    // 1. ¿El efecto es para MÍ (el cliente que recibe este mensaje)?
    if (global.clientId == _targetId) { 
        _targetInst = oPlayer.id;
    } else {
        // 2. ¿Es para otro jugador?
        with(oOtherPlayer) {
            if (clientId == _targetId) {
                _targetInst = id;
            }
        }
    }

    // 3. Crear partículas
    if (instance_exists(_targetInst)) {
        var _obj = oHealFX;
        if (_tipo == "speed")  _obj = oSpeedFX;
        if (_tipo == "shield") _obj = oSpeedFX;
        if (_tipo == "damage") _obj = oSpeedFX;
        if (_tipo == "ammo")   _obj = oSpeedFX;
        
        repeat(8) {
            instance_create_layer(_targetInst.x + random_range(-20, 20), _targetInst.y + random_range(-10, 10), "Instances", _obj);
        }
    }
}
break;

case "powerup_taken":
{
    var uid = theMessageStruct.uid;
    with (oPowerupPickup) {
        if (net_uid == uid) {
            instance_destroy();

        }
    }
}
break;

case "apply_powerup":
{
    // Si es predicción, a veces es mejor ignorarlo porque oPlayer YA lo hizo en la colisión
    var _is_pred = variable_struct_exists(theMessageStruct, "is_prediction") ? theMessageStruct.is_prediction : false;
    
    // Si eres el que lo recogió, ya tienes el efecto puesto por la colisión local
    if (_is_pred) {
        // Ya me lo puse yo al tocarlo (Collision_oPowerupPickup). Antes se aplicaba dos veces
        // y la curación daba el doble; ahora solo se confirma.
        show_debug_message("Host confirmó mi PowerUp");
        break;
    }

    // Si llegas aquí, es porque el Host te ordena aplicarlo (y no fue por colisión local)
    var _tipo = theMessageStruct.tipo;
    var _amount = variable_struct_exists(theMessageStruct, "amount") ? theMessageStruct.amount : 25;
    var _duration = variable_struct_exists(theMessageStruct, "duration") ? theMessageStruct.duration : 300;

    with (oPlayer) {
        if (_tipo == "speed") { speed_timer = _duration; walksp_mult = 1.5; } 
        else if (_tipo == "heal") { health = min(max_health, health + _amount); }
		else if (_tipo == "shield") { has_shield = true; shield_timer = _duration; }
        else if (_tipo == "damage") { damage_boost = 2; damage_timer = _duration; }
        else if (_tipo == "ammo")   { infinite_ammo = true; ammo_timer = _duration; }
    }
}
break;

case "barrel_dead":
{
    var _bx = theMessageStruct.bx;
    var _by = theMessageStruct.by;

    // Si oBarrilSmall es HIJO de oExplosiveBarrel, 
    // esta línea encontrará a CUALQUIERA de los dos.
    var _inst = instance_nearest(_bx, _by, oExplosiveBarrel); 
    
    if (_inst != noone) {
        if (point_distance(_inst.x, _inst.y, _bx, _by) < 15) {
            
            instance_create_layer(_inst.x, _inst.y, "Weapons", oExplosionFX);
            scrCamShake(10);
            if (global.sfx) audio_play_sound(sndMissileExplode, 10, false);
            
            _inst.hp = 0;
            _inst.exploded = true; 
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
    scrCreateRocketExplosion(ex, ey);

    with(oOtherPlayer) {
        SendEventToClient(clientId, "fx_pearl_explosion", { ex: ex, ey: ey });
    }
}
break;

case "request_fx_explosion":
{
    if (!oBrain.AmIPseudoHost) break;

    var ex = theMessageStruct.ex;
    var ey = theMessageStruct.ey;
    var _isNade = variable_struct_exists(theMessageStruct, "isNade") ? theMessageStruct.isNade : false;
    var _sender = senderClientId;

    // 1. El Host crea su propio efecto
    scrCreateRocketExplosion(ex, ey, _isNade);

    // 2. 🔥 BROADCAST: El Host le avisa a todos los demás clientes
    with(oOtherPlayer) {
        if (clientId != _sender) { // No se lo mandamos al que disparó, él ya lo creó localmente
            SendEventToClient(clientId, "fx_pearl_explosion", {
                ex: ex,
                ey: ey,
                isNade: _isNade
            });
        }
    }
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

case "fx_shield_hit":
{
    var _ex = theMessageStruct.ex;
    var _ey = theMessageStruct.ey;

    // Todos los que reciben esto crean el efecto visual
    instance_create_layer(_ex, _ey, "Instances", oShieldSparkFX);
    
    // Opcional: Sonido de impacto para los demás
    if (global.sfx) audio_play_sound(snd_shield_impact, 10, false, 1.8);
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

    w.no_pickup_timer = (variable_struct_exists(theMessageStruct, "npt")) ? theMessageStruct.npt : 0;
}
break;

case "request_pickup_weapon":
{
    if (!oBrain.AmIPseudoHost) break;

    var uid = theMessageStruct.uid;
    var pick = noone;
    with (oGun) { if (net_uid == uid) { pick = id; break; } }
    
    if (pick == noone) break;

    // 1. Liberar el spawn point para que pueda reaparecer otra arma después
    scr_release_spawn_point(pick.x, pick.y);
    
    // 2. Destruir pickup en el mundo del host
    instance_destroy(pick);

    // 3. Si fue SWAP, dropear el arma vieja del cliente
    //if (theMessageStruct.mode == "swap")
    //{
    //    var oldW = theMessageStruct.oldWeapon;
    //    if (is_struct(oldW))
    //    {
    //        // Nota: He usado host_drop_weapon porque es el que tenías en tu 1vs1
    //        host_drop_weapon(oldW, theMessageStruct.dropX, theMessageStruct.dropY);
    //    }
    //}

    // 4. 🔥 EL CAMBIO CLAVE: Avisar a TODOS los clientes que borren su copia
    with(oOtherPlayer) {
        SendEventToClient(clientId, "weapon_pickup_taken", { uid: uid });
    }
}
break;

case "weapon_pickup_taken":
{
    var uid = theMessageStruct.uid;
    with (oGun) { 
        if (net_uid == uid) { instance_destroy(); break; } 
    }
}
break;

case "request_resync":
{
    // Un jugador terminó de cargar el mapa y pide todo lo que hay tirado
    if (!oBrain.AmIPseudoHost) break;
    var targetID = senderClientId;

    with (oAmmoPack) {
        if (!taken) SendEventToClient(targetID, "spawn_ammo_pack", {
            uid: net_uid, x: x, y: y, amount: amount,
            is_grenade: (variable_instance_exists(id, "is_grenade_pack") ? is_grenade_pack : false)
        });
    }
    with (oGun) {
        if (variable_instance_exists(id, "weapon") && is_struct(weapon)) {
            SendEventToClient(targetID, "spawn_weapon_pickup", { uid: net_uid, x: x, y: y, weapon: weapon });
        }
    }
    with (oPowerupPickup) {
        SendEventToClient(targetID, "spawn_powerup", {
            uid: net_uid, x: x, y: y, tipo: tipo, duration: duration, amount: amount,
            spawnID: (variable_instance_exists(id, "spawn_id") ? spawn_id : -1)
        });
    }
    with (oSpawnPoint) scr_spawn_point_enviar(id, targetID);
}
break;

case "fx_impact":
    // Chispas de un impacto que hizo otro jugador
    fx_sparks(theMessageStruct.x, theMessageStruct.y, theMessageStruct.d, theMessageStruct.n, theMessageStruct.h);
break;

case "request_ammo":
{
    if (!oBrain.AmIPseudoHost) exit;
    
    var _uid = theMessageStruct.uid;
    var _sender = senderClientId; // El ID del que recogió la munición
    var _inst = noone;

    // 1. Buscar el pack de munición en el Host
    with (oAmmoPack) {
        if (variable_instance_exists(id, "net_uid") && net_uid == _uid) { 
            _inst = id; 
            break; 
        }
    }

    if (_inst != noone) {
        // 2. Liberar el spawn point para que el sistema de respawn sepa que está libre
        scr_release_spawn_point(_inst.x, _inst.y);
        
        // 3. Destruirlo en el Host
        instance_destroy(_inst);
        
        // 4. 🔥 BROADCAST A TODOS MENOS AL QUE LO AGARRÓ
        // (Porque el que lo agarró ya lo borró en su pantalla para evitar lag)
        with(oOtherPlayer) {
            if (clientId != _sender) {
                SendEventToClient(clientId, "ammo_taken", { uid: _uid });
            }
        }
    }
}
break;

case "ammo_taken":
{
    var uid = theMessageStruct.uid;

    // Buscamos y destruimos la copia visual en los demás clientes
    with (oAmmoPack) {
        if (variable_instance_exists(id, "net_uid") && net_uid == uid) { 
            instance_destroy(); 
            break; 
        }
    }
}
break;

		case "sync_spawn_point":
		{
		    var _id = theMessageStruct.pID;
		    var _state = theMessageStruct.isOcupado;
		    var _t  = variable_struct_exists(theMessageStruct, "t")  ? theMessageStruct.t  : 0;
		    var _tm = variable_struct_exists(theMessageStruct, "tm") ? theMessageStruct.tm : 0;
		    with(oSpawnPoint) {
		        if (myID == _id) {
		            ocupado = _state;
		            // El cliente NO crea nada: solo copia el reloj del host para dibujar el anillo
		            // (lo que aparece lo manda el host con "spawn_ammo_pack" / "spawn_weapon_pickup" / "spawn_powerup")
		            cooldown = _t;
		            cooldown_max = _tm;
		            primera_vez = false;
		        }
		    }
		}
		break;

		case "hab_botiquin":
		{
		    // Botiquín del Sargento de otro jugador (scr_personajes). Cada quien se cura solo.
		    var _bq = instance_create_layer(theMessageStruct.x, theMessageStruct.y, "Instances", oBotiquin);
		    _bq.team = theMessageStruct.team;
		}
		break;

		case "aviso_arma":
		    // El host avisa que salió un arma fuerte arriba al centro
		    if (variable_struct_exists(theMessageStruct, "txt")) scrAddAlert(theMessageStruct.txt, c_orange);
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
		{
		    var uid = theMessageStruct.uid;
		    show_debug_message("--- CLIENTE RECIBIÓ SPAWN: " + string(uid) + " ---");

		    var exists = false;
		    with (oAmmoPack) {
		        if (variable_instance_exists(id, "net_uid") && net_uid == uid) { exists = true; break; }
		    }
    
		    if (!exists) {
		        var _x = theMessageStruct.x;
		        var _y = theMessageStruct.y;
		        var _amt = theMessageStruct.amount;
		        // Leemos si el Host dijo que es granada (por defecto false si no viene)
		        var _isG = variable_struct_exists(theMessageStruct, "is_grenade") ? theMessageStruct.is_grenade : false;

		        var a = instance_create_layer(_x, _y, "Instances", oAmmoPack);
		        a.net_uid = uid;
		        a.taken   = false;
		        a.amount  = _amt;
		        a.is_grenade_pack = _isG; // Guardamos el estado

		        // Cambiar sprite visualmente en el cliente
		        if (_isG) {
		            a.sprite_index = spr_pack_granadas; 
		        }

		        show_debug_message("+++ MUNICIÓN CREADA (" + (_isG ? "GRANADAS" : "BALAS") + ") EN: " + string(_x) + "," + string(_y));
		    }
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
		    // Ya nadie lo manda (cada uno nace en su base). Si llega de una versión vieja,
		    // te pone en TU base en vez de la posición que traía, y no truena si aún no naciste.
		    if (instance_exists(oPlayer)) with (oPlayer) scr_spawn_en_base();
		}	
		break;

case "request_hit":
{
    if (oBrain.AmIPseudoHost) 
    {
        var victimId = theMessageStruct.victimId;
        var dmg      = theMessageStruct.damage;
        var killer   = string(theMessageStruct.killer);
        var reason   = string(theMessageStruct.reason);
        
        // Recibimos el ángulo del atacante (Asegúrate de mandarlo desde el guante)
        var ang = variable_struct_exists(theMessageStruct, "angle") ? theMessageStruct.angle : 0;

        SendEventToClient(victimId, "hit", {
            damage: dmg,
            killer: killer,
            reason: reason,
            angle: ang 
        });
    }
}
break;

case "hit":
{
    if (!instance_exists(oPlayer)) exit;

    with (oPlayer)
    {
        if (isDead || invulnerable) exit;
        if (scr_hab_esquivando()) exit;   // Asalto en pleno impulso: la bala no le hace nada (scr_personajes)

        var dmg = real(theMessageStruct.damage);

        // --- 1. LÓGICA DEL ESCUDO ---
        if (has_shield) {
            has_shield = false; 
            shield_timer = 0;   
            impact_alpha = 0.6;
            impact_color = c_aqua; 
            scrCamShake(12); 
            if (global.sfx) audio_play_sound(snd_hit, 20, false, 1.5); 
            exit; 
        }

        // --- 2. LÓGICA DE DAÑO NORMAL ---
        if (is_string(theMessageStruct.killer)) last_killer = theMessageStruct.killer;
        if (is_string(theMessageStruct.reason)) death_reason = theMessageStruct.reason;
        else death_reason = "pvp";

        dmg = scr_hab_dano_recibido(dmg);   // coraza del Tanque: la mitad (scr_personajes)
        damage_alpha = 0.4; 
        health -= dmg;
        fx_damage_number(x, bbox_top - 8, dmg, 3);
        scr_efx_recibir_jugador(theMessageStruct);   // zap, hielo, red o iman (scr_armas)
        // --- 🥊 LÓGICA DE BOXEO (Empuje y Bandera) ---
        if (theMessageStruct.reason == "boxeo") {
            
            // Recibimos el ángulo dinámico
            var _ang = variable_struct_exists(theMessageStruct, "angle") ? theMessageStruct.angle : 0;
            
            state = PLAYERSTATE.HIT;
            hit_bloqueo_timer = 20;
            
            // Empuje lateral basado en el ángulo y salto hacia arriba
            // (con la coraza del Tanque no lo mueve; la bandera sí la suelta)
            if (!scr_hab_coraza_activa()) {
                push_h = lengthdir_x(22, _ang); 
                vsp = -7; 
            }

            if (has_flag) {
                has_flag = false;
                
                // --- 🚩 EL SALTITO DE LA BANDERA ---
                var _obj_bandera = (global.myTeam == "AZUL") ? oFlag : oFlag2;
                with (_obj_bandera) {
                    has_flag = false;
                    portador_instancia = noone;
                    x = other.x;
                    y = other.y - 25;      // Aparece un poco más arriba
                    velocidad_caida = -6;  // Empuje hacia arriba para que no se recoja de una vez
                }

                // Avisamos a todos los clientes del drop con la nueva posición
                with(oOtherPlayer){
                    SendEventToClient(clientId, "flag_dropped", {
                        team: global.myTeam,
                        dropX: other.x,
                        dropY: other.y - 25
                    });
                }
                fb_toast("TE TUMBARON LA BANDERA", "Quedo en el suelo", FB_ORO);
            }
        }

        if(health <= 0) and oPlayer.t2 == 0
        {
            oPlayer.t2 = 1;
            // Si me elimino un bot, no hay a quien darle el punto (scr_objetivo)
            var _de_bot = variable_struct_exists(theMessageStruct, "bot") && theMessageStruct.bot;
            if (!_de_bot) SendMessageToClient(senderClientId , "point")
        }

        if (state != PLAYERSTATE.DEAD)
        {
            state = PLAYERSTATE.HIT;
            image_index = 0;
            hit_bloqueo_timer = max(hit_bloqueo_timer, 10);
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
		    var idDelQueCapturo = senderClientId; // <--- USAMOS EL ID ÚNICO DEL EMISOR
		    var banderaObjetivo = (equipoCapturador == "AZUL") ? oFlag : oFlag2;

		    with(banderaObjetivo) {
		        has_flag = true;
		        sprite_index = spr_mano;
        
		        // ¿Quién la capturó?
		        if (idDelQueCapturo == global.clientId) {
		            // Fui yo mismo (Local)
		            portador_instancia = oPlayer.id;
		        } else {
		            // Fue alguien más. Buscamos EXACTAMENTE a quién entre todos los "Others"
		            var elPortadorReal = noone;
		            with(oOtherPlayer) {
		                if (clientId == idDelQueCapturo) elPortadorReal = id;
		            }
		            portador_instancia = elPortadorReal;
		        }
		    }
    
		    // B: banner de bandera (scr_feedback). Quien la tomo:
		    var _nom_cap = "ALGUIEN";
		    with (oOtherPlayer) { if (clientId == idDelQueCapturo && variable_instance_exists(id, "Name")) _nom_cap = Name; }
		    if (equipoCapturador == global.myTeam) fb_banner_aliado(_nom_cap);
		    else fb_banner_robada(_nom_cap);
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
            if (teamRequest == "AZUL") {
                global.puntos_azul++;
                // --- EFECTO SEXY PARA EL HOST ---
                with(oBrain) { marcador_escala_azul = 3; marcador_shake = 15; }
            } else {
                global.puntos_rojo++;
                // --- EFECTO SEXY PARA EL HOST ---
                with(oBrain) { marcador_escala_rojo = 3; marcador_shake = 15; }
            }
        }

        // Reset físico de banderas
        if (flagToReset == "ROJA") with (oFlag) { x=spawnX; y=spawnY; velocidad_caida=0; has_flag=false; portador_instancia=noone; sprite_index=spr_suela; }
        else with (oFlag2){ x=spawnX; y=spawnY; velocidad_caida=0; has_flag=false; portador_instancia=noone; sprite_index=spr_suela; }   // antes decía x=spawnY

        var miObjetivoHost = (global.myTeam == "AZUL") ? "ROJA" : "AZUL";
        if (flagToReset == miObjetivoHost) {
            oPlayer.has_flag = false;
            oPlayer.score_pending = false;
        }

        // Feedback (scr_feedback). Nombre de quien lo hizo: viene en el mensaje (versión nueva) o lo busco
        var _nom_rp = "";
        if (variable_struct_exists(theMessageStruct, "nombre")) _nom_rp = string(theMessageStruct.nombre);
        else with (oOtherPlayer) { if (clientId == senderClientId && variable_instance_exists(id, "Name")) _nom_rp = Name; }
        if (isSystem) {
            var miColor = (global.myTeam == "AZUL") ? "AZUL" : "ROJA";
            if (flagToReset == miColor) fb_toast("BANDERA DEVUELTA", _nom_rp + " salvo tu bandera", fb_team_col(global.myTeam));
            else fb_toast("EL RIVAL RECUPERO SU BANDERA", _nom_rp, fb_team_col(fb_rival(global.myTeam)));
        } else {
            fb_anotacion((teamRequest == "AZUL") ? "AZUL" : "ROJO", _nom_rp);
        }

        // SYNC A TODOS LOS CLIENTES
        with(oOtherPlayer){
            SendEventToClient(clientId, "sync_score", {
                azul: global.puntos_azul,
                rojo: global.puntos_rojo,
                resetFlag: flagToReset,
                reason: (isSystem) ? "RETORNO" : "PUNTO",
                nombre: _nom_rp   // opcional
            });
        }
    }
}
break;



case "sync_score":
{
    var flag_scored = theMessageStruct.resetFlag; 
    var reason = variable_struct_exists(theMessageStruct, "reason") ? theMessageStruct.reason : "PUNTO";
    var miObjetivo = (global.myTeam == "AZUL") ? "ROJA" : "AZUL";
    var miColor = (global.myTeam == "AZUL") ? "AZUL" : "ROJA";

    // --- ACTIVAR EFECTO SEXY SEGÚN QUIÉN ANOTÓ ---
    with(oBrain) {
        marcador_shake = 15;
        if (theMessageStruct.azul > global.puntos_azul) marcador_escala_azul = 3;
        if (theMessageStruct.rojo > global.puntos_rojo) marcador_escala_rojo = 3;
    }

    global.puntos_azul = theMessageStruct.azul;
    global.puntos_rojo = theMessageStruct.rojo;

    // Resetear si yo la llevaba
    if (flag_scored == miObjetivo) {
        oPlayer.has_flag = false;
        oPlayer.score_pending = false;
    }
    
    if (flag_scored == miColor) {
        oPlayer.score_pending = false;
    }

    // Reset físico de banderas
    if (flag_scored == "ROJA") {
        with (oFlag) { has_flag = false; portador_instancia = noone; x = spawnX; y = spawnY; velocidad_caida = 0; sprite_index = spr_suela; }
    } else {
        with (oFlag2) { has_flag = false; portador_instancia = noone; x = spawnX; y = spawnY; velocidad_caida = 0; sprite_index = spr_suela; }
    }

    // Feedback (scr_feedback). El nombre es opcional: si viene de una versión vieja no se muestra
    var _nom_ss = variable_struct_exists(theMessageStruct, "nombre") ? string(theMessageStruct.nombre) : "";
    if (reason == "RETORNO") {
        if (flag_scored == miColor) fb_toast("BANDERA DEVUELTA", (_nom_ss == "") ? "Tu bandera volvio a la base" : _nom_ss + " salvo tu bandera", fb_team_col(global.myTeam));
        else fb_toast("EL RIVAL RECUPERO SU BANDERA", _nom_ss, fb_team_col(fb_rival(global.myTeam)));
    } else {
        // "ROJA" reseteada = anoto AZUL (se llevo la roja a su base), y al reves
        fb_anotacion((flag_scored == "ROJA") ? "AZUL" : "ROJO", _nom_ss);
    }
}
break;

case "flag_dropped":
{
    var equipoQueLaSolto = theMessageStruct.team;
    var dropX = theMessageStruct.dropX;
    var dropY = theMessageStruct.dropY;
    
    // 1. Identificar la bandera (Azul suelta Roja, Rojo suelta Azul)
    var banderaAUsar = (equipoQueLaSolto == "AZUL") ? oFlag : oFlag2;

    if (instance_exists(banderaAUsar)) {
        // Quitamos el IF de seguridad que la bloqueaba y usamos la lógica de limpieza total
        with(banderaAUsar) {
            has_flag = false;
            portador_instancia = noone;
            x = dropX;
            y = dropY;
            velocidad_caida = -2;
            sprite_index = spr_suela;
            
            // Debug por si acaso (puedes quitarlo luego)
            show_debug_message("Bandera soltada por equipo: " + equipoQueLaSolto);
        }
    }

    // 2. 🔥 IMPORTANTÍSIMO: Limpiar a TODOS los oOtherPlayer
    // Si no hacemos esto, el objeto del jugador en la pantalla de los demás
    // sigue pensando que tiene la bandera y la sigue dibujando.
    with(oOtherPlayer) {
        if (team == equipoQueLaSolto) {   // antes usaba thisPlayerTeam, que nunca se llenaba
            has_flag = false;
        }
    }
    
    // 3. Si yo soy el que la soltó, me aseguro de estar limpio
    if (global.myTeam == equipoQueLaSolto) {
        oPlayer.has_flag = false;
    }

    // Aviso chico (scr_feedback)
    if (equipoQueLaSolto == global.myTeam) fb_toast("BANDERA EN EL SUELO", "Tu equipo solto la bandera rival", FB_ORO);
    else fb_toast("TU BANDERA ESTA EN EL SUELO", "Tocala para devolverla", fb_team_col(global.myTeam));
}
break;

// --- Dentro del switch(eventName) ---
case "finalizar_partida":
{
    global.game_over = true;
    // Usamos theMessageStruct que es tu variable de red
    global.winner_team = theMessageStruct.winner;
    
    // 🏆 PROCESO DE PROGRESO PERSONAL (CLIENTE)
    // El seguro "puntos_procesados" evita que esto se repita
    if (!puntos_procesados) 
    {
        puntos_procesados = true;
        
        var mi_equipo_num = (global.myTeam == "ROJO") ? 1 : 2;
        
        // Con bots en la sala cuenta como partida contra bots (scr_objetivo)
        scr_botnet_premio(global.winner_team == mi_equipo_num);
        
        show_debug_message(">>> CLIENTE: Progreso personal actualizado.");
    }
}
break;
			
			case "host_abandono":
		    // El host se fue, así que nos desconectamos nosotros también
		    LeaveRoom(); 
			break;
			
// --- RAILGUN Y MINA (scr_jugabilidad) ---
case "fx_rail_carga":
{
    // Línea de aviso del railgun de otro jugador
    var _rc = instance_create_layer(theMessageStruct.x, theMessageStruct.y, "Instances", oRayo);
    _rc.modo = "carga";
    _rc.x1 = theMessageStruct.x; _rc.y1 = theMessageStruct.y;
    _rc.ang = theMessageStruct.ang;
    _rc.vida = RAIL_CARGA; _rc.vida_max = RAIL_CARGA;
}
break;

case "fx_rail":
{
    var _rr = instance_create_layer(theMessageStruct.x1, theMessageStruct.y1, "Instances", oRayo);
    _rr.x1 = theMessageStruct.x1; _rr.y1 = theMessageStruct.y1;
    _rr.x2 = theMessageStruct.x2; _rr.y2 = theMessageStruct.y2;
    if (global.sfx) audio_play_sound(snd_bazooka, 1, false, 0.6, 0, 1.6);
}
break;

case "mina_poner":
    if (scr_mina_buscar(theMessageStruct.mid) == noone) {
        scr_mina_crear(theMessageStruct.x, theMessageStruct.y, string(theMessageStruct.team), string(theMessageStruct.owner), theMessageStruct.mid, false);
    }
break;

case "mina_pisada":
{
    // Alguien la pisó en su pantalla: la mecha empieza aquí también (descontando medio ping)
    var _menos_m = round((max(0, global.ping) / 2) / (1000 / room_speed));
    scr_mina_encender(scr_mina_buscar(theMessageStruct.mid), _menos_m);
}
break;

case "mina_quitar":
{
    var _mq = scr_mina_buscar(theMessageStruct.mid);
    if (_mq != noone) instance_destroy(_mq);
}
break;

case "fx_shot":
{
    var fx_x = theMessageStruct.x;
    var fx_y = theMessageStruct.y;
    var ang  = theMessageStruct.ang;
    var mid  = theMessageStruct.muzzle;

    // Mapeo de Sprites
    var spr = sprMuzzle_smg;
    switch (mid) {
        case "gun":   spr = sprMuzzle_gun; break;
        case "smg":   spr = sprMuzzle_smg; break;
        case "escop": spr = sprMuzzle_escop; break;
        case "m4":    spr = sprMuzzle_smg; break; // Puedes usar el de smg
    }

    var m = instance_create_layer(fx_x, fx_y, "Instances", oMuzzleFlash);
    m.sprite_index = spr;
    m.image_angle  = ang;
    if (mid == "bazooka") m.image_xscale = 2; // Efecto más grande para bazooka

    // Tracer corregido: necesita x1, y1, x2, y2 para dibujarse
    var len = 60;
    var t = instance_create_layer(fx_x, fx_y, "Instances", oTracer);
    t.x1 = fx_x;
    t.y1 = fx_y;
    t.x2 = fx_x + lengthdir_x(len, ang);
    t.y2 = fx_y + lengthdir_y(len, ang);

    // Sonido del disparo del otro (antes solo se oian los tuyos).
    // Las armas nuevas mandan cual sonido es; las de siempre se sacan por el tipo.
    if (global.sfx) {
        var _snd = -1, _vol = 1, _tono = 1;
        if (variable_struct_exists(theMessageStruct, "snd")) {
            _snd = asset_get_index(theMessageStruct.snd);
            if (variable_struct_exists(theMessageStruct, "vol"))  _vol  = theMessageStruct.vol;
            if (variable_struct_exists(theMessageStruct, "tono")) _tono = theMessageStruct.tono;
        } else {
            switch (mid) {
                case "gun":     _snd = snd_gun;     break;
                case "smg":     _snd = snd_smg;     break;
                case "escop":   _snd = snd_escop;   break;
                case "bazooka": _snd = snd_bazooka; break;
                case "m4":      _snd = snd_M4; _vol = 0.8; break;
            }
        }
        if (_snd != -1 && asset_get_type(audio_get_name(_snd)) == asset_sound) {
            // Si pasa fuera de tu pantalla se oye mas bajito
            var _cam = view_camera[0];
            var _cx = camera_get_view_x(_cam), _cy = camera_get_view_y(_cam);
            var _ve = (fx_x > _cx - 40 && fx_x < _cx + camera_get_view_width(_cam) + 40 && fx_y > _cy - 40 && fx_y < _cy + camera_get_view_height(_cam) + 40);
            audio_play_sound(_snd, 1, false, _vol * (_ve ? 1 : 0.35), 0, _tono * random_range(0.97, 1.03));
        }
    }
}
break;

			case "fx_melee":
			{
			    // Datos que manda el atacante
			    var xx  = theMessageStruct.x;
			    var yy  = theMessageStruct.y;
			    var dir = theMessageStruct.dir; // -1 o 1

			    // Creamos SOLO el efecto visual
			    var fx = instance_create_layer(xx, yy, "Instances", oMeleeFX);
			    fx.image_xscale = dir;
			}
			break;

			case "hammer_attack":
			    var _hid = theMessageStruct._id;
    
			    // Buscamos el martillo que tenga ese ID de posición
			    // Por si llega de alguien con la versión vieja: empieza el aviso igual que "hammer_go"
			    with(oHammer) {
			        if (myHammerId == _hid) hammer_empezar(PRENSA_AVISO);
			    }
			break;

case "kill_event":
{
    scrOnKillEvent(theMessageStruct);
}
break;


case "kill_feed":
    // Alguien murió en su juego y nos avisa quién lo mató (antes este evento no lo recibía nadie)
    if (is_struct(theMessageStruct) && variable_struct_exists(theMessageStruct, "msg")) {
        scrAddKillFeed(string(theMessageStruct.msg));
    }
break;

case "player_emote":
{
    var _oid = theMessageStruct.ownerId;
    var _idx = theMessageStruct.emoteIndex;
    var _inst = noone;

    // Buscar quién lo envió
    with(oOtherPlayer) {
        if (clientId == _oid) _inst = id;
    }
    
    // Si lo encontramos (y no somos nosotros), lo creamos
    if (_inst != noone) {
        var _e = instance_create_layer(_inst.x, _inst.y - 40, "Instances", oEmote);
        _e.image_index = _idx;
        _e.owner = _inst;
    }
}
break;

    }
}