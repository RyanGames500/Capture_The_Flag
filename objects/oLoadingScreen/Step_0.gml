// Manejo de estados de la pantalla
if (state == "fade_in") {
    alpha += 0.05;
    if (alpha >= 1) state = "waiting";
}

if (state == "waiting") {
    // Si pasa mucho tiempo y no conecta
    timer_timeout--;
    if (timer_timeout <= 0 && !conector_listo) {
        mensaje = "ERROR: SERVIDOR NO RESPONDE";
        if (mouse_check_button_pressed(mb_left)) game_restart(); // Click para reintentar
    }
    
    // Si el callback ya nos dio el OK
    if (conector_listo) {
        state = "fade_out";
    }
}

if (state == "fade_out") {
    alpha -= 0.05;
    if (alpha <= 0) instance_destroy();
}