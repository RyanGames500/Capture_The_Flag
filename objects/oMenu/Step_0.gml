var mid_x = room_width / 2-300;
var mid_y = room_height / 2 - 280;

if (mouse_check_button_pressed(mb_left)) {
    // Verificamos si el mouse está dentro del cuadro redondeado (usando mid_x y mid_y)
    if (mouse_x > mid_x - 200 && mouse_x < mid_x + 200 &&
        mouse_y > mid_y - 30 && mouse_y < mid_y + 30) {
        
        input_activo = true;
        keyboard_string = ""; 
        texto_input = "";
    } else {
        input_activo = false;
    }
}

// --- 1. LÓGICA DEL INPUT DE TEXTO ---
if (input_activo) {
    if (string_length(keyboard_string) <= max_caracteres) {
        texto_input = keyboard_string;
    } else {
        keyboard_string = texto_input;
    }

    // Al presionar ENTER aquí, SOLO desactivamos el input
    if (keyboard_check_pressed(vk_enter)) {
        global.myName = (texto_input == "") ? "Jugador" : texto_input;
        input_activo = false; 
        keyboard_string = ""; // Limpiamos para que no afecte el menú
        exit; // IMPORTANTE: Salimos del evento para que este mismo ENTER no active el botón "PLAY"
    }
}

// --- 2. LÓGICA DEL MENÚ (Solo si no estás escribiendo) ---
if (!input_activo) {
    var move = keyboard_check_pressed(vk_down) - keyboard_check_pressed(vk_up);

// --- ESTADO PRINCIPAL ---
    if (menu_state == "main") {
        index = clamp(index + move, 0, array_length(menu_options) - 1);

        if (keyboard_check_pressed(vk_enter)) {
            switch(index) {
                case 0: // Ahora PLAY abre el submenú de modos
                    menu_state = "play_selection";
                    play_index = 0;
                break;
                
                case 1: // OPTIONS
                    show_message("Opciones...");
                break;

				case 2: // --- NUEVO: CONFIGURACIÓN MODO OFFLINE ---
					global.ONLINE = false;
					if(global.ONLINE){
					DisconnectFromServer();}
					menu_state = "offline_setup";
				    off_index = 0; // Índice para este submenú
    
				    // Inicializar opciones offline si no existen
				    global.off_mapa = 0;
				    global.off_flags = 3;
				    global.off_bots = 0; // 0 = Solo, 1 = Con Bots
    
				    // Textos iniciales para el array de opciones offline
				    offline_options = [
				        "MAPA: BOSQUE",
				        "OBJETIVO: 3 BANDERAS",
				        "ENEMIGOS: SOLO (PRACTICA)",
				        "INICIAR BATALLA",
				        "BACK"
				    ];
				break;
                
                case 3: // EXIT
                    game_end();
                break;
            }
        }
    }
    else if (menu_state == "private") {
        p_index = clamp(p_index + move, 0, array_length(private_options) - 1);

        if (keyboard_check_pressed(vk_enter)) {
            switch(p_index) {
				
				case 0: // CREATE ROOM
				    if (global.myName == "") global.myName = "Player_" + string(irandom(999));
				    menu_state = "setup_room"; // En lugar de connecting, vamos a configurar
				    s_index = 0;
				break;
				//case 0: // CREATE ROOM
				//    if (global.myName == "") global.myName = "Player_" + string(irandom(999)); // Por si acaso
				//    global.myRoomCode = "PRV_" + generar_codigo_sala(4); 
				//    menu_state = "connecting";
				//    ChangeRoom(global.myRoomCode); 
				//break;

				case 1: // JOIN WITH CODE
				    var _c = get_string("Introduce el código de la sala:", "");
				    if (_c != "") {
				        global.codigo_a_verificar = string_upper(_c); // Guardamos lo que escribió
				        menu_state = "verifying"; // Un estado nuevo para que el Draw sepa que estamos cargando
				        ShowAllRooms(); // Le pedimos la lista al servidor
				    }
				break;
				
                case 2: // BACK
                    menu_state = "main";
                break;
            }
        }
    }
else if (menu_state == "setup_room") {
    var move = keyboard_check_pressed(vk_down) - keyboard_check_pressed(vk_up);
    s_index = clamp(s_index + move, 0, array_length(setup_options) - 1);

    var side_move = keyboard_check_pressed(vk_right) - keyboard_check_pressed(vk_left);
    
    // --- CAMBIAR MODO ---
    if (s_index == 0 && side_move != 0) { 
        global.setup_modo = (global.setup_modo + side_move + 4) % 4; 
        
        var mod_text = ["1 VS 1", "2 VS 2", "3 VS 3", "4 VS 4"];
        setup_options[0] = "MODO: " + mod_text[global.setup_modo];
    }
    
    // --- AQUÍ EL FIX: Forzamos el límite según el modo seleccionado ANTES de crear ---
    if (global.setup_modo == 0) global.max_players_allowed = 2; // 1vs1
    if (global.setup_modo == 1) global.max_players_allowed = 4; // 2vs2
    if (global.setup_modo == 2) global.max_players_allowed = 6; // 3vs3
    if (global.setup_modo == 3) global.max_players_allowed = 8; // 4vs4

    if (s_index == 1 && side_move != 0) { // Cambiar MAPA
        global.setup_mapa = (global.setup_mapa + side_move + 2) % 2;
        var map_text = ["BOSQUE", "ARENA"];
        setup_options[1] = "MAPA: " + map_text[global.setup_mapa];
    }

    if (keyboard_check_pressed(vk_enter) && s_index == 2) { // CONFIRMAR
		
		// si el input estaba activo o el texto cambió, actualizamos YA
    if (texto_input != "Escribe tu nombre..." && texto_input != "") {
        global.myName = texto_input;
    }
		
        // Ahora sí, global.max_players_allowed valdrá 2 si estás en 1vs1
        var _prefijo = "MAX" + string(global.max_players_allowed) + "_";
        global.myRoomCode = _prefijo + generar_codigo_sala(4); 
        
        menu_state = "connecting";
        ChangeRoom(global.myRoomCode);
    }

    if (keyboard_check_pressed(vk_escape)) menu_state = "private";
}
else if (menu_state == "offline_setup") {
    var move = keyboard_check_pressed(vk_down) - keyboard_check_pressed(vk_up);
    off_index = clamp(off_index + move, 0, array_length(offline_options) - 1);

    var side_move = keyboard_check_pressed(vk_right) - keyboard_check_pressed(vk_left);

    // --- Lógica de cambio con flechas laterales ---
    if (side_move != 0) {
        switch(off_index) {
            case 0: // CAMBIAR MAPA
                global.off_mapa = (global.off_mapa + side_move + 2) % 2;
                var map_text = ["BOSQUE", "ARENA"];
                offline_options[0] = "MAPA: " + map_text[global.off_mapa];
            break;

            case 1: // CAMBIAR BANDERAS
                global.off_flags = clamp(global.off_flags + side_move, 1, 10);
                offline_options[1] = "OBJETIVO: " + string(global.off_flags) + " BANDERAS";
            break;

            case 2: // CAMBIAR ENEMIGOS
                global.off_bots = (global.off_bots + side_move + 2) % 2;
                var bot_text = ["SOLO (PRACTICA)", "CON BOTS (CPU)"];
                offline_options[2] = "ENEMIGOS: " + bot_text[global.off_bots];
            break;
        }
    }

    // --- Confirmar con ENTER ---
    if (keyboard_check_pressed(vk_enter)) {
        if (off_index == 3) { // INICIAR
            //global.ONLINE = false;
            global.puntos_azul = 0;
            global.puntos_rojo = 0;
            global.game_over = false;
            // Elegir room según el mapa
            var target_room = (global.off_mapa == 0) ? rm_stage1_offline : rm_stage2_offline;
            room_goto(target_room);
        }
        else if (off_index == 4) { // VOLVER
            menu_state = "main";
        }
    }
}
else if (menu_state == "play_selection") {
        play_index = clamp(play_index + move, 0, array_length(play_modes) - 1);

        if (keyboard_check_pressed(vk_enter)) {
            switch(play_index) {
                case 0: // PARTIDA RÁPIDA (Lo que antes era el caso 0 del main)
                    if (global.myName == "") global.myName = "Player_" + string(irandom(999));
                    menu_state = "connecting";
                    ChangeRoom("auto_matchmake_2");
                break;

                case 1: // PARTIDA PRIVADA (Lo que antes era el caso 1 del main)
                    menu_state = "private";
                    p_index = 0;
                break;

                case 2: // BACK
                    menu_state = "main";
                break;
            }
        }
        if (keyboard_check_pressed(vk_escape)) menu_state = "main";
    }

}

if (menu_state == "connecting") {
    waiting_timer++;
    if (waiting_timer > room_speed) waiting_timer = 0; // Reinicia cada segundo
}

if (menu_state == "lobby_espera") {
if (oBrain.AmIPseudoHost) {
    var mx = device_mouse_x_to_gui(0);
    var my = device_mouse_y_to_gui(0);

    // 1. Detectar Click Derecho sobre un slot
    if (mouse_check_button_pressed(mb_right)) {
        var slot_w = 400;
        var slot_h = 60;
        var padding = 20;
        var _found = false;

        for (var i = 1; i < 8; i++) { // Empezamos en 1 (no nos auto-kickeamos)
            var es_derecha = (i >= 4);
            var _x1 = es_derecha ? (display_get_gui_width() / 2) + 50 : (display_get_gui_width() / 2) - 450;
            var _y1 = 150 + ((i % 4) * (slot_h + padding));
            
            // ¿El mouse está sobre este slot?
            if (mx > _x1 && mx < _x1 + slot_w && my > _y1 && my < _y1 + slot_h) {
                // Buscamos el ID del jugador en este slot
                var _current_idx = 1;
                with(oOtherPlayer) {
                    if (_current_idx == i) {
                        other.kick_target_id = clientId;
                        other.kick_menu_x = mx;
                        other.kick_menu_y = my;
                        other.show_kick_menu = true;
                        _found = true;
                    }
                    _current_idx++;
                }
            }
        }
        if (!_found) show_kick_menu = false;
    }

    // 2. Lógica de Click Izquierdo en el botón "EXPULSAR"
    if (show_kick_menu && mouse_check_button_pressed(mb_left)) {
        if (mx > kick_menu_x && mx < kick_menu_x + 120 && my > kick_menu_y && my < kick_menu_y + 40) {
		if (kick_target_id != -1) {
            
		            // 1. Le pedimos amablemente que se retire de la sala xdd jajja
		            SendEventToClient(kick_target_id, "KICK_FROM_ROOM", {});
            
		            // 2. Lo borramos de nuestra vista (Host)
		            var _tid = kick_target_id;
		            with(oOtherPlayer) {
		                if (clientId == _tid) instance_destroy();
		            }
            
		            show_kick_menu = false;
		            kick_target_id = -1;
		        }
        } else {
            show_kick_menu = false; // Cerrar si hace click fuera
        }
    }
}

if (oBrain.AmIPseudoHost) {
        if (keyboard_check_pressed(ord("S"))) {
            
            // --- CONTAR SI ESTÁN TODOS ---
            var _total = 1; 
            with(oOtherPlayer) _total++; // Contamos a los invitados
            
            if (_total == global.max_players_allowed) {
                with(oOtherPlayer) {
                    SendEventToClient(clientId, "GO_TO_BATTLE", {});
                }
                room_goto(rm_stage1);
            }
        }
    }
}