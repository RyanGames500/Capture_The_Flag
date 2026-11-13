function scr_add_kill() {
    global.kills += 1;
    scr_xp_dar(3);   // un poquito de XP por cada baja (scr_reloj)
    
    // Guardamos el progreso inmediatamente
    scr_save_to_local();
    scr_save_to_cloud();
    
    show_debug_message(">>> KILL REGISTRADA: " + string(global.kills));
}