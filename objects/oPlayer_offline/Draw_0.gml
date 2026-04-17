// --- BARRA DE VIDA ÉPICA (LOCAL) ---
var _x1 = x - 30;
var _y1 = y - 45;
var _x2 = x + 30;
var _y2 = y - 40;

draw_set_color(c_black);
draw_rectangle(_x1 - 1, _y1 - 1, _x2 + 1, _y2 + 1, false);

draw_set_color(c_dkgray);
draw_rectangle(_x1, _y1, _x2, _y2, false);

var _width = (health / 100) * (_x2 - _x1);
if (health > 0) {
    var _barColor = (global.myTeam == "AZUL") ? c_blue : c_red;
    draw_set_color(_barColor);
    draw_rectangle(_x1, _y1, _x1 + _width, _y2, false);
    
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

// --- EFECTOS DE INVULNERABILIDAD O DIBUJO BASE ---
if (invulnerable) {
    var _oscilacion = (sin(current_time / 100) + 1) / 2;
    var _color = merge_color(c_white, (global.myTeam == "AZUL" ? c_aqua : c_orange), _oscilacion);
    
    draw_sprite_ext(sprite_index, image_index, x, y, image_xscale, image_yscale, image_angle, _color, 0.8);
    
    gpu_set_blendmode(bm_add);
    draw_sprite_ext(sprite_index, image_index, x, y, image_xscale * 1.1, image_yscale * 1.1, image_angle, _color, 0.3);
    gpu_set_blendmode(bm_normal);
} else {
    image_blend = (global.myTeam == "AZUL") ? c_white : make_color_rgb(255, 150, 150);
    draw_self();
}

// --- DIBUJAR CADENA Y PUNTA DEL ARPÓN ---
if (state == PLAYERSTATE2.GRAPPLE) {
    var _tip_x, _tip_y, _color;
    
    if (!grapple_hitting) {
        _tip_x = x + lengthdir_x(grapple_anim_dist, grapple_dir);
        _tip_y = (y - 20) + lengthdir_y(grapple_anim_dist, grapple_dir);
        _color = c_gray; 
    } else {
        _tip_x = grapple_x;
        _tip_y = grapple_y;
        _color = (grapple_type == "PARED") ? c_aqua : c_orange;
    }
    
    draw_set_color(_color);
    draw_line_width(x, y - 20, _tip_x, _tip_y, 3);
    
    var _tri_size = 10; 
    var _tri_angle = grapple_dir; 
    
    var _p1_x = _tip_x + lengthdir_x(_tri_size * 1.5, _tri_angle);
    var _p1_y = _tip_y + lengthdir_y(_tri_size * 1.5, _tri_angle);
    var _p2_x = _tip_x + lengthdir_x(_tri_size, _tri_angle + 135);
    var _p2_y = _tip_y + lengthdir_y(_tri_size, _tri_angle + 135);
    var _p3_x = _tip_x + lengthdir_x(_tri_size, _tri_angle - 135);
    var _p3_y = _tip_y + lengthdir_y(_tri_size, _tri_angle - 135);
    
    draw_triangle(_p1_x, _p1_y, _p2_x, _p2_y, _p3_x, _p3_y, false);
    draw_set_color(c_white);
}

// ======================================================
// --- LÓGICA DE MANO Y ARMA (Sincronizada con Recoil) ---
// ======================================================
var dir = sign(image_xscale);
var tiene_arma = (guns[weapon.index] != noone && !has_flag && !instance_exists(mi_guante));

// 1. Punto de giro (Hombro de Adriana)
var hombroX = x + (2 * dir); 
var hombroY = y - 18;

// 2. Calcular dónde debe estar la mano
var handX, handY, handAngle;

if (tiene_arma) {
    var largoBrazo = 14;
    
    // --- APLICAR RECOIL A LA POSICIÓN DE LA MANO ---
    // Retroceso físico (ox, oy) y rotación (recoil_angle)
    var ox_mano = lengthdir_x(-recoil_kick * 0.6, weapon.angle);
    var oy_mano = lengthdir_y(-recoil_kick * 0.6, weapon.angle);
    
    handX = hombroX + lengthdir_x(largoBrazo, weapon.angle) + ox_mano;
    handY = hombroY + lengthdir_y(largoBrazo, weapon.angle) + oy_mano;
    handAngle = weapon.angle + recoil_angle; 
} else {
    handX = x + (11 * dir); 
    handY = y - 5;          
    handAngle = 80 * dir; 
}

// 3. DIBUJAR LA MANO
if (melee_active > 0) {
    var sx_melee = 2 * dir;
    var p = 1 - (melee_active / 6); 
    var estocada_dist = sin(p * pi) * 25; 
    
    var punch_x = x + lengthdir_x(estocada_dist + 10, (tiene_arma ? weapon.angle : (dir == 1 ? 0 : 180)));
    var punch_y = (y - 12) + lengthdir_y(estocada_dist + 10, (tiene_arma ? weapon.angle : (dir == 1 ? 0 : 180)));

    draw_sprite_ext(spr_Hand, 0, punch_x, punch_y, sx_melee, 2, 0, c_white, 1);
} 
else {
    var handScaleX = 2 * dir;
    var handScaleY = (tiene_arma && handAngle > 90 && handAngle < 270) ? -2 : 2;
    var finalHandAngle = handAngle;
    
    if (tiene_arma && dir == -1) finalHandAngle += 180;

    draw_sprite_ext(spr_Hand, 0, handX, handY, handScaleX, handScaleY, finalHandAngle, c_white, 1);
}

// 5. DIBUJAR ARMA (Anclada a la mano con recoil)
if (tiene_arma) {
    var desfase_adelante = 22; 
    var desfase_arriba = -4;   

    var weaponScaleY = (handAngle > 90 && handAngle < 270) ? -2 : 2;
    var ajuste_vertical = (weaponScaleY == -2) ? -desfase_arriba : desfase_arriba;
    
    // El arma usa handX y handY que ya tienen el recoil aplicado
    var weaponX = handX + lengthdir_x(desfase_adelante, handAngle) + lengthdir_x(ajuste_vertical, handAngle - 90);
    var weaponY = handY + lengthdir_y(desfase_adelante, handAngle) + lengthdir_y(ajuste_vertical, handAngle - 90);

    draw_sprite_ext(
        guns[weapon.index].sprite, 0,
        weaponX, weaponY, 
        2, weaponScaleY, 
        handAngle, // Ya incluye el recoil_angle de la mano
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

// --- ESCUDO ---
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