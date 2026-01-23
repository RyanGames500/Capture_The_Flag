//draw a bar to show the speed
var healthbarLength = speed*10
draw_healthbar(x - healthbarLength, y -30, x+ healthbarLength,y-35,100, c_black, c_red ,c_lime,false,true,false)
draw_healthbar(x - 30, y -40, x+ 30,y-45,health, c_black, c_blue ,c_blue,false,true,false)

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

if (oBrain.AmIPseudoHost) {
image_blend=c_blue
} else {
image_blend=c_red
}

if (guns[weapon.index] != noone)
{
    var weaponScale = (weapon.angle >= 90 && weapon.angle < 270) ? -1.5 : 1.5;
    var weaponAngle = weapon.angle + ((weapon.angle >= 90 && weapon.angle < 270) ? 180 : 0);

    // offset del arma
    var ox = lengthdir_x(-recoil_kick, weapon.angle);
    var oy = lengthdir_y(-recoil_kick, weapon.angle);

    draw_sprite_ext(
        guns[weapon.index].sprite, 0,
        x + ox, (y - 16) + oy,
        weaponScale, 1.5,
        weaponAngle + recoil_angle,
        c_white, 1
    );
}

//draw_text(x,y-10,has_flag)