function callback_ChangeRoom(new_room_id) {
    // Si entramos a una sala y ya hay alguien más ahí esperándonos
        if (!string_count("auto_matchmake", new_room_id) && instance_exists(oMenu)) {
        // Si el contador de otros jugadores es mayor a 0, saltamos de una
            oMenu.menu_state = "lobby_espera";
        
    }
    
    // Tu lógica de matchmaking de antes...
    if(string_count("auto_match_", new_room_id)){
        scr_ajustes_default();   // partida rápida: 5 min, 3 banderas
        // Mapa sacado del nombre de la sala: los dos jugadores tienen el mismo nombre = mismo mapa
        global.match_mapa = scr_mapa_desde_codigo(new_room_id);
        scr_qp_mixta(new_room_id);   // faltan personas: los espacios vacios los juegan bots
        room_goto(scr_mapa_room(global.match_mapa));
    }
}
//foto del plano
//luz y agua
//uso de suelo para bono patio

/*
function callback_ChangeRoom(new_room_id){


    if(string_count("auto_match_", new_room_id)){
        room_goto(rm_stage1);
		
    }
	
    if(string_count("public", new_room_id)){
        room_goto(rm_game);
    }
	
}

/// PARTIDA RAPIDA MIXTA: si el servidor junto a menos personas de las que pide el modo
/// (por ejemplo 2 personas buscando 2 VS 2), la sala se llama "auto_match_N_k_hP"
/// (N = jugadores del modo, P = personas que entraron). Las personas van juntas en AZUL
/// y el resto lo llenan bots, como en las salas privadas (solo el lider los crea y los mueve).
/// Si la sala no trae "_h" (partida llena o servidor viejo), no hace nada.
function scr_qp_mixta(_sala) {
	var _p = string_split(string(_sala), "_");
	if (array_length(_p) < 5) return;
	var _ult = _p[array_length(_p) - 1];
	if (string_char_at(_ult, 1) != "h") return;
	var _max = real(string_digits(_p[2]));
	var _hum = real(string_digits(_ult));
	if (_max < 2 || _hum < 1 || _hum >= _max) return;
	var _tam = _max div 2;
	var _hum_azul = min(_hum, _tam);
	var _hum_rojo = _hum - _hum_azul;
	global.qp_tam = _tam;
	global.max_players_allowed = _max;
	global.botnet_defs = [];
	var _usados = [global.myName];
	var _k = 0;
	for (var _e = 0; _e < 2; _e++) {
		var _eq = (_e == 0) ? "AZUL" : "ROJO";
		var _faltan = _tam - ((_e == 0) ? _hum_azul : _hum_rojo);
		for (var _j = 0; _j < _faltan; _j++) {
			scr_bot_rival_nuevo();   // nombre de persona y personaje (scr_reloj)
			var _nom = global.bot_nombre;
			for (var _u = 0; _u < array_length(_usados); _u++) if (_usados[_u] == _nom) _nom += string(_k + 1);
			array_push(_usados, _nom);
			// En los rivales de 3 VS 3 o mas, el primero cuida la base
			var _rol = (_eq == "ROJO" && _j == 0 && _tam >= 3) ? "defensa" : "ataque";
			array_push(global.botnet_defs, { i: BOTNET_ID_BASE - 4 - _k, n: _nom, t: _eq, r: _rol, h: true, pj: irandom(3) });
			_k++;
		}
	}
}
