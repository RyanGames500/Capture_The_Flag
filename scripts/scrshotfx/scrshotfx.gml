/// PREDICCIÓN DE GOLPE (como Free Fire): muestra el golpe y baja la vida del rival
/// AL INSTANTE en mi pantalla. Cuando llega la vida real, se ajusta sola.
function scr_predict_hit(_t, _dmg, _stun = 10) {
    if (!instance_exists(_t)) return;
    with (_t) {
        if (state == PLAYERSTATE.DEAD) return;
        hit_bloqueo_timer = max(hit_bloqueo_timer, _stun);
        state = PLAYERSTATE.HIT;
        image_index = 0;
        if (pred_timer <= 0) { pred_base = enemyHealth_net; pred_dmg = 0; }
        pred_dmg += _dmg;
        pred_timer = 45; // máximo 0.75 s esperando la confirmación
    }
}