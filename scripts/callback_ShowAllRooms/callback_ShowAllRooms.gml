function callback_ShowAllRooms(_rooms_array) {
    if (instance_exists(oMenu) && oMenu.menu_state == "verifying") {
        var _existe = false;
        
        for (var i = 0; i < array_length(_rooms_array); i++) {
            var _data = _rooms_array[i];
            var _id_actual = "";
            var _cant_jugadores = 0;

            // 1. Detectar si es un objeto (Struct) o solo texto (String)
            if (is_struct(_data)) {
                _id_actual = string(_data.roomId);
                _cant_jugadores = _data.clientCount;
            } else {
                _id_actual = string(_data);
                _cant_jugadores = 0; // En modo simple no sabemos cuántos hay, asumimos que cabe
            }

            // 2. Comparar con el código que escribió el usuario
            if (_id_actual == global.codigo_a_verificar) {
                
                // 3. Verificar límite de jugadores (solo si el servidor nos dio el dato)
                if (_cant_jugadores >= 8 && is_struct(_data)) {
                    oMenu.menu_state = "private";
                    show_message_async("La sala está llena (8/8).");
                    return;
                }
                
                _existe = true;
                break;
            }
        }
        
        if (_existe) {
            oMenu.menu_state = "connecting";
            global.myRoomCode = global.codigo_a_verificar;
            ChangeRoom(global.myRoomCode);
        } else {
            oMenu.menu_state = "private"; 
            show_message_async("Error: La sala no existe.");
        }
    }
}


/*
function callback_ShowAllRooms(_rooms_array) {
    // Usamos oMenu.menu_state para que oBrain sepa a qué variable te refieres
    if (instance_exists(oMenu) && oMenu.menu_state == "verifying") {
        var _existe = false;
        
        for (var i = 0; i < array_length(_rooms_array); i++) {
            var _rName = (is_struct(_rooms_array[i])) ? _rooms_array[i].roomId : _rooms_array[i];
            
            if (_rName == global.codigo_a_verificar) {
                _existe = true;
                break;
            }
        }
        
        if (_existe) {
            oMenu.menu_state = "connecting";
            global.myRoomCode = global.codigo_a_verificar;
            ChangeRoom(global.myRoomCode);
        } else {
            oMenu.menu_state = "private"; 
            show_message_async("La sala no existe o el código es incorrecto.");
        }
    }
}


/*
function callback_ShowAllRooms(array_of_rooms){
	//What do you want to do with the array of all 
	// rooms on your server?
	show_message(string(is_array(array_of_rooms)) +"  "+ string(array_of_rooms));
	
}