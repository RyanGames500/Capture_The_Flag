/// scrCreateRocketExplosion(x, y)
function scrCreateRocketExplosion(_x, _y)
{
    instance_create_layer(_x, _y, "Weapons", oExplosionFX);

    repeat (10)
    {
        var sm = instance_create_layer(_x, _y, "Weapons", oSmokeTrail);
        sm.direction = random(360);
        sm.speed = random_range(1, 4);
        sm.fade_speed = 0.02;
    }

    if (global.sfx)
        audio_play_sound(snd_pearl_explodes, 10, false);

    scrCamShake(15);
}
