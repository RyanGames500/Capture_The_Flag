draw_healthbar(x - 30, y -40, x+ 30,y-45,enemyHealth, c_black, c_red ,c_red,false,true,false)

if (invulnerable) {
    // 1. Efecto de Brillo/Color (Mezcla de color aditiva)
    // El 'current_time' hará que el color "vibre" entre blanco y su color original
    var _oscilacion = (sin(current_time / 100) + 1) / 2; // Oscila entre 0 y 1
    var _color = merge_color(c_white, c_aqua, _oscilacion); // Puedes cambiar c_aqua por c_yellow
    
    // Dibujamos al personaje con un resplandor de color
    draw_sprite_ext(sprite_index, image_index, x, y, image_xscale, image_yscale, image_angle, _color, 0.8);
    
    // 2. EFECTO PRO: Dibujamos una "silueta" extra un poco más grande y transparente
    gpu_set_blendmode(bm_add); // Modo de luz
    draw_sprite_ext(sprite_index, image_index, x, y, image_xscale * 1.1, image_yscale * 1.1, image_angle, _color, 0.3);
    gpu_set_blendmode(bm_normal); // Volvemos al modo normal
} else {
    draw_self();
}

if (WSI != 0 && !has_flag)
{
    var weaponScale = (weapon.angle >= 90 && weapon.angle < 270) ? -1.5 : 1.5;
    var weaponAngle = weapon.angle + ((weapon.angle >= 90 && weapon.angle < 270) ? 180 : 0);

    var ox = lengthdir_x(-recoil_kick, weapon.angle);
    var oy = lengthdir_y(-recoil_kick, weapon.angle);

    draw_sprite_ext(
        WSI, 0,
        x - 3 + ox, y - 7 + oy,
        weaponScale, 1.5,
        weaponAngle + recoil_angle,
        c_white, 1
    );
}


//melee atack IM NOT FLAG
if (melee_active > 0)
{
    var dir  = sign(image_xscale);
    var sx   = 2 * dir;
    var offx = 12 * dir;   // 🔥 más cerca (antes 20)

    var p = 1 - (melee_active / 6);
    var a = lerp(-40, 40, p);

    draw_sprite_ext(
        spr_Hand, 0,
        x + offx, y - 12,
        sx, 2,
        a * dir,
        c_white, 1
    );
}



