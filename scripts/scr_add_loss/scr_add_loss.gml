function scr_add_loss() {
    scr_eq_premio(20);   // monedas (scr_armas, EQUIPAMIENTO)
    global.losses += 1;
    scr_xp_dar(10);   // XP aunque pierdas (scr_reloj)
	global.copas = max(0, global.copas - 15);
    
    //scr_check_levelup();
    scr_save_to_local();
    scr_save_to_cloud();
}