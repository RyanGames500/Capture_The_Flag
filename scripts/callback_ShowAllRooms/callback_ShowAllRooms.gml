function callback_ShowAllRooms(_rooms_array) {
    if (instance_exists(oMenu) && oMenu.menu_state == "verifying") {
        var _existe = false;
        
        for (var i = 0; i < array_length(_rooms_array); i++) {
            var _data = _rooms_array[i];
            var _id_actual = is_struct(_data) ? string(_data.roomId) : string(_data);

            if (_id_actual == global.codigo_a_verificar) {
                _existe = true;
                break;
            }
        }
        
        if (_existe) {
            // CAMBIO CLAVE: Antes de entrar, pedimos los clientes exactos
            // No hacemos ChangeRoom todavía.
            ShowAllClientsInRoom(global.codigo_a_verificar);
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