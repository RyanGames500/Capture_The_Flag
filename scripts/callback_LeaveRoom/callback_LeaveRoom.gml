function callback_LeaveRoom(){
    // 1. Limpiamos variables globales de juego
    global.game_over = false;
    global.pausa = false; // ¡IMPORTANTE! Si no, el menú principal podría salir pausado
    global.puntos_rojo = 0;
    global.puntos_azul = 0;
    global.winner_team = 0;

    // 2. Limpiamos variables de control del oBrain
    if (instance_exists(oBrain)) {
        oBrain.ammo_spawned = false;
        oBrain.weapons_spawned = false;
        oBrain.victory_alpha = 0; // Resetear el fade de la victoria
        // Si usas intro estilo Brawl Stars:
        oBrain.intro_disparada = false;
        oBrain.timer_intro = 120; 
    }

    // 3. Limpieza de red y objetos de otros jugadores
    // Es vital destruir a los otros jugadores para que no aparezcan duplicados luego
    instance_destroy(oOtherPlayer);
    
    // 4. Resetear el cursor (por si estaba oculto)
    window_set_cursor(cr_arrow);

    // 5. Volver al menú
    show_debug_message("Regresé a mi sala privada y limpié la partida.");
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