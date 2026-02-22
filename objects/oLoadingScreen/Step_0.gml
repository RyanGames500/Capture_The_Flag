// Manejo de estados de la pantalla
if (state == "fade_in") {
    alpha += 0.05;
    if (alpha >= 1) state = "waiting";
}

if (state == "waiting") {
    // 1. Si NO ha conectado todavía...
    if (!conector_listo) {
        timer_timeout--;
        
        // 2. Si el tiempo se acabó (No hay internet o server caído)
        if (timer_timeout <= 0) {
            mensaje = "FALLÓ LA CONEXIÓN\n\n> CLIC PARA JUGAR OFFLINE <";
            
            // 3. Al hacer clic, forzamos la entrada al menú
            if (mouse_check_button_pressed(mb_left)) {
                global.ONLINE = false; // Bloquea funciones de red
                
                // Si tienes un oMenu, lo preparamos para el modo offline
                if (instance_exists(oMenu)) {
                    oMenu.menu_state = "online_menu"; 
                }
                
                // Cerramos la pantalla de carga para entrar al juego
                state = "fade_out"; 
            }
        }
    }
    
    // Si conectó bien (conector_listo se vuelve true desde el callback de red)
    if (conector_listo) {
        global.ONLINE = true;
        state = "fade_out";
    }
}

if (state == "fade_out") {
    alpha -= 0.05;
    if (alpha <= 0) instance_destroy();
}