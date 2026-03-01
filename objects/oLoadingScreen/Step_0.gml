// Manejo de estados de la pantalla
if (state == "fade_in") {
    alpha += 0.05;
    if (alpha >= 1) state = "waiting";
}



if (state == "waiting") {
    var _status = gmda_status(); 

    // 1. ESPERAR A QUE GAMDATO ESTÉ "READY"
    if (_status == 1) { 
        if (!gamdato_listo) {
            gamdato_listo = true;
            // Creamos un timer de 1 segundo (room_speed) para que la red se limpie
            timer_enfriamiento = room_speed; 
            show_debug_message(">>> GAMDATO OK. Esperando limpieza de red...");

        }
    }

    // 2. DESPUÉS DEL ENFRIAMIENTO, INICIAMOS ROCKET
    if (gamdato_listo && !conector_listo) {
        if (!variable_instance_exists(id, "rocket_pedido")) {
            timer_enfriamiento--;
            mensaje = "SINCRONIZANDO PERFIL...";
            
			
			
            if (timer_enfriamiento <= 0) {
                rocket_pedido = true;
                show_debug_message(">>> INICIANDO ROCKET AHORA.");
                if (!instance_exists(oBrain)) {
                    instance_create_layer(0, 0, "Instances", oBrain);
                }
            }
        } else {
            mensaje = "ESTABLECIENDO CONEXION SEGURA...";
            timer_timeout--;
        }
    } else if (!gamdato_listo) {
        mensaje = "SINCRONIZANDO PERFIL...";
        timer_timeout--;
    }

    // 3. ÉXITO FINAL
    if (conector_listo) {
        global.ONLINE = true;
        state = "fade_out";
		if (!variable_instance_exists(id, "nube_cargada")) {
        nube_cargada = true;
        
        // --- AQUÍ ES SEGURO ---
        show_debug_message(">>> ROCKET CONECTADO. Ahora cargamos datos de la nube...");
        gmda_loadgamesave(); 
    }
    }

    // 4. ERROR
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



//if (state == "waiting") {
//    if (!conector_listo) {
//        timer_timeout--;
        
//        if (timer_timeout <= 0) {
//            mensaje = "FALLO LA CONEXION CON EL SERVIDOR";
            
//            // --- NUEVA LOGICA DE SELECCION ---
//            // Si no existe, la creamos
//            if (!variable_instance_exists(id, "error_sel")) error_sel = 0; 

//            var move = keyboard_check_pressed(vk_down) - keyboard_check_pressed(vk_up);
//            error_sel = clamp(error_sel + move, 0, 1);

//if (keyboard_check_pressed(vk_enter) || mouse_check_button_pressed(mb_left)) {
//    if (error_sel == 0) { 
//        game_restart(); // REINTENTAR
//    } else {
//        // --- SALTO DIRECTO A PRACTICA ---
//        global.ONLINE = false;
        
//        if (instance_exists(oMenu)) {
//            with(oMenu) {
//                menu_state = "offline_setup";
//                off_index = 0;
                
//                // Inicializamos los valores por defecto para que el dibujo no falle
//                global.off_mapa = 0;
//                global.off_flags = 3;
//                global.off_bots = 0;
                
//                // IMPORTANTE: Rellenamos el array de opciones que usa tu Draw
//                offline_options = [
//                    "MAPA: BOSQUE",
//                    "OBJETIVO: 3 BANDERAS",
//                    "ENEMIGOS: SOLO (PRACTICA)",
//                    "INICIAR BATALLA",
//                    "BACK"
//                ];
//            }
//        }
//        state = "fade_out"; // Cerramos la carga y ya estaremos en el menú de práctica
//    }
//}
//        }
//    }
    
//    if (conector_listo) {
//        global.ONLINE = true;
//        state = "fade_out";
//    }
//}

if (state == "fade_out") {
    alpha -= 0.05;
    if (alpha <= 0) instance_destroy();
}