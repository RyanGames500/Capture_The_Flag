/*if(global.game_over) exit;

// --- INDICADOR DE BANDERA TIPO RADAR (Fix Equipos) ---
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

            // COLOR TIPO BRAWL STARS: El objetivo siempre es "Rojo" para ti
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
	
	// Dibujar un rectángulo rojo que cubre TODA la pantalla
if (damage_alpha > 0) {
    draw_set_alpha(damage_alpha);
    draw_set_color(c_red);
    draw_rectangle(0, 0, display_get_gui_width(), display_get_gui_height(), false);
    draw_set_alpha(1);
    
    // El flash se desvanece poco a poco
    damage_alpha -= 0.05; 
}

if (has_flag) {
    var _w = display_get_gui_width();
    var _h = display_get_gui_height();
    
    // 1. EL PULSO (Un poco más rápido para dar adrenalina)
    var _pulse = 0.15 + abs(sin(current_time / 300)) * 0.2;
    var _color = c_aqua; 
    
    // 2. CAPA 1: Degradado suave (El borde más ancho y muy transparente)
    draw_set_alpha(_pulse * 0.5);
    draw_set_color(_color);
    var _thick1 = 80; // Un borde muy ancho que se mete a la pantalla
    draw_rectangle(0, 0, _w, _thick1, false); // Arriba
    draw_rectangle(0, _h - _thick1, _w, _h, false); // Abajo
    draw_rectangle(0, 0, _thick1, _h, false); // Izq
    draw_rectangle(_w - _thick1, 0, _w, _h, false); // Der

    // 3. CAPA 2: El brillo intenso (El borde fino que viste en el video)
    draw_set_alpha(_pulse);
    var _thick2 = 15; // El borde delgadito y brillante
    draw_rectangle(0, 0, _w, _thick2, false);
    draw_rectangle(0, _h - _thick2, _w, _h, false);
    draw_rectangle(0, 0, _thick2, _h, false);
    draw_rectangle(_w - _thick2, 0, _w, _h, false);

    // 4. EL TOQUE "GLITCH" (Líneas que cruzan los bordes a veces)
    if (irandom(10) > 8) {
        draw_set_alpha(random(0.3));
        draw_line_width_color(random(_w), 0, random(_w), _h, 2, _color, c_white);
    }

    draw_set_alpha(1);
    draw_set_color(c_white);
	
	
	draw_set_circle_precision(64);
	gpu_set_blendmode(bm_add);
	// Dibujar círculos en las esquinas para reforzar el brillo
	draw_circle_colour(0, 0, 150, _color, c_black, false);
	draw_circle_colour(_w, 0, 150, _color, c_black, false);
	draw_circle_colour(0, _h, 150, _color, c_black, false);
	draw_circle_colour(_w, _h, 150, _color, c_black, false);
	gpu_set_blendmode(bm_normal);
}

if (state == PLAYERSTATE2.DEAD) exit;

// oPlayer - Draw GUI Event (HUD PRINCIPAL)

// --- CONFIGURACIÓN BASE ---
var _escala = 4; 
var _xx = 40; 
var _yy = 40;
var _alto_barra = 12 * _escala; 
var _offset_y = _alto_barra + (4 * _escala); 

// 1. BARRA DE VIDA DINÁMICA
// Usamos lerp para que la barrita se mueva suave cuando te curas o te pegan
vida_visual = lerp(vida_visual, health, 0.2);

// Dibujar el fondo vacío (el marco)
draw_sprite_ext(spr_HUD_Bar_Empty, 0, _xx, _yy, _escala, _escala, 0, c_white, 1);

var _w = sprite_get_width(spr_HUD_Bar_Health);
var _h = sprite_get_height(spr_HUD_Bar_Health);

// --- EL TRUCO MAESTRO ---
// Calculamos qué porcentaje de la barra llenar (valor entre 0 y 1)
var _porcentaje_real = clamp(vida_visual / max_health, 0, 1);

// Dibujamos solo la parte proporcional del sprite de vida
draw_sprite_part_ext(spr_HUD_Bar_Health, 0, 0, 0, _w * _porcentaje_real, _h, _xx, _yy, _escala, _escala, c_white, 1);
// Variable para saber dónde dibujar la siguiente barra
var _current_y = _yy + _offset_y;

// --- 2. BARRA DE ESCUDO (Azul) ---
if (has_shield) {
    draw_sprite_ext(spr_HUD_Bar_Empty, 0, _xx, _current_y, _escala, _escala, 0, c_white, 1);
    var _porc_s = clamp(shield_timer / 600, 0, 1);
    draw_sprite_part_ext(spr_HUD_Bar_Shield, 0, 0, 0, _w * _porc_s, _h, _xx, _current_y, _escala, _escala, c_white, 1);
    
    _current_y += _offset_y; // Bajamos la posición para el siguiente
}

// --- 3. BARRA DE DAÑO BOOST (Roja o Naranja) ---
if (damage_boost > 1) {
    draw_sprite_ext(spr_HUD_Bar_Empty, 0, _xx, _current_y, _escala, _escala, 0, c_white, 1);
    // Suponiendo que el daño dura unos 10 segundos (600 frames)
    var _porc_d = clamp(damage_timer / 600, 0, 1); 
    
    // Aquí puedes usar spr_HUD_Bar_Health (rojo) o uno amarillo si tienes
    draw_sprite_part_ext(spr_HUD_Bar_Blank, 0, 0, 0, _w * _porc_d, _h, _xx, _current_y, _escala, _escala, c_orange, 1);
    
    _current_y += _offset_y;
}

// --- 4. BARRA DE VELOCIDAD (Amarilla o Verde) ---
if (speed_timer > 0) {
    draw_sprite_ext(spr_HUD_Bar_Empty, 0, _xx, _current_y, _escala, _escala, 0, c_white, 1);
    var _porc_sp = clamp(speed_timer / 600, 0, 1);
    
    // Usamos c_lime o c_yellow para diferenciarla
    draw_sprite_part_ext(spr_HUD_Bar_Blank, 0, 0, 0, _w * _porc_sp, _h, _xx, _current_y, _escala, _escala, c_lime, 1);
    
    _current_y += _offset_y;
}

// --- 5. BARRA DE MUNICIÓN INFINITA (Opcional) ---
if (infinite_ammo) {
    draw_sprite_ext(spr_HUD_Bar_Empty, 0, _xx, _current_y, _escala, _escala, 0, c_white, 1);
    var _porc_a = clamp(ammo_timer / 600, 0, 1);
    draw_sprite_part_ext(spr_HUD_Bar_Blank, 0, 0, 0, _w * _porc_a, _h, _xx, _current_y, _escala, _escala, c_aqua, 1);
}

draw_set_color(c_white);


// --- CONFIGURACIÓN ---
var _escala_hud = 4; // Mantenemos tu escala original
var _gui_w = display_get_gui_width();
var _gui_h = display_get_gui_height();

// AJUSTE DE POSICIÓN:
// _bx: Menos resta = más a la derecha. (Antes 150, ahora 135)
// _by: Más resta = más arriba. (Antes 150, ahora 180)
var _bx = _gui_w - 135; 
var _by = _gui_h - 180; 

// Dimensiones del cuadro para centrar
var _ancho_cuadro = sprite_get_width(spr_HUD_Box) * _escala_hud;
var _alto_cuadro  = sprite_get_height(spr_HUD_Box) * _escala_hud;
var _centro_x = _bx + (_ancho_cuadro / 2);
var _centro_y = _by + (_alto_cuadro / 2);

// 1. DIBUJAR EL CUADRO ANIMADO
draw_sprite_ext(spr_HUD_Box, image_index, _bx, _by, _escala_hud, _escala_hud, 0, c_white, 1);

var w = guns[weapon.index];
draw_set_font(fnt_menu);
draw_set_halign(fa_center);

if (w != noone && is_struct(w)) {
    // --- DIBUJAR ARMA ---
    draw_sprite_ext(w.sprite, 0, _centro_x, _centro_y, _escala_hud - 1, _escala_hud - 1, 0, c_white, 1);

    // --- MUNICIÓN CON SEGURO ---
    var _res_val = reserve[$ w.ammoType];
    var _res_texto = (_res_val == undefined) ? "0" : string(_res_val);
    var _ammo_text = string(w.ammo) + " / " + _res_texto;
    
    var _col_ammo = (w.ammo == 0) ? c_red : c_white;
    draw_text_transformed_color(_centro_x, _by + _alto_cuadro + 10, _ammo_text, 1, 1, 0, _col_ammo, _col_ammo, _col_ammo, _col_ammo, 1);
} 
else {
    // --- CASO MELEE ---
    draw_sprite_ext(spr_Hand, 0, _centro_x-15, _centro_y, _escala_hud, _escala_hud, 0, c_white, 1);
    draw_text_transformed_color(_centro_x, _by + _alto_cuadro + 10, "MELEE", 1, 1, 0, c_aqua, c_aqua, c_aqua, c_aqua, 1);
}

// --- INDICADOR DE GRANADAS ---
if (granadas > 0) {
    var _gx = _bx - 40;
    var _gy = _by + (_alto_cuadro / 2);
    draw_sprite_ext(spr_granada, 0, _gx, _gy, 2, 2, 0, c_white, 1);
    draw_set_halign(fa_right);
    draw_text_transformed(_gx - 10, _gy - 10, "x" + string(granadas), 1, 1, 0);
}

draw_set_halign(fa_left);