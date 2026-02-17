function callback_ShowAllClientsInRoom(_array_of_clients) {
    // 1. Verificamos que el oMenu existe para no tirar error
    if (!instance_exists(oMenu)) return;

    // --- CASO A: El jugador está intentando UNIRSE (Verificando) ---
    if (oMenu.menu_state == "verifying") {
        
        if (is_array(_array_of_clients)) {
            var _cantidad = array_length(_array_of_clients);
            
            // Usamos global.max_players_allowed que se define al recibir la info de la sala
            // Si no la tienes definida para el invitado, por ahora dejamos el 8 o el límite que traiga la sala
            if (_cantidad < global.max_players_allowed) { 
                oMenu.menu_state = "connecting"; 
                global.myRoomCode = global.codigo_a_verificar;
                ChangeRoom(global.myRoomCode);
            } else {
                oMenu.menu_state = "private";
                show_message_async("La sala está llena (" + string(_cantidad) + "/" + string(global.max_players_allowed) + ")");
            }
        } else {
            oMenu.menu_state = "private";
            show_message_async("La sala ya no está disponible.");
        }
    } 
    
    // --- CASO B: El jugador ya está DENTRO del lobby ---
    else if (oMenu.menu_state == "lobby_espera") {
        if (is_array(_array_of_clients)) {
            global.jugadores_en_sala = array_length(_array_of_clients);
            // Aquí podrías actualizar visualmente si alguien más entró
        }
    }
}