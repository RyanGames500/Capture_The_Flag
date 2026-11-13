// --- EFECTOS DEL GOLPE (scr_fx) ---
if (!variable_instance_exists(id, "hp_max")) hp_max = max(1, hp);
if (!variable_instance_exists(id, "golpe_t")) golpe_t = 0;
if (golpe_t > 0) golpe_t--;
if (variable_instance_exists(id, "chispas")) {
    for (var _i = array_length(chispas) - 1; _i >= 0; _i--) {
        var _c = chispas[_i];
        _c.x += _c.vx; _c.y += _c.vy; _c.vy += 0.3; _c.t++;
        if (_c.t > 18) array_delete(chispas, _i, 1);
    }
}

// --- DETECCIÓN DE BALAS ---
var _bullet = instance_place(x, y, oMyEntity); 
if (_bullet != noone) {
    var _d = _bullet.damage;
    var _hx = _bullet.x, _hy = _bullet.y;
    hp -= _d;
    scr_barril_golpe(_d, _hx, _hy);
    instance_destroy(_bullet);
    // Que los demas vean el mismo golpe (y le bajen la misma vida)
    if (global.ONLINE && hp > 0) {
        var _bm = { bx: x, by: y, d: _d, hx: _hx, hy: _hy };
        with (oOtherPlayer) { if (!es_bot) SendEventToClient(clientId, "barrel_hit", _bm); }
    }
}

// --- EXPLOSIÓN ---
if (hp <= 0 && !exploded) {
    exploded = true;
    var _grande = (object_index != oBarrilSmall);
    var _cx = (bbox_left + bbox_right) / 2;     // centro del barril
    var _cy = (bbox_top + bbox_bottom) / 2;

    // 1. Explosion grande con tus sprites (scr_fx)
    scr_barril_boom(_cx, bbox_bottom, _grande);

    // 2. AVISAR A TODOS LOS DEMÁS
    if (global.ONLINE) {
        var barrelData = { bx: x, by: y };
        with(oOtherPlayer) {
            if (!es_bot) SendEventToClient(clientId, "barrel_dead", barrelData);
        }
    }

    // 3. DAÑO EN ÁREA: a cualquiera cerca, de tu equipo o del otro (y los empuja hacia afuera)
    var radius = variable_instance_exists(id, "radius_value") ? radius_value : 130;
    var dmg_to_apply = variable_instance_exists(id, "mi_danio") ? mi_danio : 60;

    // A MÍ (el jugador local)
    if (instance_exists(oPlayer)) {
        with (oPlayer) {
            if (!isDead && !invulnerable && point_distance(_cx, _cy, x, y) < radius) {
                health -= scr_hab_dano_recibido(dmg_to_apply);
                fx_damage_number(x, bbox_top - 8, dmg_to_apply, 3);
                death_reason = "explosion";
                last_killer = "Barril";
                if (!scr_hab_coraza_activa()) { push_h = lengthdir_x(16, point_direction(_cx, _cy, x, y)); vsp = -6; }
                state = PLAYERSTATE.HIT;
                hit_bloqueo_timer = 15;
            }
        }
    }

    // A LOS DEMÁS (personas y bots)
    if (global.ONLINE) {
        with(oOtherPlayer) {
            if (point_distance(_cx, _cy, x, y) < radius) {
                SendEventToClient(clientId, "hit", {
                    damage: dmg_to_apply,
                    killer: "Barril",
                    reason: "explosion",
                    angle: point_direction(_cx, _cy, x, y)
                });
            }
        }
    }

    // JEFE GIGANTE: el barril tambien le pega al jefe (x4) (scr_reloj)
    if (global.ONLINE) scr_jefe_explosion(_cx, _cy, radius, dmg_to_apply * JEFE_BARRIL);

    instance_destroy();
}
