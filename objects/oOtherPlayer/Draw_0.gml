// --- VIDA DINÁMICA (Brawl Stars Style) ---
// Si el equipo de este oOtherPlayer es el mismo que el mío, es azul (aliado), si no, rojo (enemigo)
// --- BARRA DE VIDA ÉPICA (OTROS) ---
var barColor = (team == global.myTeam) ? c_blue : c_red;
var barColorLight = (team == global.myTeam) ? c_aqua : c_orange; // Para el relieve

var _x1 = x - 30;
var _y1 = y - 45;
var _x2 = x + 30;
var _y2 = y - 40;

// 1. Sombra/Borde
draw_set_color(c_black);
draw_rectangle(_x1 - 1, _y1 - 1, _x2 + 1, _y2 + 1, false);

// 2. Fondo
draw_set_color(c_dkgray);
draw_rectangle(_x1, _y1, _x2, _y2, false);

// 3. Vida (usando enemyHealth)
var _width = (enemyHealth / 100) * (_x2 - _x1);
if (enemyHealth > 0) {
    draw_set_color(barColor);
    draw_rectangle(_x1, _y1, _x1 + _width, _y2, false);
    
    // Brillo superior
    draw_set_color(barColorLight);
    draw_line(_x1, _y1, _x1 + _width, _y1);
}

draw_set_halign(fa_center);
draw_set_font(fnt_small); // O tu fuente de nombres
draw_set_color(c_white);
draw_text(x, y - 60, string(Name)); // Suponiendo que tienes la variable userName

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
        x + offx, y - 10,
        sx, 2,
        a * dir,
        c_white, 1
    );
}
if (WSI != 0 && !has_flag)
{
    var weaponScale = (weapon.angle >= 90 && weapon.angle < 270) ? -2 : 2;
    var weaponAngle = weapon.angle + ((weapon.angle >= 90 && weapon.angle < 270) ? 180 : 0);

    var ox = lengthdir_x(-recoil_kick, weapon.angle);
    var oy = lengthdir_y(-recoil_kick, weapon.angle);

    draw_sprite_ext(
        WSI, 0,
        x - 3 + ox, y - 3 + oy,
        weaponScale, 2,
        weaponAngle + recoil_angle,
        c_white, 1
    );
}


