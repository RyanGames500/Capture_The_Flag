function scr_reset_game_data() {
	
    // --- RESET DE VARIABLES GLOBALES ---
    global.game_over = false;
    global.revancha_pendiente = false;
	global.fase_seleccion = false;
    global.puntos_azul = 0;
    global.puntos_rojo = 0;
    global.pj_selected = 0;
    // --- RESET LOCAL (TU PANTALLA) ---
    global.mi_listo = false; 
	global.revancha_yo = false;     // ¿Yo pulsé el botón?
	global.revancha_rival = false;  // ¿El rival pulsó el botón?
    // Si tu char sale ya elegido, es porque esta variable o la del ID del PJ no se borró:
    // global.pj_selected = -1; // Descomenta esto si quieres que tengan que elegir PJ otra vez

    with(oBrain) {
        intro_disparada = false;
        timer_intro = 60*60;     // Reinicia el contador de la intro
        victory_alpha = 0;     // Borra el panel de victoria de tu pantalla
        victory_index = 0;
        mensaje_texto = "";    // Limpia avisos
        mensaje_alpha = 0;
    }

    // --- RESET DE RIVALES (PROXIES) ---
    with(oOtherPlayer) {
        isReady = false;
    }

	show_debug_message(">>> PARTIDA REINICIADA SINCRONIZADAMENTE");
}