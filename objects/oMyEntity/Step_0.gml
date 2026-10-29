/// @description Step oMyEntity (balas / rockets / granadas / boxeo / network-safe)

// ======================================================
// 🔄 SYNC DE RED
// ======================================================
entityProperties = {
	_entityId : entityId,
	_type     : tipo,
	_x        : x,
	_y        : y,
	_A        : direction,
    _IMXS     : image_xscale,
	_IMYS     : image_yscale,
	_SI       : sprite_index,
	_IR       : is_rocket,
	_IA		  : image_angle,
	_IB       : is_box,
	_XB       : (is_box) ? owner.x : x,       // <--- X del dueño
    _YB       : (is_box) ? owner.y - 13 : y   // <--- Y del dueño
};

// ======================================================
// 🥊 LÓGICA DE MOVIMIENTO (SOLO SI ES BOXEO)
// ======================================================
if (variable_instance_exists(id, "is_box") && is_box) 
{
    if (!instance_exists(owner)) { instance_destroy(); exit; }

    // Seguir al dueño (offset y-13)
    var x_base = owner.x;
    var y_base = owner.y - 13;
    image_angle = direction; 

    // Lógica de estiramiento
    distancia += velocidad * estado;

    if (distancia >= distancia_max) estado = -1; // Regresar al llegar al tope
    if (distancia <= 0 && estado == -1) { instance_destroy(); exit; }

    // Posición física del puño
    x = x_base + lengthdir_x(distancia, image_angle);
    y = y_base + lengthdir_y(distancia, image_angle);
}

// ======================================================
// ⏳ VIDA ÚTIL (Balas y Rockets normales)
// ======================================================
if (!variable_instance_exists(id, "is_box") || !is_box) {
    if (life > 0) {
        life--;
        if (life <= 0) instance_destroy();
    }
}

// ======================================================
// 🧱 COLISIÓN CON PAREDES / PLATAFORMAS
// ======================================================
if (place_meeting(x, y, obj_wall) || place_meeting(x, y, oPlataformaPasable))
{
       if (!(variable_instance_exists(id, "is_box") && is_box) && !is_rocket) fx_sparks(x, y, direction + 180, 6, false); 
    // Si es puño, rebota
    if (variable_instance_exists(id, "is_box") && is_box) {
        if (estado == 1) { 
            estado = -1; 
            if (global.sfx) audio_play_sound(snd_empy, 10, false, 0.5);
        }
    } 
    else {
        // Lógica original de Rocket
        if (is_rocket && !exploded) {
            exploded = true;
            instance_create_layer(x, y, "Weapons", oExplosionFX);
            if (global.sfx) audio_play_sound(snd_pearl_explodes, 10, false);
            scrCamShake(15);

            if (global.ONLINE) {
                if (oBrain.AmIPseudoHost) {
                    with(oOtherPlayer) { SendEventToClient(clientId, "fx_pearl_explosion", { ex: other.x, ey: other.y, isNade: false }); }
                } else {
                    var _targetHost = -1;
                    with(oOtherPlayer) { if (variable_instance_exists(id, "isHost") && isHost) _targetHost = clientId; }
                    if (_targetHost == -1 && instance_exists(oOtherPlayer)) { _targetHost = instance_find(oOtherPlayer, 0).clientId; }
                    if (_targetHost != -1) SendEventToClient(_targetHost, "request_rocket_explosion", { ex: x, ey: y });
                }
            }
        }
        instance_destroy();
    }
}

// ======================================================
// 🎯 COLISIÓN CON JUGADOR (TODOS LOS PROYECTILES)
// ======================================================
var target_enemy = instance_place(x, y, oOtherPlayer);

if (target_enemy != noone)
{
    if (variable_instance_exists(target_enemy, "team") && target_enemy.team != global.myTeam) 
    {
        // Evitar múltiples hits si es puño
        if (variable_instance_exists(id, "is_box") && is_box) {
            if (ds_list_find_index(hit_list, target_enemy) != -1) exit;
        }

        // --- SISTEMA DE ESCUDO ---
		if (target_enemy.has_shield) 
		{
		    instance_create_layer(x, y, "Instances", oShieldSparkFX);
		    if (global.sfx) audio_play_sound(snd_shield_impact, 20, false, 2.0);
		    if (global.ONLINE) {
		        with(oOtherPlayer) { SendEventToClient(clientId, "fx_shield_hit", { ex: other.x, ey: other.y }); }
		    }
            
            if (variable_instance_exists(id, "is_box") && is_box) {
                estado = -1; exit;
            } else {
		        instance_destroy(); exit;
            }
		}
		
        if (target_enemy.invulnerable) exit;

        // --- EFECTO VISUAL Y EMPUJE ---
        with (target_enemy) {
            if (state != PLAYERSTATE.DEAD) {
                hit_bloqueo_timer = (variable_instance_exists(other, "is_box") && other.is_box) ? 20 : 10;
                state = PLAYERSTATE.HIT;
                image_index = 0;
                
                if (variable_instance_exists(other, "is_box") && other.is_box) {
                    push_h = lengthdir_x(25, other.image_angle);
                    vsp = -7;
                }
            }
        }

        // --- LÓGICA DE EXPLOSIÓN ROCKET ---
        if (is_rocket) {
            scrCreateRocketExplosion(x, y, false);
            if (global.ONLINE) {
                if (oBrain.AmIPseudoHost) {
                    with(oOtherPlayer) { SendEventToClient(clientId, "fx_pearl_explosion", { ex: other.x, ey: other.y, isNade: false }); }
                } else {
                    var _targetHost = -1;
                    with(oOtherPlayer) { if (variable_instance_exists(id, "isHost") && isHost) _targetHost = clientId; }
                    if (_targetHost == -1 && instance_exists(oOtherPlayer)) { _targetHost = instance_find(oOtherPlayer, 0).clientId; }
                    if (_targetHost != -1) SendEventToClient(_targetHost, "request_fx_explosion", { ex: x, ey: y, isNade: false });
                }
            }
        }

        if (global.sfx) audio_play_sound(snd_hit, 20, false, 1.1);

        // --- DAÑO AUTORITATIVO ---
        if (global.ONLINE) {
            var _reason = (variable_instance_exists(id, "is_box") && is_box) ? "boxeo" : "pvp";
			
			var _dir_golpe = point_direction(x, y, target_enemy.x, target_enemy.y);
            
             scr_predict_hit(target_enemy, damage, (_reason == "boxeo") ? 20 : 10);
            var _alto = target_enemy.bbox_bottom - target_enemy.bbox_top;
            var _head = (!is_rocket && _reason == "pvp" && y < target_enemy.bbox_top + _alto * 0.28);
            if (_head) damage = round(damage * FX_HEADSHOT_MULT);
            fx_damage_number(target_enemy.x, target_enemy.bbox_top - 8, damage, is_rocket ? 2 : (_head ? 1 : 0));
            fx_sparks(x, y, direction + 180, is_rocket ? 4 : 8, is_rocket);
            SendEventToClient(target_enemy.clientId, "hit", { damage: damage, killer: global.myName, reason: _reason, angle: _dir_golpe });
        }

        if (variable_instance_exists(id, "is_box") && is_box) {
            ds_list_add(hit_list, target_enemy);
            estado = -1; 
        } else {
            instance_destroy();
        }
    }
}

// ======================================================
// 🚀 COMPORTAMIENTO VISUAL (SMOKE TRAIL)
// ======================================================
if (is_rocket) {
    if (irandom(2) == 0) {
        var sm = instance_create_layer(x, y, "Instances", oSmokeTrail);
        sm.color = c_gray;
    }
    image_angle = direction;
}

// ======================================================
// 💣 LÓGICA DE GRANADAS (MOVIMIENTO Y GRAVEDAD)
// ======================================================
if (variable_instance_exists(id, "is_granada") && is_granada) {
    if (!variable_instance_exists(id, "vsp")) vsp = 0;
    if (!variable_instance_exists(id, "hsp")) hsp = 0;

    vsp += 0.22;
    image_angle -= hsp * 5; 
    
    var target_enemy_nad = instance_place(x + hsp, y + vsp, oOtherPlayer);
    if (target_enemy_nad != noone) {
        if (variable_instance_exists(target_enemy_nad, "team") && target_enemy_nad.team == global.myTeam) target_enemy_nad = noone; 
    }
    
    var hit_wall = place_meeting(x + hsp, y + vsp, obj_wall);
    var hit_platform = false;
    var platform_id = instance_place(x, y + vsp, oPlataformaPasable); 
    if (platform_id != noone && vsp > 0) hit_platform = true;

    if (target_enemy_nad != noone || hit_wall || hit_platform) {
        scrCreateRocketExplosion(x, y, true); 
        if (global.sfx) audio_play_sound(snd_hit, 20, false, 1.1);

        if (target_enemy_nad != noone && !target_enemy_nad.invulnerable) {
            if (global.ONLINE) {
                if (oBrain.AmIPseudoHost) {
                    SendEventToClient(target_enemy_nad.clientId, "hit", { damage: damage, killer: global.myName, reason: "granada" });
                } else {
                    var _targetHost = -1;
                    with(oOtherPlayer) { if (variable_instance_exists(id, "isHost") && isHost) _targetHost = clientId; }
                    if (_targetHost == -1 && instance_exists(oOtherPlayer)) { _targetHost = instance_find(oOtherPlayer, 0).clientId; }
                    if (_targetHost != -1) SendEventToClient(_targetHost, "request_hit", { victimId: target_enemy_nad.clientId, damage: damage, killer: global.myName, reason: "granada" });
                }
            }
        }

        if (global.ONLINE) {
                 scr_predict_hit(target_enemy_nad, damage, 10);
                SendEventToClient(target_enemy_nad.clientId, "hit", { damage: damage, killer: global.myName, reason: "granada" });
        }
        instance_destroy(); 
    }
    x += hsp;
    y += vsp;
}