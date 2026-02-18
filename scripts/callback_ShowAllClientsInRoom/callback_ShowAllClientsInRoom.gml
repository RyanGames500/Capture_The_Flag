function callback_ShowAllClientsInRoom(_array_of_clients) {
    if (instance_exists(oMenu) && oMenu.menu_state == "verifying") {
        
        var _codigo = global.codigo_a_verificar;
        var _limite_detectado = 8; // Por defecto si no encuentra el prefijo

        // --- DETECTAR LÍMITE DESDE EL NOMBRE DEL CÓDIGO ---
        if (string_pos("MAX2_", _codigo) != 0) _limite_detectado = 2;
        else if (string_pos("MAX4_", _codigo) != 0) _limite_detectado = 4;
        else if (string_pos("MAX6_", _codigo) != 0) _limite_detectado = 6;
        else if (string_pos("MAX8_", _codigo) != 0) _limite_detectado = 8;

        if (is_array(_array_of_clients)) {
            var _cantidad = array_length(_array_of_clients);
            
            // Comparamos contra el límite que venía en el nombre de la sala
            if (_cantidad < _limite_detectado) {
                oMenu.menu_state = "connecting"; 
                global.myRoomCode = _codigo;
                global.max_players_allowed = _limite_detectado; // Sincronizamos la variable local
                ChangeRoom(_codigo);
            } else {
                oMenu.menu_state = "private";
                show_message_async("SALA LLENA: El límite de esta sala es de " + string(_limite_detectado) + " jugadores.");
            }
        }
    } else if (instance_exists(oMenu) && oMenu.menu_state == "lobby_espera") {
        if (is_array(_array_of_clients)) {
            global.jugadores_en_sala = array_length(_array_of_clients);
        }
    }
}