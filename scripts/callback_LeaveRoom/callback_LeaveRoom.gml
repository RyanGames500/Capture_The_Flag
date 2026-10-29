function callback_LeaveRoom(){
    // 1. Variables de Juego (Puntaje y Estado)
    global.game_over = false;
    global.pausa = false; 
    global.puntos_rojo = 0;
    global.puntos_azul = 0;
    global.winner_team = 0;

    // 2. RESET DE SELECCIÓN (Lo más importante para que no falle la próxima)
    global.mi_listo = false;       // Para que te deje presionar Enter otra vez
    global.rival_listo = false;    // Para que el rival no aparezca como "Ready"
    global.pj_selected = 0;        // Vuelve al primer personaje (Asalto)
    global.pj_rival = -1;          // -1 significa "Vacío" o "Buscando"

    // 3. Control del Cerebro (oBrain)
    if (instance_exists(oBrain)) {
        oBrain.intro_disparada = false; // FUNDAMENTAL: Para que vuelva a dibujar el GUI de selección
        oBrain.timer_intro = 60 * 60;   // Resetea el tiempo a 15 segundos
        
        // Otras limpiezas que ya tenías
        oBrain.ammo_spawned = false;
        oBrain.weapons_spawned = false;
        oBrain.victory_alpha = 0; 
        oBrain.puntos_procesados = false;
    }

    // 4. Limpieza de Instancias
    instance_destroy(oOtherPlayer); // Borramos al rival anterior
    
    // 5. Reset del Sistema
    window_set_cursor(cr_arrow);
    show_debug_message(">>> LOBBY LIMPIO: Selección reseteada correctamente.");

    // Limpiar el aviso de abandono por si se salió con ESC
    if (instance_exists(oBrain)) {
        oBrain.abandono_activo = false;
        oBrain.abandono_check = -1;
    }    
        
    room_goto(rm_menu);
}


/*
function callback_LeaveRoom(){
//called after you have left a room
//you are back to your private room now 

	//show_message("back to my private room");

// 1. Limpiamos las variables para la próxima partida
    global.game_over = false;
    global.puntos_rojo = 0;
    global.puntos_azul = 0;
    global.winner_team = 0;
    oBrain.ammo_spawned=false;
	oBrain.weapons_spawned=false;
	//instance_destroy(oMouseIcon_falso);
    // 2. Quitamos el mensaje de "back to my private room" para que no moleste
    show_debug_message("Regresé a mi sala privada con éxito.");

    // 3. Volvemos al menú principal
    room_goto(rm_menu);
}