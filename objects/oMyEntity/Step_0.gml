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
// 🎯 COLISIÓN CON JUGADOR
// ======================================================
var target_enemy = instance_place(x, y, oOtherPlayer);

if (target_enemy != noone)
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
        // ---- efectos locales SIEMPRE ----
        scrCreateRocketExplosion(x, y);

        // ---- sincronización ONLINE ----
        if (global.ONLINE)
        {
            var explosionData = { ex: x, ey: y };

            if (oBrain.AmIPseudoHost)
            {
                if (instance_exists(oOtherPlayer))
                {
                    SendEventToClient(
                        oOtherPlayer.clientId,
                        "fx_pearl_explosion",
                        explosionData
                    );
                }
            }
            else
            {
                // cliente pide al host
                SendEventToClient(
                    oOtherPlayer.clientId,
                    "request_fx_explosion",
                    explosionData
                );
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
}

// ======================================================
// 🚀 COMPORTAMIENTO DEL ROCKET (TRAIL + ROTACIÓN)
// ======================================================
// ======================================================
// 🚀 COMPORTAMIENTO DEL ROCKET (TRAIL + ROTACIÓN)
// ======================================================
if (is_rocket)
{
    // SOLO LOCAL
    if (irandom(2) == 0)
    {
        var sm = instance_create_layer(x, y, "Instances", oSmokeTrail);
        sm.color = c_gray;
    }

    image_angle = direction;
}
