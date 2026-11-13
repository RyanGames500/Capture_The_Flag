// MUSICA: si todavia no existe oBrain (sin conexion), la lleva el menu (scr_fx)
if (!instance_exists(oBrain)) scr_musica_step();

// SUBISTE DE NIVEL: la pantalla bonita tapa el menu hasta que la cierres (draw_player_profile)
if (scr_lvl_step()) exit;

// REINICIAR PROGRESO (solo pruebas: DEV_REINICIAR en scr_reloj, CTRL + SUPR)
scr_dev_reiniciar_step();

// CUENTAS: pantalla de entrar / crear cuenta, chip del menu y franja de PERFIL (DatabaseFunctions)
if (scr_cuenta_menu_step()) exit;

// MENU NUEVO (draw_player_profile): las pantallas viejas pasan a las nuevas, y aqui se manejan
// el menu principal, la pantalla de modos y la de cuantos jugadores
scr_mn_redirigir();
scr_mn_step();
scr_mn_buscando_step();

// ======================================================
// TOQUES / CLICS DIRECTOS EN LOS BOTONES DEL MENU
// El Draw GUI guarda donde esta cada boton (global.ui_taps) y aqui vemos si lo tocaron.
// ======================================================
global.ui_tap_vk = -1;
var _esc_usado = false; // ESC ya se uso este frame para cancelar algo
if (device_mouse_check_button_pressed(0, mb_left) && variable_global_exists("ui_taps")) {
    var _tpx = device_mouse_x_to_gui(0);
    var _tpy = device_mouse_y_to_gui(0);
    for (var _ti = array_length(global.ui_taps) - 1; _ti >= 0; _ti--) {
        var _tp = global.ui_taps[_ti];
        if (!point_in_rectangle(_tpx, _tpy, _tp.x1, _tp.y1, _tp.x2, _tp.y2)) continue;

        var _vk = _tp.vk;
        if (is_struct(_tp.extra)) {
            // Tarjeta de amigo: primer toque la elige, segundo toque abre su perfil
            if (_tp.extra.tipo == "amigo") {
                if (friend_selected == _tp.extra.i) _vk = ord("P");
                else { friend_selected = _tp.extra.i; _vk = -1; }
            }
            // Icono del selector de avatar: primer toque lo elige, segundo lo confirma
            // Fila del buzon: la elige (y si tocaste ACEPTAR / RECHAZAR, se aplica a esa) (DatabaseFunctions)
            if (_tp.extra.tipo == "buzon") buzon_sel = _tp.extra.i;
            if (_tp.extra.tipo == "avatar") {
                if (avatar_seleccionado == _tp.extra.i) _vk = vk_enter;
                else { avatar_seleccionado = _tp.extra.i; _vk = -1; }
            }
        }
        if (_tp.idx >= 0) {
            switch (menu_state) {
                case "main":           index = _tp.idx; break;
                case "private":        p_index = _tp.idx; break;
                case "setup_room":     s_index = _tp.idx; break;
                case "offline_setup":  off_index = _tp.idx; break;
                case "play_selection": play_index = _tp.idx; break;
                case "friends_menu":   friends_index = _tp.idx; break;
                case "options":        opt_sel = _tp.idx; break;
            }
        }
        global.ui_tap_vk = _vk;
        break;
    }
}

// Cuadro del nombre (mismas coordenadas que el Draw GUI)
var mid_x = display_get_gui_width() / 2;
var mid_y = display_get_gui_height() / 2 - 150;

if (mouse_check_button_pressed(mb_left)) {
	if (global.registrado == 0) {
    var _rmx = device_mouse_x_to_gui(0);
    var _rmy = device_mouse_y_to_gui(0);
    // Verificamos si el mouse está dentro del cuadro
    if (_rmx > mid_x - 200 && _rmx < mid_x + 200 &&
        _rmy > mid_y - 30 && _rmy < mid_y + 30) {
        
        input_activo = true;
        keyboard_string = texto_input; // Mejor que inicie con lo que ya había escrito
        if (touch_mode()) keyboard_virtual_show(kbv_type_default, kbv_returnkey_done, kbv_autocapitalize_none, false);
    } else {
        // --- AQUÍ EL TRUCO: Si hace clic fuera y el input estaba activo, GUARDAMOS ---
        if (input_activo) {
            // Aplicamos la misma lógica que el ENTER
            global.myName = (texto_input == "") ? "Jugador" : texto_input;
            // (antes: gmda_setNewname, Gamdato se quito del juego)
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
                if (touch_mode()) keyboard_virtual_show(kbv_type_default, kbv_returnkey_done, kbv_autocapitalize_none, false);
                
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
    if (vkey(vk_control) && vkey_pressed(ord("V"))) {
        if (clipboard_has_text()) {
            var texto_pegado = clipboard_get_text();
            // Limpiamos un poco el texto pegado (quitar saltos de línea por si acaso)
            texto_pegado = string_replace_all(texto_pegado, "\n", "");
            texto_pegado = string_replace_all(texto_pegado, "\r", "");
            
            // Añadimos el texto pegado al buffer actual
            keyboard_string += texto_pegado;
        }
    }

// ESC mientras se escribe: cancelar y volver
if (vkey_pressed(vk_escape)) {
    if (menu_state == "friends_menu" && friends_state == "anadir") {
        input_activo = false; keyboard_string = ""; friends_state = "main"; menu_delay = 5;
    } else if (menu_state == "join_code") {
        input_activo = false; keyboard_string = ""; menu_state = "private"; menu_delay = 5;
    } else if (menu_state == "profile") {
        input_activo = false; keyboard_string = ""; _esc_usado = true;
        if (global.myName == "") global.myName = "Soldado";
    }
    if (touch_mode()) keyboard_virtual_hide();
}

if (!input_activo) {
    // (se cancelo con ESC)
}
else if (menu_state == "join_code") {
    // Escribir el codigo de la sala (funciona en PC, Android y HTML5)
    join_input = string_upper(string_copy(keyboard_string, 1, 16));
    if (vkey_pressed(vk_enter) && join_input != "") {
        global.codigo_a_verificar = string_trim(join_input);
        input_activo = false;
        keyboard_string = "";
        if (touch_mode()) keyboard_virtual_hide();
        menu_state = "verifying";
        ShowAllRooms();
    }
}
else if (menu_state == "friends_menu" && friends_state == "anadir") {
    // Solo actualizamos mientras no hayamos disparado la búsqueda
    if (estado_busqueda == "idle" || estado_busqueda == "error") {
        friends_search_input = keyboard_string;
    }
        
    if (vkey_pressed(vk_enter) && estado_busqueda == "idle") {
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
            request_datos_rival = ReadSimpleData("perfiles", string_upper(_val));   // los ID van en mayusculas
            
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

        if (vkey_pressed(vk_enter)) {
            // Lógica original de guardar nombre
            global.myName = (texto_input == "") ? "Jugador" : texto_input;
            // (antes: gmda_setNewname, Gamdato se quito del juego)
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
var move = vkey_pressed(ord("S")) - vkey_pressed(ord("W"));

// --- ESTADO PRINCIPAL ---
    if (menu_state == "main" && !MN_NUEVO) {   // (con el menu nuevo lo maneja scr_mn_step)
        index = clamp(index + move, 0, array_length(menu_options) - 1);

        if (vkey_pressed(vk_enter)) {
            switch(index) {
                case 0: // Ahora PLAY abre el submenú de modos
                    menu_state = "play_selection";
                    play_index = 0;
					exit;
                break;
                
                case 1: // EQUIPMENT: tus 2 armas, comprar y mejorar (scr_armas, EQUIPAMIENTO)
					menu_state = "equipo";
					scr_eq_abrir();
					menu_delay = 5;
				break;

                case 2: 
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


				case 3: // FRIENDS
				    menu_state = "friends_menu";
				    friends_index = 0;
				    friends_state = "main";
					exit;
				break;

				case 4:
				menu_state = "achievements";
				break;

				case 5: // RANKING (las cuentas con mas copas) (DatabaseFunctions)
				    menu_state = "ranking";
				    scr_ranking_abrir();
				    menu_delay = 5;
				break;

				case 6: 
				    menu_state = "profile";
					show_debug_message(">>> ENTRANDO AL PERFIL");
				break;
                
                case 7: // OPTIONS -> pantalla de AJUSTES
					menu_state = "options";
					opt_sel = 0;
					menu_delay = 5;
                break;
				
                case 8: 
                    game_end();
                break;
            }
        }
		
		

// Entrar por tecla
    if (vkey_pressed(ord("M"))) {
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
    if (vkey_pressed(vk_escape)) {
        menu_state = "main";
    }

    }	
}
else if (menu_state == "private") {
    if (global.myName != "" && global.myName != "NAME") {
        texto_input = global.myName;
    }
        p_index = clamp(p_index + move, 0, array_length(private_options) - 1);

        if (vkey_pressed(vk_enter)) {
            switch(p_index) {
				
				case 0: // CREATE ROOM
				    if (global.myName == "") global.myName = "Player_" + string(irandom(999));
				    menu_state = "setup_room"; // En lugar de connecting, vamos a configurar
				    s_index = 0;
				    global.setup_modo = 0;
				    scr_ajustes_default();   // 5 min, nivel 1, 3 banderas (se cambian en la siguiente pantalla)
				break;
				//case 0: // CREATE ROOM
				//    if (global.myName == "") global.myName = "Player_" + string(irandom(999)); // Por si acaso
				//    global.myRoomCode = "PRV_" + generar_codigo_sala(4); 
				//    menu_state = "connecting";
				//    ChangeRoom(global.myRoomCode); 
				//break;

				case 1: // JOIN WITH CODE (se escribe en el juego, sirve en celular y HTML5)
				    menu_state = "join_code";
				    join_input = "";
				    input_activo = true;
				    keyboard_string = "";
				    if (touch_mode()) keyboard_virtual_show(kbv_type_default, kbv_returnkey_go, kbv_autocapitalize_characters, false);
				break;
				
                case 2: // BACK
                    menu_state = "main";
                break;
            }
        }
        if (vkey_pressed(vk_escape)) menu_state = "play_selection";
    }
else if (menu_state == "setup_room") {
    var move = vkey_pressed(vk_down) - vkey_pressed(vk_up);
    s_index = clamp(s_index + move, 0, array_length(setup_options) - 1);

    // Cambiar valores (A/D, flechas o tocando los lados del boton)
    // Todo va directo a los ajustes reales de la partida (los mismos de la sala de espera)
    var side_move = vkey_pressed(vk_right) - vkey_pressed(vk_left);
    if (side_move != 0) {
        switch (s_index) {
            case 0: var _nm = (scr_modo() == 8) ? 2 : 4; global.setup_modo = (global.setup_modo + side_move + _nm) % _nm; break; // MODO (JEFE: solo 2 o 4 jugadores)
            case 1: scr_ajustes_cambiar(1, side_move); break;                           // MAPA
            case 2: scr_ajustes_cambiar(0, side_move); break;                           // TIEMPO
            case 3: scr_ajustes_cambiar(2, side_move); break;                           // BANDERAS
        }
    }

    // Cupo de la sala segun el modo: 1vs1 = 2, 2vs2 = 4, 3vs3 = 6, 4vs4 = 8
    if (scr_modo() == 8) global.setup_modo = min(global.setup_modo, 1);   // JEFE GIGANTE: maximo 4 jugadores
    global.max_players_allowed = (global.setup_modo + 1) * 2;

    // Textos (siempre muestran lo que de verdad se va a jugar)
    var mod_text = ["1 VS 1", "2 VS 2", "3 VS 3", "4 VS 4"];
    if (scr_modo() == 8) mod_text = ["2 JUGADORES", "4 JUGADORES", "4 JUGADORES", "4 JUGADORES"];   // JEFE: todos juntos
    setup_options[0] = "MODO: " + mod_text[global.setup_modo];
    setup_options[1] = "MAPA: " + scr_ajustes_texto(1);
    setup_options[2] = "TIEMPO: " + scr_ajustes_texto(0);
    setup_options[3] = "BANDERAS PARA GANAR: " + scr_ajustes_texto(2);
    setup_options[4] = "CREAR SALA";

    if (vkey_pressed(vk_enter) && s_index == 4) { // CREAR SALA

        // si el input estaba activo o el texto cambio, actualizamos YA
        if (texto_input != "Escribe tu nombre..." && texto_input != "" && texto_input != "Name") {   // "Name" = el cuadro sin tocar (no es tu nombre)
            global.myName = texto_input;
        }

        global.setup_mapa = global.match_mapa;
        var _prefijo = "MAX" + string(global.max_players_allowed) + "_";
        global.myRoomCode = _prefijo + generar_codigo_sala(4);

        menu_state = "connecting";
        ChangeRoom(global.myRoomCode);
    }

    if (vkey_pressed(vk_escape)) menu_state = "private";
}
else if (menu_state == "offline_setup") {
    var move = vkey_pressed(vk_down) - vkey_pressed(vk_up);
    off_index = clamp(off_index + move, 0, array_length(offline_options) - 1);

    var side_move = vkey_pressed(vk_right) - vkey_pressed(vk_left);

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
    if (vkey_pressed(vk_enter)) {
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
    if (vkey_pressed(vk_escape)) menu_state = "main";
}
else if (menu_state == "play_selection") {
        play_index = clamp(play_index + move, 0, array_length(play_modes) - 1);

        if (vkey_pressed(vk_enter)) {
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
        if (vkey_pressed(vk_escape)) menu_state = "main";
    }
else if (menu_state == "options") {
    // --- AJUSTES: W/S elegir, A/D (o ENTER) cambiar, ESC volver. Se guarda solo. ---
    var _ofilas = opt_filas();
    opt_sel = clamp(opt_sel + (vkey_pressed(vk_down) - vkey_pressed(vk_up)), 0, array_length(_ofilas) - 1);
    var _olado = vkey_pressed(vk_right) - vkey_pressed(vk_left);
    if (vkey_pressed(vk_enter)) _olado = 1;
    if (_olado != 0) opt_cambiar(opt_sel, _olado);
    if (vkey_pressed(vk_escape)) {
        opt_guardar();
        menu_state = "main";
    }
}
else if (menu_state == "friends_menu") {
    // --- SALIR HACIA ATRÁS ---
    if (vkey_pressed(vk_escape)) {
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

    var move = vkey_pressed(vk_down) - vkey_pressed(vk_up);
    
    if (friends_state == "main") {
        friends_index = clamp(friends_index + move, 0, array_length(friends_options) - 1);
        
        if (vkey_pressed(vk_enter)) {
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
        var move = vkey_pressed(vk_down) - vkey_pressed(vk_up);
        
        // Arrastrar con el dedo / mouse
        if (device_mouse_check_button(0, mb_left)) {
            var _dy = device_mouse_y_to_gui(0) - drag_prev_y;
            if (device_mouse_check_button_pressed(0, mb_left)) _dy = 0;
            scroll_target = clamp(scroll_target + _dy, -max(0, num_amigos - 4) * 95, 0);
        }

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
if (vkey_pressed(ord("P"))) {
    var _tag_objetivo = global.lista_amigos[friend_selected].tag;
    
    // Iniciamos la carga de datos del amigo
    estado_busqueda = "buscando";
    request_datos_rival = ReadSimpleData("perfiles", string_upper(string(_tag_objetivo)));
    
    friends_state = "perfil_amigo"; 
    input_activo = false;
}
    
}
}

	if (friends_state == "perfil_amigo") {
	    if (vkey_pressed(vk_escape)) {
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
	
	if(vkey_pressed(vk_escape))
	{
		LeaveRoom();
		menu_state="main";	
	}
}
// Verificando codigo: ESC para cancelar
if (menu_state == "verifying" && vkey_pressed(vk_escape)) {
    menu_state = "private";
}

// --- CHAT DE LA SALA (scr_objetivo): si esta abierto, ENTER manda y ESC lo cierra ---
var _chat_tomo = scr_chat_step();
var _chat_abierto = _chat_tomo || global.chat.abierto;

// --- SALIR DE LA SALA PRIVADA (con confirmacion) ---
var _lobby_input_ok = true;
if (_chat_abierto) _lobby_input_ok = false;   // con el chat abierto no se empieza ni se expulsa
// Tocar el panel de voz (scr_objetivo) no cuenta como tocar a un jugador
if (device_mouse_check_button_pressed(0, mb_left) && scr_voz_en_zona(device_mouse_x_to_gui(0), device_mouse_y_to_gui(0))) _lobby_input_ok = false;
if (menu_state == "lobby_espera") {
    var _sgw = display_get_gui_width();
    var _sgh = display_get_gui_height();
    var _su  = clamp(min(_sgw / 1280, _sgh / 720), 0.6, 1.6);
    var _sgx = device_mouse_x_to_gui(0);
    var _sgy = device_mouse_y_to_gui(0);
    var _sclick = device_mouse_check_button_pressed(0, mb_left);

    if (!confirmar_salida) {
        // Abrir la ventanita: ESC o el boton SALIR de arriba a la izquierda
        var _pedir = vkey_pressed(vk_escape);
        if (_sclick && point_in_rectangle(_sgx, _sgy, 20 * _su, 20 * _su, 170 * _su, 64 * _su)) _pedir = true;
        if (_chat_abierto) _pedir = false;   // ESC cerro el chat, no abre esta ventanita
        if (_pedir) {
            confirmar_salida = true;
            salir_sel = 1; // por defecto: NO, QUEDARME
            show_kick_menu = false;
            _lobby_input_ok = false;
        }
    } else {
        _lobby_input_ok = false;

        // Botones SI / NO (mismas medidas que en el Draw)
        var _bw  = 200 * _su;
        var _bh  = 48 * _su;
        var _by  = _sgh / 2 + 40 * _su;
        var _bx0 = _sgw / 2 - _bw - 12 * _su;
        var _bx1 = _sgw / 2 + 12 * _su;

        if (vkey_pressed(vk_left) || vkey_pressed(vk_right)) salir_sel = 1 - salir_sel;

        var _elegido = -1;
        if (point_in_rectangle(_sgx, _sgy, _bx0, _by, _bx0 + _bw, _by + _bh)) { salir_sel = 0; if (_sclick) _elegido = 0; }
        if (point_in_rectangle(_sgx, _sgy, _bx1, _by, _bx1 + _bw, _by + _bh)) { salir_sel = 1; if (_sclick) _elegido = 1; }
        if (vkey_pressed(vk_enter)) _elegido = salir_sel;
        if (vkey_pressed(vk_escape)) _elegido = 1;

        if (_elegido == 1) {
            // Se queda en la sala
            confirmar_salida = false;
        }
        else if (_elegido == 0) {
            // Se sale (igual que cuando el lider expulsa a alguien)
            confirmar_salida = false;
            LeaveRoom();
            global.roomId = -1;
            global.myRoomCode = "";
            with(oOtherPlayer) instance_destroy();
            menu_state = "private";
            menu_delay = 5;
            show_debug_message(">>> SALA: el jugador salio por su cuenta.");
        }
    }
}

// Cambiar de equipo: tocar un lugar con BOT del otro equipo (scr_objetivo)
if (menu_state == "lobby_espera" && _lobby_input_ok && device_mouse_check_button_pressed(0, mb_left)) {
    if (scr_sala_toque_cambio(device_mouse_x_to_gui(0), device_mouse_y_to_gui(0))) _lobby_input_ok = false;
}

// --- BOTON LISTO (scr_objetivo): Enter/OK o tocar el letrero de abajo ---
var _toque_pie = false;
if (menu_state == "lobby_espera") {
    scr_sala_listo_step();
    if (_lobby_input_ok && device_mouse_check_button_pressed(0, mb_left) && variable_instance_exists(id, "sala_pie_x1")) {
        _toque_pie = point_in_rectangle(device_mouse_x_to_gui(0), device_mouse_y_to_gui(0), sala_pie_x1, sala_pie_y1, sala_pie_x2, sala_pie_y2);
    }
    if (_lobby_input_ok && !oBrain.AmIPseudoHost && (vkey_pressed(vk_enter) || _toque_pie)) {
        scr_sala_listo_poner(!global.sala_listo);
    }
}

if (menu_state == "lobby_espera" && _lobby_input_ok) {
if (oBrain.AmIPseudoHost) {
    var mx = device_mouse_x_to_gui(0);
    var my = device_mouse_y_to_gui(0);

    // 1. Detectar Click Derecho sobre un slot
    // En PC: clic derecho sobre un jugador. En el celular: tocarlo.
    var _kick_tap = touch_mode() && device_mouse_check_button_pressed(0, mb_left) && !show_kick_menu;
    if (mouse_check_button_pressed(mb_right) || _kick_tap) {
        // Las mismas casillas que se dibujan (scr_objetivo): solo se puede sacar a personas, no a mi ni a los bots
        var _found = false;
        var _sl = scr_sala_slots();
        for (var _t = 0; _t < 2 && !_found; _t++) {
            var _lista = (_t == 0) ? _sl.azul : _sl.rojo;
            for (var k = 0; k < array_length(_lista); k++) {
                var _s = _lista[k];
                if (_s.tipo != "humano") continue;
                var _pos = scr_sala_slot_pos(_t == 1, k);
                if (mx > _pos[0] && mx < _pos[0] + 400 && my > _pos[1] && my < _pos[1] + 60) {
                    kick_target_id = _s.cid;
                    kick_menu_x = mx;
                    kick_menu_y = my;
                    show_kick_menu = true;
                    _found = true;
                    break;
                }
            }
        }
        if (!_found) show_kick_menu = false;
    }

    // 2. Lógica de Click Izquierdo en el botón "EXPULSAR"
    if (show_kick_menu && mouse_check_button_pressed(mb_left) && !_kick_tap) {
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
        // Los ajustes ya se eligieron al crear la sala. Se mandan cada 2 segundos
        // (por si el líder se va y otro queda de líder, que los tenga)
        lobby_sync_cd -= 1;
        if (lobby_sync_cd <= 0) {
            lobby_sync_cd = room_speed * 2;
            scr_ajustes_enviar();
        }

        // Empezar: S en el teclado. En el celular, OK (ahí la flecha de abajo también cuenta como S
        // y ahora sirve para elegir los ajustes, así que no debe arrancar la partida).
        var _empezar = vkey_pressed(vk_enter) || _toque_pie;
        // Solo se puede empezar cuando todas las personas dieron LISTO (scr_objetivo)
        if (_empezar && scr_sala_faltan_listos() > 0) {
            _empezar = false;
            listo_aviso_t = room_speed * 2;
        }
        if (_empezar) {
            // Ya no hay que esperar a que se llene: los espacios vacios los juegan bots (scr_objetivo)
            var _dest = scr_mapa_resolver();  // si es ALEATORIO, el líder elige aquí (una sola vez)
            var _aj = scr_ajustes_struct();   // ya lleva el mapa elegido: todos van al mismo
            scr_sala_roster_fijar(_aj);       // quienes juegan: nadie mas entra a media partida (scr_objetivo)
            scr_partida_estado_nuevo();       // seleccion de personaje desde cero (scr_objetivo)
            global.botnet_defs = scr_sala_bots();
            with(oOtherPlayer) {
                if (!es_bot) SendEventToClient(clientId, "GO_TO_BATTLE", _aj);
            }
            room_goto(_dest);
        }
    }
}
if (menu_state == "profile") {
    // 1. Activar edición con la tecla E
    if (vkey_pressed(ord("E"))) {
        if (!input_activo && !mostrando_selector) {
            input_activo = true;
            keyboard_string = global.myName; // Empezamos con el nombre actual
            if (touch_mode()) keyboard_virtual_show(kbv_type_default, kbv_returnkey_done, kbv_autocapitalize_none, false);
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
        if (vkey_pressed(vk_enter)) {
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
    if (vkey_pressed(vk_escape) && !input_activo && !mostrando_selector && !_esc_usado) {
        menu_state = "main";
    }
	
if (vkey_pressed(ord("B")) && !input_activo) {
	var PLAYER_ID = string(global.miFriendTag);   // antes era el ID de Gamdato
        var _id_buscado = get_string("Introduce el ID ÚNICO del jugador:", "");
        
        if (_id_buscado != "" && _id_buscado != string(PLAYER_ID)) {
            estado_busqueda = "buscando";
            // PASO DIRECTO: Leemos el perfil usando el ID como nombre de documento
            request_datos_rival = ReadSimpleData("perfiles", string_upper(string(_id_buscado)));
            
            show_debug_message(">>> BUSCADOR: Pidiendo perfil del ID: " + string(_id_buscado));
        }
    }
	
    
    // Abrir selector con A
    if (vkey_pressed(ord("A")) && !mostrando_selector && !input_activo) {
        mostrando_selector = true;
        avatar_seleccionado = global.avatar_id; // Empezar en el actual
    }
    
    // Si la ventanita está abierta
if (mostrando_selector) {
// Scroll con la rueda del ratón
    if (mouse_wheel_up())   scroll_y_target -= 60;
    if (mouse_wheel_down()) scroll_y_target += 60;
    // Arrastrar con el dedo / mouse
    if (device_mouse_check_button(0, mb_left) && !device_mouse_check_button_pressed(0, mb_left)) {
        scroll_y_target -= device_mouse_y_to_gui(0) - drag_prev_y;
    }

    // Movimiento con flechas (Mantenemos lo de antes)
    var total_iconos = sprite_get_number(spr_player_icon);
    var columnas = 4;
    var prev_sel = avatar_seleccionado;

    if (vkey_pressed(vk_right)) avatar_seleccionado = clamp(avatar_seleccionado + 1, 0, total_iconos - 1);
    if (vkey_pressed(vk_left))  avatar_seleccionado = clamp(avatar_seleccionado - 1, 0, total_iconos - 1);
    if (vkey_pressed(vk_down))  avatar_seleccionado = clamp(avatar_seleccionado + columnas, 0, total_iconos - 1);
    if (vkey_pressed(vk_up))    avatar_seleccionado = clamp(avatar_seleccionado - columnas, 0, total_iconos - 1);

    // AUTO-SCROLL: Si el seleccionado se sale por abajo o por arriba, movemos el scroll
    var fila_actual = floor(avatar_seleccionado / columnas);
    var y_en_grid = fila_actual * 120;
    
    if (y_en_grid < scroll_y_target) scroll_y_target = y_en_grid;
    if (y_en_grid > scroll_y_target + 120) scroll_y_target = y_en_grid - 120;

    // Limitar el scroll para que no se vaya al infinito
    var filas_totales = ceil(total_iconos / columnas);
    var max_scroll = max(0, (filas_totales * 120) - 240);
    scroll_y_target = clamp(scroll_y_target, 0, max_scroll);

    if (vkey_pressed(vk_space) || vkey_pressed(vk_escape)) mostrando_selector = false;

    if (vkey_pressed(vk_enter)) {
// --- DENTRO DEL IF (vkey_pressed(vk_enter)) ---
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
            request_datos_rival = ReadSimpleData("perfiles", string_upper(string(ultimo_intento_busqueda)));
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

if (menu_state == "ranking") scr_ranking_step();   // (DatabaseFunctions)
if (menu_state == "equipo") scr_eq_step();        // EQUIPAMIENTO (scr_armas)

if (menu_state == "achievements") {
    if (vkey_pressed(vk_escape)) {
        menu_state = "main";
    }
	
	var move_scroll = (mouse_wheel_down() - mouse_wheel_up()) * 40;
    move_scroll += (vkey(vk_down) - vkey(vk_up)) * 10;
    if (device_mouse_check_button(0, mb_left) && !device_mouse_check_button_pressed(0, mb_left)) {
        move_scroll -= device_mouse_y_to_gui(0) - drag_prev_y;
    }
    scroll_target = clamp(scroll_target + move_scroll, 0, scroll_max);
    
    // Interpolación suave para que no sea un movimiento brusco
    scroll_y = lerp(scroll_y, scroll_target, 0.15);
}



if (estado_busqueda == "encontrado" && vkey_pressed(ord("F"))) {
    if (is_struct(datos_busqueda_resultado)) {
        var id_rival = string(ultimo_intento_busqueda); 
        var mi_id = string(global.miFriendTag);   // antes era el ID de Gamdato
        
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
    // Buzon con varias solicitudes: W/S elegir, Y aceptar, N rechazar (DatabaseFunctions, BUZON)
    scr_buzon_step();
    
    if (vkey_pressed(vk_escape)) {
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
    if (vkey_pressed(vk_enter)) {
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
    if (vkey_pressed(vk_escape) || reto_timer <= 0) {
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

// Posicion del dedo / mouse de este frame (para el scroll arrastrando)
drag_prev_y = device_mouse_y_to_gui(0);
