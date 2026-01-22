function scrPlayerWeaponUpdate(){
	if (guns[weapon.index] == noone) { exit; }
	
if (guns[weapon.index].type2 == "gun")
{
    weapon.angle = point_direction(x, y, mouse_x, mouse_y);

    if (weapon.frequency > 0) weapon.frequency--;

    // permitir disparar si tiene ammo O si balas infinitas está activa
    if (mouse_check_button(mb_left)
        && (guns[weapon.index].ammo > 0)
        && weapon.frequency <= 0)
    {
        var bx = x + lengthdir_x(13, weapon.angle);
        var by = y - 16 + lengthdir_y(15, weapon.angle);

        var bullet = instance_create_layer(bx, by, "Instances", oMyEntity);
        bullet.speed = 7;
        bullet.direction = point_direction(bx, by, mouse_x, mouse_y);
        guns[weapon.index].ammo -= 1;
        
		//Sonido
		if(global.sfx==true){audio_play_sound(snd_gun,1,0);}
        //scrTerremoto(5);
        weapon.frequency = guns[weapon.index].frequency;

    }
}

}