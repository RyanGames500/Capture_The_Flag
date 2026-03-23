draw_text(x,y-20,grapple_active)

// --- BARRA DE VIDA ÉPICA (LOCAL) ---
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

// 3. La vida (Cambia de color según tu equipo)
var _width = (health / 100) * (_x2 - _x1);
if (health > 0) {
    var _barColor = (global.myTeam == "AZUL") ? c_blue : c_red;
    draw_set_color(_barColor);
    draw_rectangle(_x1, _y1, _x1 + _width, _y2, false);
    
    // Un toque de brillo arriba
    draw_set_color(c_white);
    draw_set_alpha(0.3);
    draw_line(_x1, _y1, _x1 + _width, _y1);
    draw_set_alpha(1);
}

// --- NOMBRE SOBRE LA CABEZA ---
draw_set_halign(fa_center);
draw_set_font(fnt_small); 
draw_set_color(c_white);
draw_text(x, y - 60, string(playerName));

// --- EFECTOS DE INVULNERABILIDAD ---
if (invulnerable) {
    var _oscilacion = (sin(current_time / 100) + 1) / 2;
    var _color = merge_color(c_white, (global.myTeam == "AZUL" ? c_aqua : c_orange), _oscilacion);
    
    draw_sprite_ext(sprite_index, image_index, x, y, image_xscale, image_yscale, image_angle, _color, 0.8);
    
    gpu_set_blendmode(bm_add);
    draw_sprite_ext(sprite_index, image_index, x, y, image_xscale * 1.1, image_yscale * 1.1, image_angle, _color, 0.3);
    gpu_set_blendmode(bm_normal);
} else {
    // Color de mezcla según el equipo (Azul o Rojo)
    image_blend = (global.myTeam == "AZUL") ? c_white : make_color_rgb(255, 150, 150);
    draw_self();
}

// --- DIBUJAR CADENA Y PUNTA DEL ARPÓN ---
if (state == PLAYERSTATE2.GRAPPLE) {
    
    // 1. Calculamos la posición visual de la punta
    var _tip_x, _tip_y, _color;
    
    if (!grapple_hitting) {
        // Mientras vuela, la punta sigue la animación lineal
        _tip_x = x + lengthdir_x(grapple_anim_dist, grapple_dir);
        _tip_y = (y - 20) + lengthdir_y(grapple_anim_dist, grapple_dir);
        _color = c_gray; // Color por defecto mientras vuela
    } else {
        // Si ya pegó, la punta se queda fija en el objetivo
        _tip_x = grapple_x;
        _tip_y = grapple_y;
        
        // Color según el objetivo
        _color = (grapple_type == "PARED") ? c_aqua : c_orange;
    }
    
    // 2. DIBUJAR EL CABLE (Línea gris o de color)
    draw_set_color(_color);
    draw_line_width(x, y - 20, _tip_x, _tip_y, 3);
    
    // 3. DIBUJAR LA PUNTA TRIANGULAR (Agresiva)
    var _tri_size = 10; // Tamaño del triángulo
    var _tri_angle = grapple_dir; // Dirección del triángulo
    
    // Calculamos los 3 vértices del triángulo apuntando en la dirección correcta
    var _p1_x = _tip_x + lengthdir_x(_tri_size * 1.5, _tri_angle);
    var _p1_y = _tip_y + lengthdir_y(_tri_size * 1.5, _tri_angle);
    
    var _p2_x = _tip_x + lengthdir_x(_tri_size, _tri_angle + 135);
    var _p2_y = _tip_y + lengthdir_y(_tri_size, _tri_angle + 135);
    
    var _p3_x = _tip_x + lengthdir_x(_tri_size, _tri_angle - 135);
    var _p3_y = _tip_y + lengthdir_y(_tri_size, _tri_angle - 135);
    
    // Dibujamos el triángulo relleno
    draw_triangle(_p1_x, _p1_y, _p2_x, _p2_y, _p3_x, _p3_y, false);
    
    // Resetear color
    draw_set_color(c_white);
}
// ======================================================

// --- ATAQUE MELEE (Mano) ---
if (melee_active > 0) {
    var dir  = sign(image_xscale);
    var sx   = 2 * dir;
    var offx = 12 * dir;

    var p = 1 - (melee_active / 6);
    var a = lerp(-40, 40, p);

    draw_sprite_ext(spr_Hand, 0, x + offx, y - 10, sx, 2, a * dir, c_white, 1);
}

// --- DIBUJAR ARMA ---
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

// --- INDICADOR DE RECARGA ---
if (reloading) {
    var spr = spr_reload_circle;
    var frames = sprite_get_number(spr);
    var progress = 1 - (reload_timer / reload_max);
    var frame = clamp(floor(progress * (frames - 1)), 0, frames - 1);

    draw_sprite_ext(spr, frame, x, bbox_top - 25, 0.5, 0.5, 0, c_white, 1);
}

// --- ESCUDO (POWER-UP) ---
if (has_shield) {
    gpu_set_blendmode(bm_add);
    var _sc = 1.4 + sin(current_time/150) * 0.08; 
    var _alp = 0.4 + random(0.1);
    var _y_ajustada = y - 5; 
    
    draw_set_alpha(_alp);
    draw_circle_colour(x, _y_ajustada, 28 * _sc, c_aqua, c_blue, false);
    
    gpu_set_blendmode(bm_normal);
    draw_set_alpha(1);
}



