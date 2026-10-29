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
var _ancho_barra = (_x2 - _x1);
var _porcentaje = clamp(health / max_health, 0, 1); 
var _width_final = _porcentaje * _ancho_barra;

if (health > 0) {
    draw_set_color(c_blue);
    draw_rectangle(_x1, _y1, _x1 + _width_final, _y2, false);
    draw_set_color(c_aqua);
    draw_line(_x1, _y1, _x1 + _width_final, _y1);
}

draw_set_halign(fa_center);
draw_set_font(fnt_small);
draw_set_color(c_white);
draw_text(x, y - 60, string(playerName));

if (invulnerable) {
    var _oscilacion = (sin(current_time / 100) + 1) / 2;
    var _color = merge_color(c_white, c_aqua, _oscilacion);
    draw_sprite_ext(sprite_index, image_index, x, y, image_xscale, image_yscale, image_angle, _color, 0.8);
    gpu_set_blendmode(bm_add);
    draw_sprite_ext(sprite_index, image_index, x, y, image_xscale * 1.1, image_yscale * 1.1, image_angle, _color, 0.3);
    gpu_set_blendmode(bm_normal);
} else {
    draw_self();
}

// --- BRAZO Y ARMA: no se dibujan si el personaje está muerto ---
if (state != PLAYERSTATE.DEAD) {

    var dir = sign(image_xscale);
    var tiene_arma = (guns[weapon.index] != noone && !has_flag && !instance_exists(mi_guante));

    // 1. Punto de giro (Hombro)
    var hombroX = x + (2 * dir); 
    var hombroY = y - 18;

    // 2. Calcular dónde debe estar la mano
    var handX, handY, handAngle;

    if (tiene_arma) {
        var largoBrazo = 14;
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

    // Arma (solo si tengo arma, no tengo bandera y el guante no está volando)
    if (tiene_arma) {
        var desfase_adelante = 22; 
        var desfase_arriba = -4;   
        var weaponScaleY = (handAngle > 90 && handAngle < 270) ? -2 : 2;
        var ajuste_vertical = (weaponScaleY == -2) ? -desfase_arriba : desfase_arriba;
        var weaponX = handX + lengthdir_x(desfase_adelante, handAngle) + lengthdir_x(ajuste_vertical, handAngle - 90);
        var weaponY = handY + lengthdir_y(desfase_adelante, handAngle) + lengthdir_y(ajuste_vertical, handAngle - 90);
        draw_sprite_ext(guns[weapon.index].sprite, 0, weaponX, weaponY, 2, weaponScaleY, handAngle, c_white, 1);
    }

} // fin brazo y arma

if (reloading)
{
    var spr = spr_reload_circle;
    var frames = sprite_get_number(spr);
    var progress = 1 - (reload_timer / reload_max);
    var frame = floor(progress * (frames - 1));
    frame = clamp(frame, 0, frames - 1);
    var yy = bbox_top - 25;
    draw_sprite_ext(spr, frame, x, yy, 0.5, 0.5, 0, c_white, 1);
}

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