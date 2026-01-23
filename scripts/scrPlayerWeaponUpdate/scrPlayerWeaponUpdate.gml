function scrPlayerWeaponUpdate(){
	if (guns[weapon.index] == noone) { exit; }
	
if (guns[weapon.index].type2 == "gun")
{
	    // ❌ SIN BALAS
    if (guns[weapon.index].ammo <= 0)
    {
        if (empty_cd <= 0)
        {
            if (global.sfx==true){audio_play_sound(snd_empy, 1, false);}
            empty_cd = 10; // evita spam (10 frames)
        }
        //exit;
    }
	
    weapon.angle = point_direction(x, y, mouse_x, mouse_y);

    if (weapon.frequency > 0) weapon.frequency--;

    // permitir disparar si tiene ammo O si balas infinitas está activa
    if (mouse_check_button(mb_left)
        && (guns[weapon.index].ammo > 0)
        && weapon.frequency <= 0)
    {
		scrCamShake(1.2);
        var bx = x + lengthdir_x(13, weapon.angle);
        var by = y - 16 + lengthdir_y(15, weapon.angle);
		
				// ---- recoil por disparo (ajustable por arma)
		var kick = 3;     // retroceso visual
		var angKick = 1;  // retroceso angular
		var push = 0.4;   // empuje al cuerpo (opcional)
		
		recoil_kick += kick;
		recoil_angle += random_range(-angKick, angKick);

        var bullet = instance_create_layer(bx, by, "Instances", oMyEntity);
		bullet.sprite_index=sprBullet_gun;
        bullet.speed = 7;
        bullet.direction = point_direction(bx, by, mouse_x, mouse_y);
		bullet.life = 25;
		bullet.damage = guns[weapon.index].damage;
		bullet.owner_team = global.myTeam; // o tu variable team
		bullet.owner_id = id;
		var flash = instance_create_layer(bx, by, "Instances", oMuzzleFlash);		
		flash.sprite_index=sprMuzzle_gun;
		flash.image_angle = weapon.angle;
		flash.image_xscale = 1;
		flash.image_yscale = 1;
		var len = 40;
		var dir = weapon.angle; // o el dir real que usaste para la bala

		var t = instance_create_layer(bx, by, "Instances", oTracer);
		t.x1 = bx;
		t.y1 = by;
		t.x2 = bx + lengthdir_x(len, dir);
		t.y2 = by + lengthdir_y(len, dir);
		
		//crear efectos en pantalla del otro jugador remoto
		var mid = guns[weapon.index].type2; // o guns[weapon.index].type2

		if (global.ONLINE && instance_exists(oOtherPlayer))
		{
		    SendEventToClient(oOtherPlayer.clientId, "fx_shot", {
		        x: bx,
		        y: by,
		        ang: weapon.angle,
		        muzzle: mid
		    });
		}





        guns[weapon.index].ammo -= 1;
        
		if (guns[weapon.index].ammo <= 0)
		{
			scrReloadWeapon();
		    exit;
		}

		//Sonido
		if(global.sfx==true){audio_play_sound(snd_gun,1,0);}
        //scrTerremoto(5);
        weapon.frequency = guns[weapon.index].frequency;
		if (empty_cd > 0) empty_cd--;

    }
}
else if (guns[weapon.index].type2 == "smg")
{
		    // ❌ SIN BALAS
    if (guns[weapon.index].ammo <= 0)
    {
        if (empty_cd <= 0)
        {
            if (global.sfx==true){audio_play_sound(snd_empy, 1, false);}
            empty_cd = 10; // evita spam (10 frames)
        }
        //exit;
    }
	
    weapon.angle = point_direction(x, y, mouse_x, mouse_y);

    if (weapon.frequency > 0) weapon.frequency--;

    if (mouse_check_button(mb_left)
        && (guns[weapon.index].ammo > 0)
        && weapon.frequency <= 0)
    {
		scrCamShake(0.8);
        var bx = x + lengthdir_x(13, weapon.angle);
        var by = y - 16 + lengthdir_y(15, weapon.angle);
		
				// ---- recoil por disparo (ajustable por arma)
		var kick = 3;     // retroceso visual
		var angKick = 1;  // retroceso angular
		var push = 0.4;   // empuje al cuerpo (opcional)
		
		recoil_kick += kick;
		recoil_angle += random_range(-angKick, angKick);
        // ===== CONFIG AK47 =====
        var base_dir = point_direction(bx, by, mouse_x, mouse_y);

        // recoil acumulado (sube con cada bala)
        ak_recoil = clamp(ak_recoil + 0.9, 0, 10); // 0..10 aprox

        // spread horizontal random + recoil vertical hacia arriba
        var rand_spread = random_range(-2.0, 2.0);      // spray lateral
        var recoil_up   = ak_recoil * random_range(0.5, 0.9); // hacia arriba
        var shot_dir    = base_dir + rand_spread - recoil_up;

        var bullet = instance_create_layer(bx, by, "Instances", oMyEntity);
		bullet.sprite_index=sprBullet_smg;
        bullet.speed = 11;
        bullet.direction = shot_dir;
		bullet.life = 35;
		bullet.damage = guns[weapon.index].damage;
		bullet.owner_team = global.myTeam; // o tu variable team
		bullet.owner_id = id;
		var flash = instance_create_layer(bx, by, "Instances", oMuzzleFlash);
		flash.sprite_index=sprMuzzle_smg;
		flash.image_angle = weapon.angle;
		flash.image_xscale = 1;
		flash.image_yscale = 1;
		var len = 40;
		var dir = weapon.angle; // o el dir real que usaste para la bala

		var t = instance_create_layer(bx, by, "Instances", oTracer);
		t.x1 = bx;
		t.y1 = by;
		t.x2 = bx + lengthdir_x(len, dir);
		t.y2 = by + lengthdir_y(len, dir);
		//crear efectos en pantalla del otro jugador remoto
		var mid = guns[weapon.index].type2; // o guns[weapon.index].type2

		if (global.ONLINE && instance_exists(oOtherPlayer))
		{
		    SendEventToClient(oOtherPlayer.clientId, "fx_shot", {
		        x: bx,
		        y: by,
		        ang: weapon.angle,
		        muzzle: mid
		    });
		}

        guns[weapon.index].ammo -= 1;

		if (guns[weapon.index].ammo <= 0)
		{
		    scrReloadWeapon();
		    exit;
		}


        if (global.sfx==true) audio_play_sound(snd_smg, 1, 0);

        // Cadencia: usa la del struct (ponle una frequency tipo AK)
        weapon.frequency = guns[weapon.index].frequency;
		if (empty_cd > 0) empty_cd--;
    }
}

else if (guns[weapon.index].type2 == "escop")
{
		    // ❌ SIN BALAS
    if (guns[weapon.index].ammo <= 0)
    {
        if (empty_cd <= 0)
        {
            if (global.sfx==true){audio_play_sound(snd_empy, 1, false);}
            empty_cd = 10; // evita spam (10 frames)
        }
        //exit;
    }
	
    weapon.angle = point_direction(x, y, mouse_x, mouse_y);

    if (weapon.frequency > 0) weapon.frequency--;

    if (mouse_check_button(mb_left)
        && (guns[weapon.index].ammo > 0)
        && weapon.frequency <= 0)
    {
		
		scrCamShake(2.5);
        var bx = x + lengthdir_x(13, weapon.angle);
        var by = y - 16 + lengthdir_y(15, weapon.angle);

        // ===== CONFIG ESCOPETA =====
        var pellets = 7;          // cantidad de perdigones
        var spread  = 18;         // apertura total en grados (más = más abierto)
        var spd     = 6;          // velocidad base
        var rand_sp = 2;          // random extra de ángulo (ruido)

        // centro del abanico (hacia el mouse)
        var base_dir = point_direction(bx, by, mouse_x, mouse_y);
		
		// ---- recoil por disparo (ajustable por arma)
		var kick = 3;     // retroceso visual
		var angKick = 1;  // retroceso angular
		var push = 0.4;   // empuje al cuerpo (opcional)

		recoil_kick += kick;
		recoil_angle += random_range(-angKick, angKick);

		// empuje al cuerpo (hacia atrás)
		hsp -= lengthdir_x(push, weapon.angle);
		//vsp -= lengthdir_y(push, weapon.angle);
        // tiro en abanico
        for (var i = 0; i < pellets; i++)
        {
            // repartir ángulos de -spread/2 a +spread/2
            var t = (pellets == 1) ? 0 : (i / (pellets - 1)); // 0..1
            var ang = base_dir + lerp(-spread*0.5, spread*0.5, t);

            // random para que se sienta más natural
            ang += random_range(-rand_sp, rand_sp);
			
            var b = instance_create_layer(bx, by, "Instances", oMyEntity);
			b.sprite_index=sprBullet_escop;
            b.speed = spd + random_range(-0.5, 0.5);
            b.direction = ang;
			b.life = 18 + irandom(6);
			b.damage = guns[weapon.index].damage;
			b.owner_team = global.myTeam;
			b.owner_id = id;
			var flash = instance_create_layer(bx, by, "Instances", oMuzzleFlash);
			flash.sprite_index=sprMuzzle_escop;
			flash.image_angle = weapon.angle;
			flash.image_xscale = 1;
			flash.image_yscale = 1;
			var len = 40;
			var dir = weapon.angle; // o el dir real que usaste para la bala

			var tt = instance_create_layer(bx, by, "Instances", oTracer);
			tt.x1 = bx;
			tt.y1 = by;
			tt.x2 = bx + lengthdir_x(len, dir);
			tt.y2 = by + lengthdir_y(len, dir);
		//crear efectos en pantalla del otro jugador remoto
		var mid = guns[weapon.index].type2; // o guns[weapon.index].type2

		if (global.ONLINE && instance_exists(oOtherPlayer))
		{
		    SendEventToClient(oOtherPlayer.clientId, "fx_shot", {
		        x: bx,
		        y: by,
		        ang: weapon.angle,
		        muzzle: mid
		    });
		}


            // opcional: si tu bala soporta daño/rango
            // b.damage = 6;
            // b.life = 25; // frames, para que no viaje infinito (si tu bala lo usa)
        }

        // la escopeta gasta 1 de ammo por disparo (no por perdigón)
        guns[weapon.index].ammo -= 1;

		if (guns[weapon.index].ammo <= 0)
		{
		    scrReloadWeapon();
		    exit;
		}


        if (global.sfx==true) audio_play_sound(snd_escop, 1, 0);

        weapon.frequency = guns[weapon.index].frequency;
		if (empty_cd > 0) empty_cd--;
    }
}


}