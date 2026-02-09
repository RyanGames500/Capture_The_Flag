switch (estado) {
    case INTRO_STATE.ENTRADA:
        anim = lerp(anim, 1, 0.08);
        alpha = lerp(alpha, 1, 0.05);
        if (anim > 0.98) {
            anim = 1;
            estado = INTRO_STATE.ESPERA;
        }
    break;

    case INTRO_STATE.ESPERA:
        timer--;
        if (timer <= 0) estado = INTRO_STATE.SALIDA;
    break;

    case INTRO_STATE.SALIDA:
        // En lugar de volver a 0, hacemos que anim siga subiendo para que salgan por el otro lado
        // O hacemos que alpha baje y los nombres se disparen
        anim = lerp(anim, 2.5, 0.1); // El 2.5 los manda lejos de la pantalla
        alpha = lerp(alpha, 0, 0.1);
        
        if (alpha <= 0.01) {
		// ¡DEVOLVER EL CONTROL!
        if (instance_exists(oPlayer)) {
            oPlayer.state = PLAYERSTATE.IDLE;
        }
            instance_destroy();
        }
    break;
}