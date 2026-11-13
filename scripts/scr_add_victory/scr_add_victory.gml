function scr_add_victory() {
    scr_eq_premio(50);   // monedas (scr_armas, EQUIPAMIENTO)
    global.wins += 1;
    scr_xp_dar(30);   // XP por ganar (scr_reloj)
    
	
	// --- SISTEMA DE COPAS ---
    global.copas += 25;
	
    
    scr_save_to_local();  // Tu función de guardado INI
    scr_save_to_cloud();  // Tu función de guardado Gamdato
    show_debug_message("Victoria registrada y guardada !!!");
}