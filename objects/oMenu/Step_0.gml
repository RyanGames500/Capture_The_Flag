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

    if (keyboard_check_pressed(vk_enter)) 
    {
        // Por seguridad, si el jugador nunca hizo clic en el cuadro, 
        // guardamos lo que haya en texto_input antes de entrar
        if (global.myName == "") global.myName = (texto_input == "" || texto_input == "Escribe tu nombre...") ? "Jugador" : texto_input;

        switch(index) {
            case 0: // PLAY
                menu_state = "connecting";
                // Aquí es vital: primero nos aseguramos de estar conectados 
                // y luego cambiamos de room
                //ChangeRoom("public");
				ChangeRoom("auto_matchmake_4");
            break;
            case 1: // OPTIONS
                show_message("Opciones...");
            break;
            case 2: // EXIT
                game_end();
            break;
        }
    }
}

if (menu_state == "connecting") {
    waiting_timer++;
    if (waiting_timer > room_speed) waiting_timer = 0; // Reinicia cada segundo
}