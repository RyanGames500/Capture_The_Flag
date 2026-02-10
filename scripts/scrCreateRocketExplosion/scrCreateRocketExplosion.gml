function scrCreateRocketExplosion(_x, _y, _is_nade = false) // Por defecto es false
{
    var _obj = instance_create_layer(_x, _y, "Weapons", oExplosionFX);
    
    // --- CAMBIAR SPRITE SI ES GRANADA ---
    if (_is_nade) {
        _obj.sprite_index = spr_explode2; // Pon el nombre de tu sprite aquí
        scrCamShake(8); // Sacudida un poco más suave que el rocket
    } else {
        scrCamShake(15); // Sacudida fuerte de Rocket
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
}