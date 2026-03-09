function scr_reset_partida_online() {
with(oPlayer) instance_destroy();
with(oOtherPlayer) instance_destroy();
    // 1. Estados de Juego
    global.game_over = false;
    global.puntos_rojo = 0;
    global.puntos_azul = 0;
    global.winner_team = 0;

    global.revancha_yo = false;
    global.revancha_otro = false;

    // 2. RESET DE SELECCIÓN
    global.mi_listo = false;
    global.pj_selected = 0;

    // 🔥 MUY IMPORTANTE
    global.rival_listo = false;
    global.pj_rival = -1;

    // 3. Reset de oBrain
    if (instance_exists(oBrain)) {
        oBrain.intro_disparada = false;
        oBrain.timer_intro = 60 * 60;
        oBrain.victory_alpha = 0;
        oBrain.puntos_procesados = false;
    }

    // 4. Limpieza de pickups
    instance_destroy(oGun);
    instance_destroy(oAmmoPack);
    instance_destroy(oPowerupPickup);

    // 5. RESET VISUAL DE JUGADORES
    with(oOtherPlayer) {
        isReady = false;
        mySelectedPJ = -1; // mejor usar -1 para indicar vacío
    }

    window_set_cursor(cr_arrow);
}