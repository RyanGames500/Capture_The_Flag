function callback_ChangeRoom(new_room_id) {
    
    // --- NUEVA LÓGICA PARA DUELOS ---
    // Si el nombre de la sala empieza por "duelo_", saltamos al mapa de combate
    if (string_count("duelo_", new_room_id)) {
        show_debug_message(">>> RED: Entrando a sala de duelo privada: " + new_room_id);
        room_goto(rm_stage1); // O el mapa que uses para 1vs1
    }

    if (!string_count("auto_matchmake", new_room_id)) {
        oMenu.menu_state = "lobby_espera";
    }
    
    if (string_count("auto_match_", new_room_id)) {
        room_goto(rm_stage2);
    }
}

/*
function callback_ChangeRoom(new_room_id){


    if(string_count("auto_match_", new_room_id)){
        room_goto(rm_stage1);
		
    }
	
    if(string_count("public", new_room_id)){
        room_goto(rm_game);
    }
	
}