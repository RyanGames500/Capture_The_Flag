function scrCreateRocketExplosion(_x, _y, _is_nade = false) 
{
    // ============================
    // 🎨 PARTE VISUAL (TU CÓDIGO)
    // ============================
    var _obj = instance_create_layer(_x, _y, "Weapons", oExplosionFX);
    
    if (_is_nade) {
        _obj.sprite_index = spr_explode2; 
        scrCamShake(8); 
    } else {
        scrCamShake(15); 
    }

    repeat (10)
    {
        var sm = instance_create_layer(_x, _y, "Weapons", oSmokeTrail);
        sm.direction = random(360);
        sm.speed = random_range(1, 4);
        sm.fade_speed = 0.02;
    }

    if (global.sfx)
        audio_play_sound(snd_pearl_explodes, 10, false);
    fx_light(_x, _y, _is_nade ? 150 : 190, make_color_rgb(255, 138, 42), 26);
    fx_sparks(_x, _y, 0, 7, true);
    fx_sparks(_x, _y, 90, 7, true);
    fx_sparks(_x, _y, 180, 7, true);
    fx_sparks(_x, _y, 270, 5, true);
    // ==========================================
    // 🧠 DAÑO EN ÁREA (SOPORTE 4 PLAYERS)
    // ==========================================
    if (global.ONLINE && oBrain.AmIPseudoHost) 
    {
        var _radius = 70; // El tamaño de la explosión
        var _baseDamage = (_is_nade) ? 35 : 55; // Daño según el tipo

        // 1. Verificamos a todos los "Otros Jugadores" (Clientes)
        with (oOtherPlayer) 
        {
            // Si el enemigo está dentro del círculo de la explosión
            if (point_distance(x, y, _x, _y) < _radius) 
            {
                // El Host les manda el golpe directamente
                SendEventToClient(clientId, "hit", {
                    damage: _baseDamage,
                    killer: "Explosion",
                    reason: (_is_nade) ? "granada" : "rocket"
                });
            }
        }
        
        // 2. Opcional: El Host se hace daño a sí mismo si está cerca
        if (point_distance(oPlayer.x, oPlayer.y, _x, _y) < _radius) {
            // Aquí podrías restar vida al oPlayer del Host si quieres fuego amigo
        }
    }
}