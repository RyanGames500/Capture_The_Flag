// --- ALARMA 2: REFRESCO DE STATUS ---
if (array_length(global.lista_amigos) > 0) {
    for (var i = 0; i < array_length(global.lista_amigos); i++) {
        var _amigo = global.lista_amigos[i];
        
        // Usamos tu función para actualizar el valor interno del struct
        // Esto guarda el resultado (true/1 o false/0) directamente en el amigo
        // (antes: gmda_status, que decia si TU estabas en Gamdato, no tu amigo)
        if (!variable_struct_exists(_amigo, "online")) _amigo.online = false;
    }
}

// Le pregunto al servidor cuales de mis amigos estan conectados (DatabaseFunctions, AMIGOS EN LINEA)
scr_amigos_online_pedir();

// Volvemos a activar la alarma para dentro de 5 segundos
alarm[2] = room_speed * 5;