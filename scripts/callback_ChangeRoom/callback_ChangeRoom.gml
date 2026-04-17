function callback_ChangeRoom(new_room_id) {
    // Si entramos a una sala y ya hay alguien más ahí esperándonos
    if (!string_count("auto_matchmake", new_room_id)) {
        // Si el contador de otros jugadores es mayor a 0, saltamos de una
            oMenu.menu_state = "lobby_espera";
        
    }
    
    // Tu lógica de matchmaking de antes...
    if(string_count("auto_match_", new_room_id)){
        room_goto(rm_stage1);
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