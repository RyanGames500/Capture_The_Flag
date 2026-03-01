function scr_add_kill() {
    global.kills += 1;
    global.xp += 10; // Opcional: ¡Dar un poco de XP por cada kill es motivador!
    
    // Guardamos el progreso inmediatamente
    scr_save_to_local();
    scr_save_to_cloud();
    
    show_debug_message(">>> KILL REGISTRADA: " + string(global.kills));
}