function scr_add_loss() {
    scr_eq_premio(20);   // monedas (scr_armas, EQUIPAMIENTO)
    global.losses += 1;
    global.xp += 5; // Opcional: Dar un poquito de XP aunque pierda por "consolación"
	global.copas = max(0, global.copas - 15);
    
    //scr_check_levelup();
    scr_save_to_local();
    scr_save_to_cloud();
}