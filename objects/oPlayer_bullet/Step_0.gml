// ======================================================
// ⏳ VIDA ÚTIL
// ======================================================
if (life > 0) {
    life--;
    if (life <= 0) {
        instance_destroy();
    }
}

// Cohete del RPG: sale lento y acelera (scr_armas)
if (variable_instance_exists(id, "acel") && acel > 0) speed = min(speed * acel, vel_max);

if (is_rocket)
{
    if (irandom(2) == 0)
    {
        var sm = instance_create_layer(x, y, "Instances", oSmokeTrail);
        sm.color = c_gray;
    }
    image_angle = direction;
}



// 0. Balas rápidas: reviso el tramo de este frame (scr_mira)
//    así no atraviesan un muro, una plataforma o al bot sin pegar
if (!is_granada && speed > 0) {
    var _nx = x + hspeed;
    var _ny = y + vspeed;
    if (collision_line(x, y, _nx, _ny, obj_wall, false, true) != noone) {
        if (is_rocket) { instance_create_layer(x, y, "Instances", oExplosionFX); scrCamShake(11); }
        instance_destroy();
        exit;
    }
    if (collision_line(x, y, _nx, _ny, oPlataformaPasable, false, true) != noone) {
        instance_destroy();
        exit;
    }
    var _bl = collision_line(x, y, _nx, _ny, oPlayer2_local, false, true);
    if (_bl != noone && _bl.team != team && place_meeting(x, y, oPlayer2_local) == false) {
        // la pongo sobre el bot: el código de abajo hace el daño como siempre
        x = _bl.x;
        y = _bl.y - 16;
    }
}

// 1. Chocar con paredes
if (place_meeting(x, y, obj_wall)  and !is_rocket) 
{
    instance_destroy();
}
else if (place_meeting(x, y, obj_wall)  and is_rocket) 
{
    instance_create_layer(x, y, "Instances", oExplosionFX); // Tu objeto de explosión
	scrCamShake(11);
    instance_destroy();
}

// 2. Chocar con el Jugador (oPlayer2_local)
var bot = instance_place(x, y, oPlayer2_local);

if (bot != noone) 
{
    // Solo si son de equipos distintos
    if (bot.team != team) 
	{ 
        
        // Daño al bot: escudo, invulnerabilidad y quién mató en un solo lugar (scr_dano_local)
        var _dmg = is_rocket ? damage_rocket : damage;
        var _ok = scr_dano_bot(bot, _dmg, global.myName);
        if (_ok && global.sfx) audio_play_sound(snd_hit, 10, false);
        if (is_rocket) {
            instance_create_layer(x, y, "Instances", oExplosionFX);
            scrCamShake(11);
        }
        instance_destroy();
        exit;
    }
}