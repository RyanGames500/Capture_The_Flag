// --- ALARMA 2: REFRESCO DE STATUS ---
if (array_length(global.lista_amigos) > 0) {
    for (var i = 0; i < array_length(global.lista_amigos); i++) {
        var _amigo = global.lista_amigos[i];
        
        // Usamos tu función para actualizar el valor interno del struct
        // Esto guarda el resultado (true/1 o false/0) directamente en el amigo
        _amigo.online = gmda_status(_amigo.tag); 
    }
}

// Volvemos a activar la alarma para dentro de 5 segundos
alarm[2] = room_speed * 5;