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
if (place_meeting(x, y, obj_wall) || place_meeting(x, y, oPlataformaPasable))
{
    // ============================
    // 💥 MISIL
    // ============================
    if (is_rocket && !exploded)
    {
        exploded = true;

        // FX LOCAL (feedback inmediato)
		//scrCreateRocketExplosion(x,y);
        instance_create_layer(x, y, "Weapons", oExplosionFX);
        if (global.sfx) audio_play_sound(snd_pearl_explodes, 10, false);
        scrCamShake(15);

        // ============================
        // 🌐 AVISAR AL HOST
        // ============================
        if (global.ONLINE)
        {
            if (!oBrain.AmIPseudoHost)
            {
                // el cliente le dice al host: "exploté aquí"
                SendEventToClient(
                    oOtherPlayer.clientId,
                    "request_rocket_explosion",
                    { ex: x, ey: y }
                );
            }
            else
            {
                // si YO soy el host, sincronizo de una vez
                if (instance_exists(oOtherPlayer))
                {
                    SendEventToClient(
                        oOtherPlayer.clientId,
                        "fx_pearl_explosion",
                        { ex: x, ey: y }
                    );
                }
            }
        }
    }

    instance_destroy();
}


// ======================================================
// 🎯 COLISIÓN CON JUGADOR (BALAS Y ROCKETS)
// ======================================================
var target_enemy = instance_place(x, y, oOtherPlayer);

if (target_enemy != noone)
{
    // 🔥 FILTRO BRAWL STARS: Solo procesamos si NO es de nuestro equipo
    if (variable_instance_exists(target_enemy, "team") && target_enemy.team != global.myTeam) 
    {
        if (target_enemy.invulnerable) exit;

        // ==========================================
        // 🔥 PREDICCIÓN VISUAL (SOLO LOCAL)
        // ==========================================
        with (target_enemy)
        {
            if (state != PLAYERSTATE.DEAD)
            {
                hit_bloqueo_timer = 10;
                state = PLAYERSTATE.HIT;
                image_index = 0;
            }
        }

        // ==========================================
        // 💥 EXPLOSIÓN (SOLO SI ES ROCKET)
        // ==========================================
        if (is_rocket)
        {
            scrCreateRocketExplosion(x, y);

            if (global.ONLINE)
            {
                var explosionData = { ex: x, ey: y };
                if (oBrain.AmIPseudoHost)
                {
                    if (instance_exists(oOtherPlayer))
                    {
                        SendEventToClient(oOtherPlayer.clientId, "fx_pearl_explosion", explosionData);
                    }
                }
                else
                {
                    SendEventToClient(oOtherPlayer.clientId, "request_fx_explosion", explosionData);
                }
            }
        }

        // ==========================================
        // 🔊 SONIDO DE HIT
        // ==========================================
        if (global.sfx)
            audio_play_sound(snd_hit, 20, false, 1.1);

        // ==========================================
        // 🧠 DAÑO AUTORITATIVO
        // ==========================================
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
                SendEventToClient(oOtherPlayer.clientId, "request_hit", {
                    victimId: target_enemy.clientId,
                    damage: damage,
                    killer: global.myName,
                    reason: "pvp"
                });
            }
        }

        instance_destroy();
        exit; // Importante para no seguir procesando
    }
}

// ======================================================
// 🚀 COMPORTAMIENTO DEL ROCKET (TRAIL + ROTACIÓN)
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
// 💣 LÓGICA DE GRANADAS (GRAVEDAD Y MOVIMIENTO)
// ======================================================
if (variable_instance_exists(id, "is_granada") && is_granada) {
    
    vsp += 0.22; // Gravedad
    image_angle -= hsp * 5; 
    
    // 1. CHEQUEAR COLISIÓN CON EL ENEMIGO (Ignorando aliados)
    var target_enemy_nad = instance_place(x + hsp, y + vsp, oOtherPlayer);
    
    // Si detectamos a alguien, verificamos que sea enemigo
    if (target_enemy_nad != noone) {
        if (variable_instance_exists(target_enemy_nad, "team") && target_enemy_nad.team == global.myTeam) {
            target_enemy_nad = noone; // Es aliado, hacemos como que no lo vimos
        }
    }
    
    // 2. CHEQUEAR COLISIÓN CON EL SUELO/PARED
    var hit_wall = place_meeting(x + hsp, y + vsp, obj_wall);

    // 3. CHEQUEAR PLATAFORMAS
    var hit_platform = false;
    var platform_id = instance_place(x, y + vsp, oPlataformaPasable); 
    if (platform_id != noone && vsp > 0) {
        hit_platform = true;
    }

    // EXPLOSIÓN DE GRANADA
    if (target_enemy_nad != noone || hit_wall || hit_platform) {
        
        is_rocket = true; 
        scrCreateRocketExplosion(x, y, true); 
  
        if (global.sfx) audio_play_sound(snd_hit, 20, false, 1.1);

        // DAÑO DIRECTO SI PEGÓ A UN ENEMIGO
        if (target_enemy_nad != noone && !target_enemy_nad.invulnerable) {
            with (target_enemy_nad) {
                if (state != PLAYERSTATE.DEAD) {
                    hit_bloqueo_timer = 10;
                    state = PLAYERSTATE.HIT;
                    image_index = 0;
                }
            }

            if (global.ONLINE) {
                if (oBrain.AmIPseudoHost) {
                    SendEventToClient(target_enemy_nad.clientId, "hit", {
                        damage: damage, killer: global.myName, reason: "granada"
                    });
                } else {
                    SendEventToClient(oOtherPlayer.clientId, "request_hit", {
                        victimId: target_enemy_nad.clientId, damage: damage, killer: global.myName, reason: "granada"
                    });
                }
            }
        }

        // SINCRONIZACIÓN VISUAL BUM
        if (global.ONLINE) {
            var explosionData = { ex: x, ey: y, isNade: true };
            if (oBrain.AmIPseudoHost) {
                if (instance_exists(oOtherPlayer)) 
                    SendEventToClient(oOtherPlayer.clientId, "fx_pearl_explosion", explosionData);
            } else {
                SendEventToClient(oOtherPlayer.clientId, "request_fx_explosion", explosionData);
            }
        }

        instance_destroy(); 
        exit; 
    }
    
    x += hsp;
    y += vsp;
}