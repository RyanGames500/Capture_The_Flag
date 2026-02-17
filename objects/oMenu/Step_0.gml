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

    if (menu_state == "main") {
        index = clamp(index + move, 0, array_length(menu_options) - 1);

        if (keyboard_check_pressed(vk_enter)) {
            switch(index) {
                case 0: // PLAY (Random)
                    menu_state = "connecting";
                    ChangeRoom("auto_matchmake_2");
                break;
                
                case 1: // PRIVATE (Ir al submenú)
                    menu_state = "private";
                    p_index = 0;
                break;

                case 2: // OPTIONS
                    show_message("Opciones...");
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
    
    if (s_index == 0 && side_move != 0) { // --- CAMBIAR MODO ---
        // Ahora es % 4 porque tenemos 4 opciones
        global.setup_modo = (global.setup_modo + side_move + 4) % 4; 
        
        var mod_text = ["1 VS 1", "2 VS 2", "3 VS 3", "4 VS 4"];
        setup_options[0] = "MODO: " + mod_text[global.setup_modo];
        
        // Ajustamos el límite real de jugadores
        if (global.setup_modo == 0) global.max_players_allowed = 2;
        if (global.setup_modo == 1) global.max_players_allowed = 4;
        if (global.setup_modo == 2) global.max_players_allowed = 6; // 3 vs 3 = 6 Jugadores
        if (global.setup_modo == 3) global.max_players_allowed = 8;
    }
    
    if (s_index == 1 && side_move != 0) { // Cambiar MAPA
        global.setup_mapa = (global.setup_mapa + side_move + 2) % 2;
        var map_text = ["BOSQUE", "ARENA"];
        setup_options[1] = "MAPA: " + map_text[global.setup_mapa];
    }

    if (keyboard_check_pressed(vk_enter) && s_index == 2) { // CONFIRMAR
        global.myRoomCode = "PRV_" + generar_codigo_sala(4); 
        menu_state = "connecting";
        ChangeRoom(global.myRoomCode);
        
        // Avisamos al servidor (opcional para que otros lo vean luego)
        // SendEventToAll("ROOM_CONFIG", { modo: global.setup_modo, mapa: global.setup_mapa });
    }

    if (keyboard_check_pressed(vk_escape)) menu_state = "private";
}
}

if (menu_state == "connecting") {
    waiting_timer++;
    if (waiting_timer > room_speed) waiting_timer = 0; // Reinicia cada segundo
}

if (menu_state == "lobby_espera") {
    if (oBrain.AmIPseudoHost) {
        if (keyboard_check_pressed(ord("S"))) {
            // 1. Avisar a todos usando tu sistema de oOtherPlayer
            with(oOtherPlayer) {
                SendEventToClient(clientId, "GO_TO_BATTLE", {});
            }
            
            // 2. Ir a la batalla
            room_goto(rm_stage1);
            
            // Opcional: menu_state = "playing"; o destruir el menú
        }
    }
}