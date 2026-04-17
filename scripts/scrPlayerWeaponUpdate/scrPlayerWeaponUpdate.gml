function scrPlayerWeaponUpdate()
{
    if (guns[weapon.index] == noone) exit;

    // Actualizar el ángulo siempre
    weapon.angle = point_direction(x, y, mouse_x, mouse_y);

    // Cooldowns
    if (weapon.frequency > 0) weapon.frequency--;
    if (empty_cd > 0) empty_cd--;

    var w = guns[weapon.index];
    var t2 = w.type2;

    // =========================================
    // DISPARO
    // =========================================
    if (mouse_check_button(mb_left) && weapon.frequency <= 0)
    {
        // ---------- SIN BALAS ----------
        if (w.ammo <= 0)
        {
            if (empty_cd <= 0)
            {
                if (global.sfx) audio_play_sound(snd_empy, 1, false);
                empty_cd = 10;
            }
            scrReloadWeapon();
            weapon.frequency = 3;
            exit;
        }

        // ---------- CÁLCULO DE POSICIÓN DE PUNTA DE CAÑÓN (Sincronizado con Draw) ----------
        var dir_char = sign(image_xscale);
        var handAngle = weapon.angle;

        // 1. Posición del hombro y mano (Igual que en el Draw)
        var hombroX = x + (2 * dir_char); 
        var hombroY = y - 18;
        
        // La mano ya tiene el largo del brazo (14)
        var handX = hombroX + lengthdir_x(14, handAngle);
        var handY = hombroY + lengthdir_y(14, handAngle);

        // 2. Desfases del arma (Desfase adelante 34 para llegar a la punta del cañón)
        var desfase_adelante = 34; 
        var desfase_arriba = -4; // El valor que ajustamos para que el arma subiera

        var weaponScaleY = (handAngle > 90 && handAngle < 270) ? -2 : 2;
        var ajuste_vertical = (weaponScaleY == -2) ? -desfase_arriba : desfase_arriba;

        // 3. Punto final de salida (bx, by)
        var bx = handX + lengthdir_x(desfase_adelante, handAngle) + lengthdir_x(ajuste_vertical, handAngle - 90);
        var by = handY + lengthdir_y(desfase_adelante, handAngle) + lengthdir_y(ajuste_vertical, handAngle - 90);

        var len = 40;
        var mid = t2;

        // ==========================
        // GUN (Pistola)
        // ==========================
        if (t2 == "gun")
        {
            scrCamShake(1.2);
            recoil_kick += 3;
            recoil_angle += random_range(-1, 1);

            var bullet = instance_create_layer(bx, by, "Instances", oMyEntity);
            bullet.owner_name = global.myName;
            bullet.sprite_index = sprBullet_gun;
            bullet.speed = 7;
            bullet.direction = point_direction(bx, by, mouse_x, mouse_y);
            bullet.life = 40;
            bullet.owner_team = global.myTeam;
            bullet.owner_id = id;
            bullet.damage = w.damage * damage_boost; 

            if (damage_boost > 1) {
                bullet.image_blend = c_red;
                bullet.image_xscale *= 1.2;
            }

            var flash = instance_create_layer(bx, by, "Instances", oMuzzleFlash);
            flash.sprite_index = sprMuzzle_gun;
            flash.image_angle = weapon.angle;

            var tr = instance_create_layer(bx, by, "Instances", oTracer);
            tr.x1 = bx; tr.y1 = by;
            tr.x2 = bx + lengthdir_x(len, handAngle);
            tr.y2 = by + lengthdir_y(len, handAngle);

            if (global.ONLINE && instance_exists(oOtherPlayer)) {
                with(oOtherPlayer) {
                    SendEventToClient(clientId, "fx_shot", { x: bx, y: by, ang: other.weapon.angle, muzzle: mid });
                }
            }

            if (!infinite_ammo) w.ammo -= 1;
            guns[weapon.index] = w;
            if (global.sfx) audio_play_sound(snd_gun, 1, false);
            weapon.frequency = w.frequency;
            if (w.ammo <= 0) scrReloadWeapon();
        }

        // ==========================
        // SMG / AK
        // ==========================
        else if (t2 == "smg")
        {
            scrCamShake(0.8);
            recoil_kick += 3;
            recoil_angle += random_range(-1, 1);

            var base_dir = point_direction(bx, by, mouse_x, mouse_y);
            ak_recoil = clamp(ak_recoil + 0.9, 0, 10);
            var shot_dir = base_dir + random_range(-2.0, 2.0) - (ak_recoil * random_range(0.5, 0.9));

            var bullet = instance_create_layer(bx, by, "Instances", oMyEntity);
            bullet.owner_name = global.myName;
            bullet.sprite_index = sprBullet_smg;
            bullet.speed = 11;
            bullet.direction = shot_dir;
            bullet.life = 35;
            bullet.damage = w.damage * damage_boost; 
            bullet.owner_team = global.myTeam;
            bullet.owner_id = id;

            var flash = instance_create_layer(bx, by, "Instances", oMuzzleFlash);
            flash.sprite_index = sprMuzzle_smg;
            flash.image_angle = weapon.angle;

            var tr = instance_create_layer(bx, by, "Instances", oTracer);
            tr.x1 = bx; tr.y1 = by;
            tr.x2 = bx + lengthdir_x(len, handAngle);
            tr.y2 = by + lengthdir_y(len, handAngle);

            if (global.ONLINE && instance_exists(oOtherPlayer)) {
                with(oOtherPlayer) {
                    SendEventToClient(clientId, "fx_shot", { x: bx, y: by, ang: other.weapon.angle, muzzle: mid });
                }
            }

            if (!infinite_ammo) w.ammo -= 1;
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
            recoil_kick += 3;
            recoil_angle += random_range(-1, 1);
            hsp -= lengthdir_x(6, weapon.angle);

            var pellets = 7;
            var spread = 18;
            var base_dir = point_direction(bx, by, mouse_x, mouse_y);

            var flash = instance_create_layer(bx, by, "Instances", oMuzzleFlash);
            flash.sprite_index = sprMuzzle_escop;
            flash.image_angle = weapon.angle;

            for (var i = 0; i < pellets; i++) {
                var tt = (pellets == 1) ? 0 : (i / (pellets - 1));
                var ang = base_dir + lerp(-spread * 0.5, spread * 0.5, tt) + random_range(-2, 2);
                var b = instance_create_layer(bx, by, "Instances", oMyEntity);
                b.owner_name = global.myName;
                b.sprite_index = sprBullet_escop;
                b.speed = 6 + random_range(-0.5, 0.5);
                b.direction = ang;
                b.life = 18 + irandom(6);
                b.damage = w.damage * damage_boost; 
                b.owner_team = global.myTeam;
                b.owner_id = id;
            }

            if (global.ONLINE && instance_exists(oOtherPlayer)) {
                with(oOtherPlayer) {
                    SendEventToClient(clientId, "fx_shot", { x: bx, y: by, ang: other.weapon.angle, muzzle: mid });
                }
            }

            if (!infinite_ammo) w.ammo -= 1;
            guns[weapon.index] = w;
            if (global.sfx) audio_play_sound(snd_escop, 1, false);
            weapon.frequency = w.frequency;
            if (w.ammo <= 0) scrReloadWeapon();
        }

        // ==========================
        // BAZOOKA
        // ==========================
        else if (t2 == "bazooka")
        {
            scrCamShake(10);
            hsp -= lengthdir_x(12, weapon.angle);
            recoil_kick += 8;
            recoil_angle += random_range(-4, 4);

            var missile = instance_create_layer(bx, by, "Instances", oMyEntity);
            missile.owner_name = global.myName;
            missile.sprite_index = sprBullet_bazooka;
            missile.speed = 8;
            missile.direction = weapon.angle;
            missile.image_angle = weapon.angle;
            missile.life = 500;
            missile.damage = w.damage * damage_boost; 
            missile.owner_team = global.myTeam;
            missile.owner_id = id;
            missile.is_rocket = true;

            var flash = instance_create_layer(bx, by, "Instances", oMuzzleFlash);
            flash.sprite_index = sprMuzzle_escop;
            flash.image_angle = weapon.angle;
            flash.image_xscale = 2;

            if (global.ONLINE && instance_exists(oOtherPlayer)) {
                with(oOtherPlayer) {
                    SendEventToClient(clientId, "fx_shot", { x: bx, y: by, ang: other.weapon.angle, muzzle: mid });
                }
            }

            if (!infinite_ammo) w.ammo -= 1;
            guns[weapon.index] = w;
            if (global.sfx) audio_play_sound(snd_bazooka, 1, false);
            weapon.frequency = w.frequency;
            if (w.ammo <= 0) scrReloadWeapon();
        }

        // ==========================
        // M4 RIFLE
        // ==========================
        else if (t2 == "m4")
        {
            scrCamShake(1.5);
            recoil_kick += 4.5;
            recoil_angle += random_range(-1.5, 1.5);

            var base_dir = point_direction(bx, by, mouse_x, mouse_y);
            ak_recoil = clamp(ak_recoil + 0.7, 0, 8); 
            var shot_dir = base_dir + random_range(-1.5, 1.5) - (ak_recoil * random_range(0.4, 0.7));

            var bullet = instance_create_layer(bx, by, "Instances", oMyEntity);
            bullet.owner_name = global.myName;
            bullet.sprite_index = sprBullet_smg;
            bullet.speed = 14;
            bullet.direction = shot_dir;
            bullet.image_angle = shot_dir;
            bullet.life = 45;
            bullet.damage = w.damage * damage_boost; 
            bullet.owner_team = global.myTeam;
            bullet.owner_id = id;

            var flash = instance_create_layer(bx, by, "Instances", oMuzzleFlash);
            flash.sprite_index = sprMuzzle_smg;
            flash.image_angle = weapon.angle;
            flash.image_xscale = 1.2;

            if (global.ONLINE && instance_exists(oOtherPlayer)) {
                with(oOtherPlayer) {
                    SendEventToClient(clientId, "fx_shot", { x: bx, y: by, ang: other.weapon.angle, muzzle: mid });
                }
            }

            if (!infinite_ammo) w.ammo -= 1;
            guns[weapon.index] = w;
            if (global.sfx) audio_play_sound(snd_M4, 1, false, 0.8);
            weapon.frequency = w.frequency;
            if (w.ammo <= 0) scrReloadWeapon();
        }

        // ==========================
        // GUANTE DE BOX
        // ==========================
        else if (t2 == "box")
        {
            if (!instance_exists(mi_guante)) 
            {
                scrCamShake(2);
                recoil_kick = 8;
                var punch = instance_create_layer(x, y - 13, "Instances", oMyEntity);
                punch.is_box = true;
                punch.owner = id;
                punch.direction = weapon.angle;
                punch.image_angle = weapon.angle;
                punch.damage = w.damage * damage_boost;
                punch.owner_team = global.myTeam;
                punch.distancia = 0;
                punch.distancia_max = 160; 
                punch.velocidad = 15;
                punch.estado = 1;
                mi_guante = punch; 

                if (global.ONLINE && instance_exists(oOtherPlayer)) {
                    with(oOtherPlayer) {
                        SendEventToClient(clientId, "fx_shot", { x: other.x, y: other.y - 13, ang: other.weapon.angle, muzzle: "box" });
                    }
                }
            }
            weapon.frequency = w.frequency;
        }
        else
        {
            weapon.frequency = 5;
        }
    }
}