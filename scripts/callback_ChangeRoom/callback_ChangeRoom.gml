function callback_ChangeRoom(new_room_id){
    // GUARDAMOS el ID real en nuestra global para usarlo después

    if(string_count("auto_match_", new_room_id)){
        room_goto(rm_game);
    }
	
    if(string_count("public", new_room_id)){
        room_goto(rm_game);
    }
	
}