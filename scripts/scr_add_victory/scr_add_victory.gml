function scr_add_victory() {
    global.wins += 1;
    global.xp += 50; // Recompensa de XP por ganar
    
	
	// --- SISTEMA DE COPAS ---
    global.copas += 25;
	
    // Subir nivel si alcanzó 100 XP
    if (global.xp >= 100) {
        global.lvl += 1;
        global.xp -= 100;
    }
    
    scr_save_to_local();  // Tu función de guardado INI
    scr_save_to_cloud();  // Tu función de guardado Gamdato
    show_debug_message("Victoria registrada y guardada !!!");
}