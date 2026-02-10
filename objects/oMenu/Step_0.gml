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
    index += move;

    if (index < 0) index = array_length(menu_options) - 1;
    if (index >= array_length(menu_options)) index = 0;

    // Suavizado de posición (Lerp)
    for (var i = 0; i < array_length(menu_options); i++) {
        var target = (i == index) ? 30 : 0; // Se mueve 30px a la derecha si está seleccionada
        menu_x_offset[i] = lerp(menu_x_offset[i], target, 0.15);
    }

    // Cambiar modo de juego solo si estamos en PLAY (Horizontal)
    if (index == 0) {
        var change_mode = keyboard_check_pressed(vk_right) - keyboard_check_pressed(vk_left);
        if (change_mode != 0) {
            mode_index = clamp(mode_index + change_mode, 0, array_length(game_modes) - 1);
            if (global.sfx) audio_play_sound(snd_hit, 5, false, 2); // Sonido agudo de clic
        }
		
		// Cambiar tipo de juego con la tecla ESPACIO o TAB
    if (keyboard_check_pressed(vk_tab)) {
        if (global.gameMode == MODOS.CTF) global.gameMode = MODOS.DESTROY;
        else global.gameMode = MODOS.CTF;
    }
    }

    if (keyboard_check_pressed(vk_enter)) 
    {
        if (global.myName == "") global.myName = (texto_input == "" || texto_input == "Escribe tu nombre...") ? "Jugador" : texto_input;

        switch(index) {
            case 0: // PLAY
                menu_state = "connecting";
                
                // --- LÓGICA DE MATCHMAKING DINÁMICA ---
                // Dependiendo del modo, entramos a una sala distinta
                // auto_matchmake_2 (1vs1), auto_matchmake_4 (2vs2), etc.
                var slots_necesarios = (mode_index + 1) * 2; 
                ChangeRoom("auto_matchmake_" + string(slots_necesarios));
            break;
            
            case 1: show_message("Opciones..."); break;
            case 2: game_end(); break;
        }
    }
}

if (menu_state == "connecting") {
    waiting_timer++;
    if (waiting_timer > room_speed) waiting_timer = 0; // Reinicia cada segundo
}