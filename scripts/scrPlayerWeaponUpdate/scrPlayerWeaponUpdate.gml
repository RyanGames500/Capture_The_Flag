function scrPlayerWeaponUpdate()
{
    if (guns[weapon.index] == noone) exit;

    // siempre actualizar el ángulo
    weapon.angle = point_direction(x, y, mouse_x, mouse_y);

    // cooldown de disparo
    if (weapon.frequency > 0) weapon.frequency--;

    // cooldown del sonido empty (SIEMPRE)
    if (empty_cd > 0) empty_cd--;

    var w = guns[weapon.index];
    var t2 = w.type2;

    // =========================================
    // DISPARO (misma entrada para todas)
    // =========================================
    if (mouse_check_button_pressed(mb_left) && weapon.frequency <= 0)
    {
        // ---------- SIN BALAS ----------
        if (w.ammo <= 0)
        {
            if (empty_cd <= 0)
            {
                if (global.sfx) audio_play_sound(snd_empy, 1, false);
                empty_cd = 10; // anti-spam
            }

            // intentar auto-recargar (si hay reserva)
            scrReloadWeapon();

            // mini cooldown para no spamear clicks (y no saturar red/fx)
            weapon.frequency = 3;

            exit;
        }

        // ---------- CON BALAS ----------
        var bx = x + lengthdir_x(13, weapon.angle);
        var by = y - 16 + lengthdir_y(15, weapon.angle);

        // tracer config base
        var len = 40;
        var dir = weapon.angle;

        // id del muzzle para remoto
        var mid = t2;

        // ==========================
        // GUN (pistola)
        // ==========================
        if (t2 == "gun")
        {
            scrCamShake(1.2);

            // recoil visual
            var kick = 3;
            var angKick = 1;

            recoil_kick += kick;
            recoil_angle += random_range(-angKick, angKick);

            var bullet = instance_create_layer(bx, by, "Instances", oMyEntity);
            bullet.sprite_index = sprBullet_gun;
            bullet.speed = 7;
            bullet.direction = point_direction(bx, by, mouse_x, mouse_y);
            bullet.life = 25;
            bullet.damage = w.damage;
            bullet.owner_team = global.myTeam;
            bullet.owner_id = id;

            var flash = instance_create_layer(bx, by, "Instances", oMuzzleFlash);
            flash.sprite_index = sprMuzzle_gun;
            flash.image_angle = weapon.angle;
            flash.image_xscale = 1;
            flash.image_yscale = 1;

            var tr = instance_create_layer(bx, by, "Instances", oTracer);
            tr.x1 = bx; tr.y1 = by;
            tr.x2 = bx + lengthdir_x(len, dir);
            tr.y2 = by + lengthdir_y(len, dir);

            // remoto fx
            if (global.ONLINE && instance_exists(oOtherPlayer))
            {
                SendEventToClient(oOtherPlayer.clientId, "fx_shot", {
                    x: bx, y: by, ang: weapon.angle, muzzle: mid
                });
            }

            // gastar bala
            w.ammo -= 1;
            guns[weapon.index] = w;

            // sonido
            if (global.sfx) audio_play_sound(snd_gun, 1, false);

            // cadencia
            weapon.frequency = w.frequency;

            // auto-reload si quedó vacío
            if (w.ammo <= 0) scrReloadWeapon();
        }

        // ==========================
        // SMG / AK style
        // ==========================
        else if (t2 == "smg")
        {
            scrCamShake(0.8);

            // recoil visual
            var kick = 3;
            var angKick = 1;

            recoil_kick += kick;
            recoil_angle += random_range(-angKick, angKick);

            // recoil/spread tipo AK
            var base_dir = point_direction(bx, by, mouse_x, mouse_y);
            ak_recoil = clamp(ak_recoil + 0.9, 0, 10);

            var rand_spread = random_range(-2.0, 2.0);
            var recoil_up   = ak_recoil * random_range(0.5, 0.9);
            var shot_dir    = base_dir + rand_spread - recoil_up;

            var bullet = instance_create_layer(bx, by, "Instances", oMyEntity);
            bullet.sprite_index = sprBullet_smg;
            bullet.speed = 11;
            bullet.direction = shot_dir;
            bullet.life = 35;
            bullet.damage = w.damage;
            bullet.owner_team = global.myTeam;
            bullet.owner_id = id;

            var flash = instance_create_layer(bx, by, "Instances", oMuzzleFlash);
            flash.sprite_index = sprMuzzle_smg;
            flash.image_angle = weapon.angle;
            flash.image_xscale = 1;
            flash.image_yscale = 1;

            var tr = instance_create_layer(bx, by, "Instances", oTracer);
            tr.x1 = bx; tr.y1 = by;
            tr.x2 = bx + lengthdir_x(len, dir);
            tr.y2 = by + lengthdir_y(len, dir);

            if (global.ONLINE && instance_exists(oOtherPlayer))
            {
                SendEventToClient(oOtherPlayer.clientId, "fx_shot", {
                    x: bx, y: by, ang: weapon.angle, muzzle: mid
                });
            }

            // gastar bala
            w.ammo -= 1;
            guns[weapon.index] = w;

            if (global.sfx) audio_play_sound(snd_smg, 1, false);

            weapon.frequency = w.frequency;

            if (w.ammo <= 0) scrReloadWeapon();
        }

        // ==========================
        // ESCOPETA
        // ==========================
        else if (t2 == "escop")
        {
            scrCamShake(2.5);

            // recoil
            var kick = 3;
            var angKick = 1;
            var push = 0.4;

            recoil_kick += kick;
            recoil_angle += random_range(-angKick, angKick);

            // empuje al cuerpo
            hsp -= lengthdir_x(push, weapon.angle);

            // pellets config
            var pellets = 7;
            var spread  = 18;
            var spd     = 6;
            var rand_sp = 2;

            var base_dir = point_direction(bx, by, mouse_x, mouse_y);

            // flash 1 vez (mejor que por pellet)
            var flash = instance_create_layer(bx, by, "Instances", oMuzzleFlash);
            flash.sprite_index = sprMuzzle_escop;
            flash.image_angle = weapon.angle;
            flash.image_xscale = 1;
            flash.image_yscale = 1;

            // tracer 1 vez (mejor que por pellet)
            var tr = instance_create_layer(bx, by, "Instances", oTracer);
            tr.x1 = bx; tr.y1 = by;
            tr.x2 = bx + lengthdir_x(len, dir);
            tr.y2 = by + lengthdir_y(len, dir);

            // pellets
            for (var i = 0; i < pellets; i++)
            {
                var tt = (pellets == 1) ? 0 : (i / (pellets - 1));
                var ang = base_dir + lerp(-spread * 0.5, spread * 0.5, tt);
                ang += random_range(-rand_sp, rand_sp);

                var b = instance_create_layer(bx, by, "Instances", oMyEntity);
                b.sprite_index = sprBullet_escop;
                b.speed = spd + random_range(-0.5, 0.5);
                b.direction = ang;
                b.life = 18 + irandom(6);
                b.damage = w.damage;
                b.owner_team = global.myTeam;
                b.owner_id = id;
            }

            if (global.ONLINE && instance_exists(oOtherPlayer))
            {
                SendEventToClient(oOtherPlayer.clientId, "fx_shot", {
                    x: bx, y: by, ang: weapon.angle, muzzle: mid
                });
            }

            // gastar 1 ammo por disparo
            w.ammo -= 1;
            guns[weapon.index] = w;

            if (global.sfx) audio_play_sound(snd_escop, 1, false);

            weapon.frequency = w.frequency;

            if (w.ammo <= 0) scrReloadWeapon();
        }

        // si llega un type2 raro, por seguridad:
        else
        {
            // fallback simple: no disparar, solo cooldown
            weapon.frequency = 5;
        }
    }
}
