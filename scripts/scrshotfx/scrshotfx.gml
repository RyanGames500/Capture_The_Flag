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

/// PREDICCIÓN DE EMPUJE (boxeo): el rival sale volando AL INSTANTE en mi pantalla.
/// Usa los mismos números que aplica el que recibe el golpe (callback_ReceivedEvent, "hit"),
/// y cuando llega su posición real, la predicción se va quitando sola.
function scr_predict_push(_t, _ang) {
    if (!instance_exists(_t)) return;
    with (_t) {
        if (state == PLAYERSTATE.DEAD) return;
        pp_start_x = net_x;
        pp_start_y = net_y;
        pp_dx = 0;
        pp_dy = 0;
        pp_h  = lengthdir_x(22, _ang);
        pp_vy = -7;
        pp_seen_up = false;
        pp_timer = 60; // máximo 1 s; después se suelta suave
    }
}

// ======================================================
// HITMARKER + HIT-STOP (sensación de golpe)
// ======================================================
#macro HM_FRAMES       16   // cuánto dura la X en la mira
#macro HITSTOP_MELEE   4    // frames que se congela tu personaje al pegar cuerpo a cuerpo
#macro HITSTOP_KILL    6    // frames que se congela al matar (0 = apagado)

/// Llámalo justo después de scr_predict_hit, en la pantalla del que pega.
function scr_hit_confirm(_t, _head = false, _melee = false) {
    if (!instance_exists(_t)) return;
    if (_t.state == PLAYERSTATE.DEAD) return;

    var _kill = (_t.enemyHealth_net - _t.pred_dmg) <= 0;

    global.hm_timer = HM_FRAMES;
    global.hm_type  = _kill ? 2 : (_head ? 1 : 0);   // 0 normal, 1 cabeza, 2 baja

    if (!variable_global_exists("hitstop")) global.hitstop = 0;
    var _stop = _kill ? HITSTOP_KILL : (_melee ? HITSTOP_MELEE : 0);
    global.hitstop = max(global.hitstop, _stop);

    if (global.sfx) {
        var _pitch = _kill ? 0.75 : (_head ? 1.3 : 1);
        audio_play_sound(snd_hitmarker, 30, false, _kill ? 1.2 : 0.9, 0, _pitch);
    }
    if (_kill) scrCamShake(4);
    else if (_melee) scrCamShake(2);
}

/// Dibuja la X en la mira. Va en el Draw GUI del jugador.
function scr_hitmarker_draw() {
    if (!variable_global_exists("hm_timer")) return;
    if (global.hm_timer <= 0) return;
    global.hm_timer -= 1;

    var _t   = global.hm_timer / HM_FRAMES;            // 1 -> 0
    var _mx  = device_mouse_x_to_gui(0);
    var _my  = device_mouse_y_to_gui(0);
    var _col = c_white;
    if (global.hm_type == 1) _col = c_yellow;
    if (global.hm_type == 2) _col = c_red;
    var _big = (global.hm_type == 2) ? 1.4 : 1;
    var _gap = (6 + (1 - _t) * 4) * _big;               // se abre un poquito
    var _len = 7 * _big;

    draw_set_alpha(min(1, _t * 2));
    for (var i = 0; i < 4; i++) {
        var _a  = 45 + i * 90;
        var _x1 = _mx + lengthdir_x(_gap, _a);
        var _y1 = _my + lengthdir_y(_gap, _a);
        var _x2 = _mx + lengthdir_x(_gap + _len, _a);
        var _y2 = _my + lengthdir_y(_gap + _len, _a);
        draw_set_colour(c_black);
        draw_line_width(_x1 + 1, _y1 + 1, _x2 + 1, _y2 + 1, 3);
        draw_set_colour(_col);
        draw_line_width(_x1, _y1, _x2, _y2, 2);
    }
    draw_set_alpha(1);
    draw_set_colour(c_white);
}
