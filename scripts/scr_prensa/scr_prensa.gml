// ======================================================
// PRENSAS QUE APLASTAN (oHammer)
// ======================================================
#macro PRENSA_AVISO 42   // frames de aviso antes de caer (0.7 s)

/// Empieza el aviso. Se llama en el host y cuando llega "hammer_go".
function hammer_empezar(_frames) {
    estado = "aviso";
    aviso_t = _frames;
    golpe_ya = false;
    mato_ya = false;
    image_index = 0;
    image_speed = 0;
}

/// Mi jugador (en línea o en local).
function hammer_mi_jugador() {
    if (instance_exists(oPlayer)) return instance_find(oPlayer, 0);
    if (instance_exists(oPlayer_offline)) return instance_find(oPlayer_offline, 0);
    return noone;
}

/// ¿Mi jugador está cerca de esta prensa?
function hammer_cerca(_dist) {
    var _p = hammer_mi_jugador();
    if (_p == noone) return false;
    return point_distance(x + 16, y + 60, _p.x, _p.y) < _dist;
}

/// Revisa quién quedó bajo la cabeza de la prensa. Cada pantalla revisa solo a su jugador
/// (y en local, también al bot), con lo que se ve en esa pantalla.
function hammer_aplastar(_f) {
    var _y1 = y + cabeza_arriba[_f];
    var _y2 = y + cabeza_abajo[_f];
    var _x1 = x + 2;
    var _x2 = x + 29;

    // Mi jugador
    var _p = hammer_mi_jugador();
    if (_p != noone && !_p.isDead) {
        if (collision_rectangle(_x1, _y1, _x2, _y2, _p, false, true) != noone) {
            mato_ya = true;
            with (_p) {
                death_reason = "crush";
                last_killer = "La prensa";
                health = 0;
            }
        }
    }

    // En local: el bot también se puede aplastar
    if (!global.ONLINE && instance_exists(oPlayer2_local)) {
        with (oPlayer2_local) {
            if (!isDead && collision_rectangle(_x1, _y1, _x2, _y2, id, false, true) != noone) {
                last_killer = "La prensa";
                hp = 0;
            }
        }
    }
}
