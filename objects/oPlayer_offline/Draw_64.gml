// --- INDICADOR DE BANDERA TIPO RADAR (Modo Local) ---
if (state != PLAYERSTATE.DEAD) {
    // REGLA: Si soy Azul, debo robar la Roja (oFlag). Si soy Rojo, debo robar la Azul (oFlag2).
    var target_flag = (global.myTeam == "AZUL") ? oFlag : oFlag2; 

    if (instance_exists(target_flag)) {
        var camX = camera_get_view_x(view_camera[0]);
        var camY = camera_get_view_y(view_camera[0]);
        var camW = camera_get_view_width(view_camera[0]);
        var camH = camera_get_view_height(view_camera[0]);

        // Solo dibujar si la bandera enemiga está fuera de la cámara
        if (target_flag.x < camX || target_flag.x > camX + camW || 
            target_flag.y < camY || target_flag.y > camY + camH) {
            
            var dir = point_direction(camX + camW/2, camY + camH/2, target_flag.x, target_flag.y);
            
            // Posición en la GUI
            var margin = 55;
            var centerX = clamp(target_flag.x - camX, margin, display_get_gui_width() - margin);
            var centerY = clamp(target_flag.y - camY, margin, display_get_gui_height() - margin);

            // COLOR: El objetivo siempre se ve Rojo (enemigo)
            var col = c_red; 

            var dist = 25; 
            var arrowX = centerX + lengthdir_x(dist, dir);
            var arrowY = centerY + lengthdir_y(dist, dir);

            // Dibujar flecha y bandera
            draw_sprite_ext(sTroangle, 0, arrowX, arrowY, 1, 1, dir, col, 1);
            draw_sprite_ext(spr_flagvacia, 0, centerX, centerY, 2, 2, 0, col, 1);
        }
    }
}

// --- FLASH DE DAÑO (Toda la pantalla) ---
if (damage_alpha > 0) {
    draw_set_alpha(damage_alpha);
    draw_set_color(c_red);
    draw_rectangle(0, 0, display_get_gui_width(), display_get_gui_height(), false);
    draw_set_alpha(1);
    
    // Desvanecimiento suave
    damage_alpha -= 0.05; 
}

// --- EFECTO DE PANTALLA AL TENER BANDERA ---
if (has_flag) {
    var _w = display_get_gui_width();
    var _h = display_get_gui_height();
    
    var _pulse = 0.15 + abs(sin(current_time / 300)) * 0.2;
    var _color = (global.myTeam == "AZUL") ? c_aqua : c_orange; // El color del pulso según tu equipo
    
    // Capa 1: Degradado suave
    draw_set_alpha(_pulse * 0.5);
    draw_set_color(_color);
    var _thick1 = 80;
    draw_rectangle(0, 0, _w, _thick1, false);
    draw_rectangle(0, _h - _thick1, _w, _h, false);
    draw_rectangle(0, 0, _thick1, _h, false);
    draw_rectangle(_w - _thick1, 0, _w, _h, false);

    // Capa 2: Borde brillante
    draw_set_alpha(_pulse);
    var _thick2 = 15;
    draw_rectangle(0, 0, _w, _thick2, false);
    draw_rectangle(0, _h - _thick2, _w, _h, false);
    draw_rectangle(0, 0, _thick2, _h, false);
    draw_rectangle(_w - _thick2, 0, _w, _h, false);

    // Toque Glitch
    if (irandom(10) > 8) {
        draw_set_alpha(random(0.3));
        draw_line_width_color(random(_w), 0, random(_w), _h, 2, _color, c_white);
    }

    // Brillo en esquinas
    draw_set_circle_precision(64);
    gpu_set_blendmode(bm_add);
    draw_circle_colour(0, 0, 150, _color, c_black, false);
    draw_circle_colour(_w, 0, 150, _color, c_black, false);
    draw_circle_colour(0, _h, 150, _color, c_black, false);
    draw_circle_colour(_w, _h, 150, _color, c_black, false);
    gpu_set_blendmode(bm_normal);
    
    draw_set_alpha(1);
    draw_set_color(c_white);
}

// --- TIMERS DE POWERUPS ---
var _gui_h = display_get_gui_height();
var _draw_y = _gui_h - 150; 

// ESCUDO
if (shield_timer > 0) {
    draw_set_color(c_aqua);
    draw_text(20, _draw_y, "ESCUDO: " + string(ceil(shield_timer/60)) + "s");
    draw_rectangle(20, _draw_y + 20, 20 + (shield_timer/6), _draw_y + 25, false);
    _draw_y -= 40;
}

// DAÑO X2
if (damage_timer > 0) {
    draw_set_color(c_red);
    draw_text(20, _draw_y, "DAÑO X2: " + string(ceil(damage_timer/60)) + "s");
    draw_rectangle(20, _draw_y + 20, 20 + (damage_timer/6), _draw_y + 25, false);
    _draw_y -= 40;
}

// MUNICIÓN INFINITA
if (ammo_timer > 0) {
    draw_set_color(c_orange);
    draw_text(20, _draw_y, "AMMO INF: " + string(ceil(ammo_timer/60)) + "s");
    draw_rectangle(20, _draw_y + 20, 20 + (ammo_timer/6), _draw_y + 25, false);
}

draw_set_color(c_white); // Reset final para no pintar todo de naranja