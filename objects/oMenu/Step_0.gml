// Navegación
var move = keyboard_check_pressed(vk_down) - keyboard_check_pressed(vk_up);
index += move;

// Envolver el índice para que no se salga del arreglo
if (index < 0) index = array_length(menu_options) - 1;
if (index >= array_length(menu_options)) index = 0;

// Seleccionar opción
if (keyboard_check_pressed(vk_enter)) 
{
    switch(index) {
		case 0: // PLAY
	    menu_state = "connecting";
		//room_goto(rm_game_offline)
	    //ChangeRoom("public");
		ChangeRoom("auto_matchmake_2");
	    break;
        case 1: // OPTIONS
            show_message("Aquí irían las opciones...");
            break;
        case 2: // EXIT
            game_end();
            break;
    }
}

if (menu_state == "connecting") {
    waiting_timer++;
    if (waiting_timer > room_speed) waiting_timer = 0; // Reinicia cada segundo
}