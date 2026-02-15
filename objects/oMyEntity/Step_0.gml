/// @description Step oMyEntity (balas / rockets / network-safe)

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
	_IA		  : image_angle
};

// ======================================================
// ⏳ VIDA ÚTIL
// ======================================================
if (life > 0) {
    life--;
    if (life <= 0) {
        instance_destroy();
    }
}
// ======================================================
// 🧱 COLISIÓN CON PAREDES / PLATAFORMAS (BALAS Y MISILES)
// ======================================================
if (place_meeting(x, y, obj_wall) || place_meeting(x, y, oPlataformaPasable))
{
    if (is_rocket && !exploded)
    {
        exploded = true;

        // FX LOCAL inmediato
        instance_create_layer(x, y, "Weapons", oExplosionFX);
        if (global.sfx) audio_play_sound(snd_pearl_explodes, 10, false);
        scrCamShake(15);

        if (global.ONLINE)
        {
            if (oBrain.AmIPseudoHost)
            {
                // EL HOST LE AVISA A TODOS LOS DEMÁS
                with(oOtherPlayer) {
                    SendEventToClient(clientId, "fx_pearl_explosion", { ex: other.x, ey: other.y, isNade: false });
                }
            }
            else
            {
                // EL CLIENTE LE PIDE AL HOST QUE REPLIQUE LA EXPLOSIÓN
                var _targetHost = -1;
                with(oOtherPlayer) { if (variable_instance_exists(id, "isHost") && isHost) _targetHost = clientId; }
                if (_targetHost == -1 && instance_exists(oOtherPlayer)) { _targetHost = instance_find(oOtherPlayer, 0).clientId; }

                if (_targetHost != -1) {
                    SendEventToClient(_targetHost, "request_rocket_explosion", { ex: x, ey: y });
                }
            }
        }
    }
    instance_destroy();
}

// ======================================================
// 🎯 COLISIÓN CON JUGADOR (TODOS LOS PROYECTILES)
// ======================================================
var target_enemy = instance_place(x, y, oOtherPlayer);

if (target_enemy != noone)
{
    // Solo procesamos si NO es de nuestro equipo (Filtro Brawl Stars)
    if (variable_instance_exists(target_enemy, "team") && target_enemy.team != global.myTeam) 
    {
        if (target_enemy.invulnerable) exit;

        // PREDICCIÓN VISUAL LOCAL
        with (target_enemy)
        {
            if (state != PLAYERSTATE.DEAD)
            {
                hit_bloqueo_timer = 10;
                state = PLAYERSTATE.HIT;
                image_index = 0;
            }
        }

        // SI ES ROCKET, EXPLOTA
        if (is_rocket)
        {
            scrCreateRocketExplosion(x, y, false);

            if (global.ONLINE)
            {
                if (oBrain.AmIPseudoHost)
                {
                    with(oOtherPlayer) { 
                        SendEventToClient(clientId, "fx_pearl_explosion", { ex: other.x, ey: other.y, isNade: false }); 
                    }
                }
                else
                {
                    var _targetHost = -1;
                    with(oOtherPlayer) { if (variable_instance_exists(id, "isHost") && isHost) _targetHost = clientId; }
                    if (_targetHost == -1 && instance_exists(oOtherPlayer)) { _targetHost = instance_find(oOtherPlayer, 0).clientId; }
                    if (_targetHost != -1) SendEventToClient(_targetHost, "request_fx_explosion", { ex: x, ey: y, isNade: false });
                }
            }
        }

        if (global.sfx) audio_play_sound(snd_hit, 20, false, 1.1);

        // DAÑO AUTORITATIVO
        if (global.ONLINE)
        {
            if (oBrain.AmIPseudoHost)
            {
                SendEventToClient(target_enemy.clientId, "hit", {
                    damage: damage,
                    killer: global.myName,
                    reason: "pvp"
                });
            }
            else
            {
                var _targetHost = -1;
                with(oOtherPlayer) { if (variable_instance_exists(id, "isHost") && isHost) _targetHost = clientId; }
                if (_targetHost == -1 && instance_exists(oOtherPlayer)) { _targetHost = instance_find(oOtherPlayer, 0).clientId; }
                
                if (_targetHost != -1) {
                    SendEventToClient(_targetHost, "request_hit", {
                        victimId: target_enemy.clientId,
                        damage: damage,
                        killer: global.myName,
                        reason: "pvp"
                    });
                }
            }
        }

        instance_destroy();
    }
}

// ======================================================
// 🚀 COMPORTAMIENTO VISUAL (SMOKE TRAIL)
// ======================================================
if (is_rocket)
{
    if (irandom(2) == 0)
    {
        var sm = instance_create_layer(x, y, "Instances", oSmokeTrail);
        sm.color = c_gray;
    }
    image_angle = direction;
}

// ======================================================
// 💣 LÓGICA DE GRANADAS (MOVIMIENTO Y GRAVEDAD)
// ======================================================
if (variable_instance_exists(id, "is_granada") && is_granada) {
    
    // Evitar error de variable no definida para balas normales
    if (!variable_instance_exists(id, "vsp")) vsp = 0;
    if (!variable_instance_exists(id, "hsp")) hsp = 0;

    vsp += 0.22; // Gravedad
    image_angle -= hsp * 5; 
    
    // 1. Detección de enemigo para granada
    var target_enemy_nad = instance_place(x + hsp, y + vsp, oOtherPlayer);
    if (target_enemy_nad != noone) {
        if (variable_instance_exists(target_enemy_nad, "team") && target_enemy_nad.team == global.myTeam) {
            target_enemy_nad = noone; 
        }
    }
    
    // 2. Colisión física
    var hit_wall = place_meeting(x + hsp, y + vsp, obj_wall);
    var hit_platform = false;
    var platform_id = instance_place(x, y + vsp, oPlataformaPasable); 
    if (platform_id != noone && vsp > 0) hit_platform = true;

    // EXPLOSIÓN DE GRANADA
    if (target_enemy_nad != noone || hit_wall || hit_platform) {
        
        scrCreateRocketExplosion(x, y, true); 
        if (global.sfx) audio_play_sound(snd_hit, 20, false, 1.1);

        // DAÑO SI ES ENEMIGO
        if (target_enemy_nad != noone && !target_enemy_nad.invulnerable) {
            if (global.ONLINE) {
                if (oBrain.AmIPseudoHost) {
                    SendEventToClient(target_enemy_nad.clientId, "hit", {
                        damage: damage, killer: global.myName, reason: "granada"
                    });
                } else {
                    var _targetHost = -1;
                    with(oOtherPlayer) { if (variable_instance_exists(id, "isHost") && isHost) _targetHost = clientId; }
                    if (_targetHost == -1 && instance_exists(oOtherPlayer)) { _targetHost = instance_find(oOtherPlayer, 0).clientId; }
                    if (_targetHost != -1) {
                        SendEventToClient(_targetHost, "request_hit", {
                            victimId: target_enemy_nad.clientId, damage: damage, killer: global.myName, reason: "granada"
                        });
                    }
                }
            }
        }

        // SINCRONIZACIÓN VISUAL BUM
        if (global.ONLINE) {
            if (oBrain.AmIPseudoHost) {
                with(oOtherPlayer) { 
                    SendEventToClient(clientId, "fx_pearl_explosion", { ex: other.x, ey: other.y, isNade: true }); 
                }
            } else {
                var _targetHost = -1;
                with(oOtherPlayer) { if (variable_instance_exists(id, "isHost") && isHost) _targetHost = clientId; }
                if (_targetHost == -1 && instance_exists(oOtherPlayer)) { _targetHost = instance_find(oOtherPlayer, 0).clientId; }
                if (_targetHost != -1) SendEventToClient(_targetHost, "request_fx_explosion", { ex: x, ey: y, isNade: true });
            }
        }

        instance_destroy(); 
    }
    
    x += hsp;
    y += vsp;
}