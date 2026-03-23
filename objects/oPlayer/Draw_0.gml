

var _x1 = x - 30;
var _y1 = y - 45;
var _x2 = x + 30;
var _y2 = y - 40;

// 1. Sombra/Borde exterior
draw_set_color(c_black);
draw_rectangle(_x1 - 1, _y1 - 1, _x2 + 1, _y2 + 1, false);

// 2. Fondo de la barra
draw_set_color(c_dkgray);
draw_rectangle(_x1, _y1, _x2, _y2, false);

// --- 3. LA VIDA DINÁMICA ---
// Usamos max_health para que el porcentaje sea real según la clase
var _ancho_barra = (_x2 - _x1); // Esto es 60
var _porcentaje = clamp(health / max_health, 0, 1); 
var _width_final = _porcentaje * _ancho_barra;

if (health > 0) {
    // Color Azul/Cian para el jugador local (Aliado de sí mismo)
    draw_set_color(c_blue);
    draw_rectangle(_x1, _y1, _x1 + _width_final, _y2, false);
    
    // Un toque de brillo arriba para darle relieve
    draw_set_color(c_aqua);
    draw_line(_x1, _y1, _x1 + _width_final, _y1);
}

draw_set_halign(fa_center);
draw_set_font(fnt_small); // O tu fuente de nombres
draw_set_color(c_white);
draw_text(x, y - 60, string(playerName)); // Suponiendo que tienes la variable userName

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

//if (oBrain.AmIPseudoHost) {
//image_blend=c_blue
//} else {
//image_blend=c_red
//}

if (melee_active > 0)
{
    var dir  = sign(image_xscale);   // -1 o 1
    var sx   = 2 * dir;              // escala X (voltea)
    var offx = 12 * dir;             // 🔥 más cerca (antes 10*dir pero tu dir era *2)

    var p = 1 - (melee_active / 6);
    var a = lerp(-40, 40, p);

    draw_sprite_ext(spr_Hand, 0,
        x + offx, y - 10,
        sx, 2,
        a * dir,
        c_white, 1);
}
// Solo dibujamos si tengo arma, no tengo bandera Y el guante no está volando
var guante_volando = (instance_exists(mi_guante));

if (guns[weapon.index] != noone && !has_flag && !guante_volando)
{
    var weaponScale = (weapon.angle >= 90 && weapon.angle < 270) ? -2 : 2;
    var weaponAngle = weapon.angle + ((weapon.angle >= 90 && weapon.angle < 270) ? 180 : 0);

    var ox = lengthdir_x(-recoil_kick, weapon.angle);
    var oy = lengthdir_y(-recoil_kick, weapon.angle);

    draw_sprite_ext(
        guns[weapon.index].sprite, 0,
        x + ox, (y - 13) + oy,
        weaponScale, 2,
        weaponAngle + recoil_angle,
        c_white, 1
    );
}

if (reloading)
{
    var spr = spr_reload_circle; // tu sprite
    var frames = sprite_get_number(spr);

    // progreso real de recarga
    var progress = 1 - (reload_timer / reload_max);
    var frame = floor(progress * (frames - 1));
    frame = clamp(frame, 0, frames - 1);

    // posición sobre la cabeza
    var yy = bbox_top - 25; // ajusta si quieres más arriba

    draw_sprite_ext(
        spr,
        frame,
        x,
        yy,
        0.5, 0.5,
        0,
        c_white,
        1
    );
}


if (has_shield) {
    gpu_set_blendmode(bm_add);
    
    // 1. ESCALA: Aumentamos el tamaño (antes era ~1.1, probemos 1.4)
    var _sc = 1.4 + sin(current_time/150) * 0.08; 
    var _alp = 0.4 + random(0.1);
    
    // 2. POSICIÓN: Bajamos el origen. 
    // Si antes era "y - 12", prueba con "y - 5" o simplemente "y" para centrarlo en los pies.
    var _y_ajustada = y - 5; 
    
    // El radio ahora es 28 para que sea más grande
    draw_set_alpha(_alp);
    draw_circle_colour(x, _y_ajustada, 28 * _sc, c_aqua, c_blue, false);
    
    gpu_set_blendmode(bm_normal);
    draw_set_alpha(1);
}