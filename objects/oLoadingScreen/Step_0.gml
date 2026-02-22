// Manejo de estados de la pantalla
if (state == "fade_in") {
    alpha += 0.05;
    if (alpha >= 1) state = "waiting";
}

if (state == "waiting") {
    if (!conector_listo) {
        timer_timeout--;
        
        if (timer_timeout <= 0) {
            mensaje = "FALLO LA CONEXION CON EL SERVIDOR";
            
            // --- NUEVA LOGICA DE SELECCION ---
            // Si no existe, la creamos
            if (!variable_instance_exists(id, "error_sel")) error_sel = 0; 

            var move = keyboard_check_pressed(vk_down) - keyboard_check_pressed(vk_up);
            error_sel = clamp(error_sel + move, 0, 1);

if (keyboard_check_pressed(vk_enter) || mouse_check_button_pressed(mb_left)) {
    if (error_sel == 0) { 
        game_restart(); // REINTENTAR
    } else {
        // --- SALTO DIRECTO A PRACTICA ---
        global.ONLINE = false;
        
        if (instance_exists(oMenu)) {
            with(oMenu) {
                menu_state = "offline_setup";
                off_index = 0;
                
                // Inicializamos los valores por defecto para que el dibujo no falle
                global.off_mapa = 0;
                global.off_flags = 3;
                global.off_bots = 0;
                
                // IMPORTANTE: Rellenamos el array de opciones que usa tu Draw
                offline_options = [
                    "MAPA: BOSQUE",
                    "OBJETIVO: 3 BANDERAS",
                    "ENEMIGOS: SOLO (PRACTICA)",
                    "INICIAR BATALLA",
                    "BACK"
                ];
            }
        }
        state = "fade_out"; // Cerramos la carga y ya estaremos en el menú de práctica
    }
}
        }
    }
    
    if (conector_listo) {
        global.ONLINE = true;
        state = "fade_out";
    }
}

if (state == "fade_out") {
    alpha -= 0.05;
    if (alpha <= 0) instance_destroy();
}