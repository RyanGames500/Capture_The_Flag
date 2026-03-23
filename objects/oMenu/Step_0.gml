var mid_x = room_width / 2-300;
var mid_y = room_height / 2 - 250;

if (mouse_check_button_pressed(mb_left)) {
	if (global.registrado == 0) {
    // Verificamos si el mouse está dentro del cuadro
    if (mouse_x > mid_x - 200 && mouse_x < mid_x + 200 &&
        mouse_y > mid_y - 30 && mouse_y < mid_y + 30) {
        
        input_activo = true;
        keyboard_string = texto_input; // Mejor que inicie con lo que ya había escrito
    } else {
        // --- AQUÍ EL TRUCO: Si hace clic fuera y el input estaba activo, GUARDAMOS ---
        if (input_activo) {
            // Aplicamos la misma lógica que el ENTER
            global.myName = (texto_input == "") ? "Jugador" : texto_input;
            gmda_setNewname((texto_input == "") ? "Jugador" : texto_input);
			global.registrado=1;
			menu_delay = 5;
	
	// 2. GENERAR EL FRIEND TAG AQUÍ MISMO (Solo ocurre esta vez)
    if (!variable_global_exists("miFriendTag") || global.miFriendTag == "" || global.miFriendTag == 0) {
        global.miFriendTag = scr_generar_id_amigo();
        show_debug_message(">>> TAG GENERADO EN REGISTRO: " + string(global.miFriendTag));
    }
	
            #region Guardado local
			scr_save_to_local();
            #endregion

			#region --- PREPARAR GUARDADO EN LA NUBE ---
			save_state = "prepare";
			save_timer = room_speed; // 1 segundo de espera para no chocar con el input
			#endregion
			
            keyboard_string = ""; 
			mensaje_texto = "Nombre guardado!";
			mensaje_alpha = 4; // Lo ponemos en 2 para que dure un poco más antes de desvanecerse
        }
        input_activo = false;
		}
    }
}


// --- CLIC PARA CONTROLAR EL FOCO DEL BUSCADOR ---
if (mouse_check_button_pressed(mb_left)) {
    if (menu_state == "friends_menu" && friends_state == "anadir") {
        var cx = display_get_gui_width() / 2;
        var cy = display_get_gui_height() / 2;
        var mx = device_mouse_x_to_gui(0);
        var my = device_mouse_y_to_gui(0);

        // Si hace clic DENTRO: Encendemos el teclado
        if (mx > cx - 250 && mx < cx + 250 && my > cy - 180 && my < cy - 120) {
            var es_buscando = (estado_busqueda == "buscando" || estado_busqueda == "buscando_nombre" || estado_busqueda == "buscando_perfil_final");
            
            if (!es_buscando) {
                input_activo = true;
                keyboard_string = friends_search_input;
                
                if (estado_busqueda == "error" || estado_busqueda == "encontrado") {
                    estado_busqueda = "idle";
                }
            }
        } 
        // Si hace clic FUERA: Solo apagamos el teclado (sin buscar)
        else {
            input_activo = false;
        }
    }
}
// --- 1. LÓGICA DEL INPUT DE TEXTO ---
if (input_activo) {
// --- LÓGICA PARA PEGAR TEXTO (CTRL + V) ---
    if (keyboard_check(vk_control) && keyboard_check_pressed(ord("V"))) {
        if (clipboard_has_text()) {
            var texto_pegado = clipboard_get_text();
            // Limpiamos un poco el texto pegado (quitar saltos de línea por si acaso)
            texto_pegado = string_replace_all(texto_pegado, "\n", "");
            texto_pegado = string_replace_all(texto_pegado, "\r", "");
            
            // Añadimos el texto pegado al buffer actual
            keyboard_string += texto_pegado;
        }
    }

if (menu_state == "friends_menu" && friends_state == "anadir") {
    // Solo actualizamos mientras no hayamos disparado la búsqueda
    if (estado_busqueda == "idle" || estado_busqueda == "error") {
        friends_search_input = keyboard_string;
    }
        
    if (keyboard_check_pressed(vk_enter) && estado_busqueda == "idle") {
        if (friends_search_input != "") {
            // LIMPIEZA TOTAL DE ESPACIOS
            var _val = string_trim(friends_search_input); 
            
            estado_busqueda = "buscando";
            search_timer = 0; // REINICIAMOS EL TIMER AQUÍ MISMO
            
            // Bloqueamos el input para que no se manden más peticiones
            input_activo = false; 
            keyboard_string = "";
            
            ultimo_intento_busqueda = _val; 
            
            // PASO 1: ID Directo
            request_datos_rival = ReadSimpleData("perfiles", _val);
            
            show_debug_message(">>> BUSCANDO EN NUBE: " + _val);
        }
    }
		
}
    // Si NO estamos en amigos, es el input normal del nombre (registro o perfil)
    else {
        if (string_length(keyboard_string) <= max_caracteres) {
            texto_input = keyboard_string;
        } else {
            keyboard_string = texto_input;
        }

        if (keyboard_check_pressed(vk_enter)) {
            // Lógica original de guardar nombre
            global.myName = (texto_input == "") ? "Jugador" : texto_input;
            gmda_setNewname(global.myName);
            global.registrado = 1;
            menu_delay = 5;
            scr_save_to_local();
            save_state = "prepare";
            save_timer = room_speed;
            input_activo = false; 
            keyboard_string = "";
            mensaje_texto = "Nombre guardado!";
            mensaje_alpha = 2;
        }
    }
}
// --- 2. LÓGICA DEL MENÚ (Solo si no estás escribiendo) ---
if (!input_activo) {
if (menu_delay > 0) {
        menu_delay--;
    } else {
var move = keyboard_check_pressed(ord("S")) - keyboard_check_pressed(ord("W"));

// --- ESTADO PRINCIPAL ---
    if (menu_state == "main") {
        index = clamp(index + move, 0, array_length(menu_options) - 1);

        if (keyboard_check_pressed(vk_enter)) {
            switch(index) {
                case 0: // Ahora PLAY abre el submenú de modos
                    menu_state = "play_selection";
                    play_index = 0;
					exit;
                break;
                
                case 1: 
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


				case 2: // FRIENDS
				    menu_state = "friends_menu";
				    friends_index = 0;
				    friends_state = "main";
					exit;
				break;

				case 3:
				menu_state = "achievements";
				break;

				case 4: 
				    menu_state = "profile";
					show_debug_message(">>> ENTRANDO AL PERFIL");
				break;
                
                case 5: 
					show_message("options...");
                break;
				
                case 6: 
                    game_end();
                break;
            }
        }
		
		

// Entrar por tecla
    if (keyboard_check_pressed(ord("M"))) {
        menu_state = "mailbox";
    }
    
    // Entrar por clic en el sobre (usando tus variables mail_x/y del Create)
    var mx = device_mouse_x_to_gui(0);
    var my = device_mouse_y_to_gui(0);
    if (mouse_check_button_pressed(mb_left)) {
        if (mx > mail_x - 40 && mx < mail_x + 40 && my > mail_y - 40 && my < mail_y + 40) {
            menu_state = "mailbox";
        }
    }
	

// Salir del buzón
if (menu_state == "mailbox") {
    if (keyboard_check_pressed(vk_escape)) {
        menu_state = "main";
    }

    }	
}
else if (menu_state == "private") {
    if (global.myName != "" && global.myName != "NAME") {
        texto_input = global.myName;
    }
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
                case 0: // PARTIDA RÁPIDA 
                    if (global.myName == "") global.myName = "Player_" + string(irandom(999));
                    menu_state = "connecting";
                    ChangeRoom("auto_matchmake_2");
                break;

                case 1: // PARTIDA PRIVADA 
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
else if (menu_state == "friends_menu") {
    // --- SALIR HACIA ATRÁS ---
    if (keyboard_check_pressed(vk_escape)) {
        if (friends_state == "main") {
            menu_state = "main";
        } else {
            // Si estábamos en añadir o lista, volvemos al submenú de amigos
            friends_state = "main";
            input_activo = false;
            keyboard_string = "";
        }
        // Usamos exit para que no procese nada más este frame y no se raye
        exit; 
    }

    var move = keyboard_check_pressed(vk_down) - keyboard_check_pressed(vk_up);
    
    if (friends_state == "main") {
        friends_index = clamp(friends_index + move, 0, array_length(friends_options) - 1);
        
        if (keyboard_check_pressed(vk_enter)) {
            switch(friends_index) {
                case 0: friends_state = "lista"; break;
                case 1: 
                    friends_state = "anadir";
                    input_activo = true;
                    keyboard_string = ""; 
                    friends_search_input = "";
                    estado_busqueda = "idle";
                break;
                case 2: menu_state = "main"; break;
            }
        }
    }
    // Nota: La lógica de "anadir" ya la movimos arriba al bloque global de input_activo
	
	if (friends_state == "lista") {
    var num_amigos = array_length(global.lista_amigos);
    
    if (num_amigos > 0) {
        var move = keyboard_check_pressed(vk_down) - keyboard_check_pressed(vk_up);
        
        if (move != 0) {
            friend_selected = clamp(friend_selected + move, 0, num_amigos - 1);
            
            // Si el seleccionado se sale de la vista, movemos el target del scroll
            // Ajusta el -95 según necesites para que siempre se vea el seleccionado
            if (friend_selected > 3) {
                scroll_target = -(friend_selected - 3) * 95; 
            } else {
                scroll_target = 0;
            }
        }


// --- ACCIÓN: VER PERFIL ---
if (keyboard_check_pressed(ord("P"))) {
    var _tag_objetivo = global.lista_amigos[friend_selected].tag;
    
    // Iniciamos la carga de datos del amigo
    estado_busqueda = "buscando";
    request_datos_rival = ReadSimpleData("perfiles", _tag_objetivo);
    
    friends_state = "perfil_amigo"; 
    input_activo = false;
}
    
}
}

	if (friends_state == "perfil_amigo") {
	    if (keyboard_check_pressed(vk_escape)) {
	        friends_state = "lista";
	        estado_busqueda = "idle";
	    }
	}
}
}
}
if (menu_state == "connecting") {
    waiting_timer++;
    if (waiting_timer > room_speed) waiting_timer = 0; // Reinicia cada segundo
	
	if(keyboard_check_released(vk_escape))
	{
		LeaveRoom();
		menu_state="main";	
	}
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
if (menu_state == "profile") {
    // 1. Activar edición con la tecla E
    if (keyboard_check_pressed(ord("E"))) {
        if (!input_activo) {
            input_activo = true;
            keyboard_string = global.myName; // Empezamos con el nombre actual
        }
    }

    // 2. Si estamos editando...
    if (input_activo) {
        // Limitamos caracteres
        if (string_length(keyboard_string) <= 12) {
            global.myName = keyboard_string;
        } else {
            keyboard_string = global.myName;
        }

        // Confirmar cambio con ENTER
        if (keyboard_check_pressed(vk_enter)) {
            input_activo = false;
			#region --- PREPARAR GUARDADO EN LA NUBE ---
			save_state = "prepare";
			save_timer = room_speed; // 1 segundo de espera para no chocar con el input
			#endregion
            if (global.myName == "") global.myName = "Soldado";
            show_debug_message(">>> Nombre actualizado desde el perfil.");
        }
    }

    // 3. Salir si no estamos escribiendo
    if (keyboard_check_pressed(vk_escape) && !input_activo) {
        menu_state = "main";
    }
	
if (keyboard_check_pressed(ord("B")) && !input_activo) {
	var PLAYER_ID = gmda_getPlayerid();
        var _id_buscado = get_string("Introduce el ID ÚNICO del jugador:", "");
        
        if (_id_buscado != "" && _id_buscado != string(PLAYER_ID)) {
            estado_busqueda = "buscando";
            // PASO DIRECTO: Leemos el perfil usando el ID como nombre de documento
            request_datos_rival = ReadSimpleData("perfiles", string(_id_buscado));
            
            show_debug_message(">>> BUSCADOR: Pidiendo perfil del ID: " + string(_id_buscado));
        }
    }
	
    
    // Abrir selector con A
    if (keyboard_check_pressed(ord("A")) && !mostrando_selector) {
        mostrando_selector = true;
        avatar_seleccionado = global.avatar_id; // Empezar en el actual
    }
    
    // Si la ventanita está abierta
if (mostrando_selector) {
// Scroll con la rueda del ratón
    if (mouse_wheel_up())   scroll_y_target -= 60;
    if (mouse_wheel_down()) scroll_y_target += 60;

    // Movimiento con flechas (Mantenemos lo de antes)
    var total_iconos = sprite_get_number(spr_player_icon);
    var columnas = 4;
    var prev_sel = avatar_seleccionado;

    if (keyboard_check_pressed(vk_right)) avatar_seleccionado = clamp(avatar_seleccionado + 1, 0, total_iconos - 1);
    if (keyboard_check_pressed(vk_left))  avatar_seleccionado = clamp(avatar_seleccionado - 1, 0, total_iconos - 1);
    if (keyboard_check_pressed(vk_down))  avatar_seleccionado = clamp(avatar_seleccionado + columnas, 0, total_iconos - 1);
    if (keyboard_check_pressed(vk_up))    avatar_seleccionado = clamp(avatar_seleccionado - columnas, 0, total_iconos - 1);

    // AUTO-SCROLL: Si el seleccionado se sale por abajo o por arriba, movemos el scroll
    var fila_actual = floor(avatar_seleccionado / columnas);
    var y_en_grid = fila_actual * 120;
    
    if (y_en_grid < scroll_y_target) scroll_y_target = y_en_grid;
    if (y_en_grid > scroll_y_target + 120) scroll_y_target = y_en_grid - 120;

    // Limitar el scroll para que no se vaya al infinito
    var filas_totales = ceil(total_iconos / columnas);
    var max_scroll = max(0, (filas_totales * 120) - 240);
    scroll_y_target = clamp(scroll_y_target, 0, max_scroll);

    if (keyboard_check_pressed(vk_space)) mostrando_selector = false;

    if (keyboard_check_pressed(vk_enter)) {
// --- DENTRO DEL IF (keyboard_check_pressed(vk_enter)) ---
if (scr_check_icon_unlocked(avatar_seleccionado)) {
    global.avatar_id = avatar_seleccionado;
    mostrando_selector = false;
    scr_save_to_local(); // Guardar el nuevo icono
    
    oMenu.mensaje_texto = "ICONO ACTUALIZADO!";
    oMenu.mensaje_alpha = 2;
} else {
    // Feedback de que está bloqueado
    oMenu.mensaje_texto = "ICONO BLOQUEADO!";
    oMenu.mensaje_alpha = 2;
    // audio_play_sound(snd_error, 1, false); 
}
    }
}


}

	

// Lógica de desvanecimiento del mensaje
if (mensaje_alpha > 0) {
    mensaje_alpha -= 0.05; // Velocidad a la que desaparece
}

// --- TIMEOUT AGRESIVO (2 SEGUNDOS) ---
if (estado_busqueda == "buscando" || estado_busqueda == "buscando_nombre" || estado_busqueda == "buscando_perfil_final") {
    
    search_timer++;
    
    // Si pasan 120 frames (aprox 2 seg a 60fps) y no hay respuesta, cortamos
    if (search_timer > 120) { 
        if (estado_busqueda == "buscando") {
            // Reintento rápido por nombre
            show_debug_message(">>> ID TARDA MUCHO, SALTANDO A NOMBRE...");
            request_datos_rival = ReadSimpleData("perfiles", ultimo_intento_busqueda);
            estado_busqueda = "buscando_nombre";
            search_timer = 0; // Reset para otros 2 segundos
        } else {
            // Fallo definitivo
            estado_busqueda = "error";
            mensaje_texto = "Usuario no encontrado!";
            mensaje_alpha = 3;
            search_timer = 0; 
            show_debug_message(">>> CORTADO POR LENTITUD (Timeout Agresivo)");
        }
    }
} else {
    search_timer = 0; 
}

// --- 3. RESETEAR ESTADO AL TERMINAR EL MENSAJE ---
if (estado_busqueda == "error" && mensaje_alpha <= 0) {
    estado_busqueda = "idle";
}

if (menu_state == "achievements") {
    if (keyboard_check_pressed(vk_escape)) {
        menu_state = "main";
    }
	
	var move_scroll = (mouse_wheel_down() - mouse_wheel_up()) * 40;
    scroll_target = clamp(scroll_target + move_scroll, 0, scroll_max);
    
    // Interpolación suave para que no sea un movimiento brusco
    scroll_y = lerp(scroll_y, scroll_target, 0.15);
}



if (estado_busqueda == "encontrado" && keyboard_check_pressed(ord("F"))) {
    if (is_struct(datos_busqueda_resultado)) {
        var id_rival = string(ultimo_intento_busqueda); 
        var mi_id = string(gmda_getPlayerid());
        
        // --- MODO TEST: Permitimos auto-envío ---
        // Comentamos el IF original para que nos deje pasar
        // if (id_rival != mi_id) { 
            
            scr_enviar_solicitud_amistad(id_rival); // Recuerda que id_rival aquí es el Tag que escribiste
            
            estado_busqueda = "idle";
            friends_search_input = "";
            datos_busqueda_resultado = -1; 
            
        /* } else {
            mensaje_texto = "Ese eres tú, genio! jjj";
            mensaje_alpha = 3;
        } */
    }
}



	if (menu_state == "mailbox") {
    if (hay_solicitud_pendiente) {
        // ACEPTAR
        if (keyboard_check_pressed(ord("Y"))) {
            scr_aceptar_solicitud();
            mensaje_texto = "Ahora eres amigo de " + string(global.nombre_ultimo_amigo) + "!";
            mensaje_alpha = 3;
        }
        
        // RECHAZAR
        if (keyboard_check_pressed(ord("N"))) {
            DeleteSimpleData("solicitudes", string(global.miFriendTag));
            hay_solicitud_pendiente = false;
            show_debug_message(">>> Solicitud rechazada.");
        }
    }
    
    if (keyboard_check_pressed(vk_escape)) {
        menu_state = "main";
    }
}


//eliminar amigo
if (mouse_check_button_pressed(mb_left)){
	var gui_w = display_get_gui_width();
    var gui_h = display_get_gui_height();
    
    var mx = device_mouse_x_to_gui(0);
    var my = device_mouse_y_to_gui(0);
    var cx = gui_w / 2;
    var cx = gui_w / 2;

    for (var i = 0; i < array_length(global.lista_amigos); i++) {
        var yy = 180 + scroll_y + (i * (80 + 15)); // Misma fórmula del Draw
        var _bx = cx + 500/2 - 25; // La misma X del botón borrar

        // Detectamos el clic en el círculo de la X
        if (point_distance(mx, my, _bx, yy) < 15)
		{
            var _amigo_nombre = global.lista_amigos[i].nombre;
            
            // Mensaje de confirmación
            if (show_question("¿Eliminar a " + _amigo_nombre + " de tus amigos?")) {
                var _tag_a_borrar = global.lista_amigos[i].tag;
                
                // 1. Borrar de la lista local
                array_delete(global.lista_amigos, i, 1);
                
                // 2. Guardar cambio localmente
                scr_save_to_local();
                
                // 3. (Opcional) Avisar a Rocket si tienes una tabla de relaciones
                 DeleteSimpleData("amigos", _tag_a_borrar);
                
				#region --- PREPARAR GUARDADO EN LA NUBE ---
				save_state = "prepare";
				save_timer = room_speed; // 1 segundo de espera para no chocar con el input
				#endregion
				
                mensaje_texto = "Amigo eliminado.";
                mensaje_alpha = 2;
                break;
            }
        }
    }
}



if (mouse_check_button_pressed(mb_left)) {
    var mx = device_mouse_x_to_gui(0);
    var my = device_mouse_y_to_gui(0);
    var cx = display_get_gui_width() / 2;

    // Recorremos la lista para ver si el clic cayó en algún botón de duelo
    for (var i = 0; i < array_length(global.lista_amigos); i++) {
        
        // Calculamos la posición exacta que tiene este amigo en la pantalla
        // USAMOS LA MISMA FÓRMULA QUE EN TU DRAW
        var item_yy = 180 + scroll_y + (i * (80 + 15)); 
        var btn_duelo_x = cx + 500/2 - 110; // Ajusta el -110 según donde dibujaste el icono

        // ¿El clic está sobre el botón de duelo de este amigo específico?
        if (point_distance(mx, my, btn_duelo_x, item_yy) < 15) {
            
		// --- CLIC EN BOTÓN DE DUELO ---
		var _su_tag = global.lista_amigos[i].tag;

		SetSimpleData("duelo_pendiente", string(_su_tag), {
		    retador_nombre: global.myName,
		    retador_id: global.clientId, // Le damos nuestro ID para que nos responda directo
		    es_duelo: true 
		});

		oMenu.mensaje_texto = "Esperando respuesta del rival...";
		oMenu.mensaje_alpha = 2;
		// NO llamamos a ChangeRoom aquí.
        }
    }
}

//dibujar venta de reto
if (mostrando_reto) {
    reto_timer--;
    
    // Si presiona ENTER (Aceptar)
    if (keyboard_check_pressed(vk_enter)) {
        var _id_retador = datos_reto.retador_id;
        
        // Avisar al retador
        SendEventToClient(_id_retador, "ENTRA_AL_DUELO", {
            sala_destino: "duelo_" + string(_id_retador)
        });

        // Limpiar y movernos
        DeleteSimpleData("duelo_pendiente", global.miFriendTag);
        mostrando_reto = false;
        ChangeRoom("duelo_" + string(_id_retador));
    }
    
    // Si presiona ESC o se acaba el tiempo (Rechazar)
    if (keyboard_check_pressed(vk_escape) || reto_timer <= 0) {
        DeleteSimpleData("duelo_pendiente", global.miFriendTag);
        mostrando_reto = false;
        datos_reto = -1;
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
    if (!variable_instance_exists(id, "nube_guardada") || nube_guardada == false) {
        nube_guardada = true; // Marcamos que ya empezamos
        
		//GUARDAR PERFIL EN LA NUBE 
		scr_sincronizar_nube();
		
        alarm[1] = 60;
        show_debug_message(">>> Guardando en la nube... Alarma 1 iniciada.");
        
        save_state = "waiting"; 
    }
}

if (room == rm_menu) {
    // Solo ejecutamos si el clientId ya existe y no es -1 (o el valor inicial)
    if (variable_global_exists("clientId") && global.clientId != -1) {
        
        if (current_time % 60 == 0) { 
            ReadSimpleData("confirmaciones", string(global.miFriendTag));
        }
        
    }
}



if(menu_state == "main")
{	
	if (estado_busqueda != "idle") {
        estado_busqueda = "idle";
        datos_busqueda_resultado = -1; // <--- Limpia el "fantasma" del amigo anterior
        ultimo_intento_busqueda = "";  // Limpia el buscador
        show_debug_message(">>> SISTEMA: Estado de búsqueda reseteado por seguridad.");
    }
}