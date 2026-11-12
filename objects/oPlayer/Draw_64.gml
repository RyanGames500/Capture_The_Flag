if(global.game_over) exit;

// --- OBJETIVO: que hacer ahora, flecha al objetivo y ayudas (scr_objetivo) ---
if (state != PLAYERSTATE.DEAD) scr_draw_objetivo(id);

	
	// Dibujar un rectángulo rojo que cubre TODA la pantalla
if (damage_alpha > 0) {
    draw_set_alpha(damage_alpha);
    draw_set_color(c_red);
    draw_rectangle(0, 0, display_get_gui_width(), display_get_gui_height(), false);
    draw_set_alpha(1);
    
    // El flash se desvanece poco a poco
    damage_alpha -= 0.05; 
}

if (has_flag) scr_bandera_gui_draw();   // efecto A (scr_fx)

// Granada cegadora: pantalla blanca (scr_armas)
scr_efx_draw_ciego();

// Hitmarker: va después del flash rojo y del brillo de la bandera para que nada lo tape
scr_hitmarker_draw();

// Pantalla de respawn: ELIMINADO POR + cuenta regresiva (scr_fx)
scr_respawn_draw(state == PLAYERSTATE2.DEAD);
if (state == PLAYERSTATE2.DEAD) exit;

// oPlayer - Draw GUI Event (HUD PRINCIPAL)

// HUD NUEVO (draw_player_profile): tu carta arriba a la izquierda y tu arma arriba a la derecha
if (MN_NUEVO) { scr_hud_nuevo(); } else {
// --- CONFIGURACIÓN BASE ---
var _escala = 4; 
var _xx = 40; 
var _yy = 56;   // un poco más abajo: arriba va tu nombre
var _alto_barra = 12 * _escala; 
var _offset_y = _alto_barra + (4 * _escala); 

// --- TU NOMBRE (arriba, junto a tu vida) ---
draw_set_font(fnt_menu);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
var _col_nom = (scr_my_team() == "AZUL") ? c_aqua : c_red;
draw_text_transformed_color(_xx + 2, 16 + 2, string(global.myName), 0.9, 0.9, 0, c_black, c_black, c_black, c_black, 1);
draw_text_transformed_color(_xx, 16, string(global.myName), 0.9, 0.9, 0, _col_nom, _col_nom, _col_nom, _col_nom, 1);

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

// Icono de tu habilidad junto a la vida (scr_personajes)
scr_hab_hud(_xx + _w * _escala + 40, _yy + _alto_barra / 2);
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

// Micro y bocina del chat de voz: chiquitos debajo de tus barras (scr_objetivo)
voz_hud_y = _current_y + (infinite_ammo ? _offset_y : 0);
scr_voz_hud();   // en la PC se dibujan aqui; en el celular son botones (scr_touch)

draw_set_color(c_white);


// --- CONFIGURACIÓN ---
var _escala_hud = 4; // Mantenemos tu escala original
var _gui_w = display_get_gui_width();
var _gui_h = display_get_gui_height();

// Arriba a la derecha (abajo están los joysticks en el celular).
// En el celular se corre a la izquierda para no tapar los botones de pausa y emotes.
var _bx = _gui_w - 135;
var _by = 20;
if (touch_mode()) _bx = _gui_w - 335;

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
    draw_sprite_ext(w.sprite, 0, _centro_x, _centro_y, _escala_hud - 1, _escala_hud - 1, 0, scr_arma_tinte(w), 1);

    // --- MUNICIÓN CON SEGURO ---
    var _res_val = reserve[$ w.ammoType];
    var _res_texto = (_res_val == undefined) ? "0" : string(_res_val);
    var _ammo_text = string(w.ammo) + " / " + _res_texto;
    if (w.ammoType == "") _ammo_text = "x" + string(w.ammo);   // railgun y mina: solo las cargas que quedan
    
    var _col_ammo = (w.ammo == 0) ? c_red : c_white;
    draw_text_transformed_color(_centro_x, _by + _alto_cuadro + 10, _ammo_text, 1, 1, 0, _col_ammo, _col_ammo, _col_ammo, _col_ammo, 1);
} 
else {
    // --- CASO MELEE ---
    draw_sprite_ext(spr_Hand, 0, _centro_x-15, _centro_y, _escala_hud, _escala_hud, 0, c_white, 1);
    draw_text_transformed_color(_centro_x, _by + _alto_cuadro + 10, "MELEE", 1, 1, 0, c_aqua, c_aqua, c_aqua, c_aqua, 1);
}

// --- SEGUNDA ARMA: cuadro chico a la izquierda (scr_armas, SEGUNDA ARMA) ---
var _gx_base = _bx - 40;
if (scr_slots_dos()) {
    scr_slot_init();
    var _e2 = 2.4;
    var _w2 = sprite_get_width(spr_HUD_Box) * _e2;
    var _h2 = sprite_get_height(spr_HUD_Box) * _e2;
    var _x2 = _bx - _w2 - 14;
    var _y2 = _by + (_alto_cuadro - _h2) / 2;
    slot2_x1 = _x2 - 6; slot2_y1 = _y2 - 6; slot2_x2 = _x2 + _w2 + 6; slot2_y2 = _y2 + _h2 + 30;   // donde se toca
    var _o2 = guns[1 - weapon.index];
    var _a2 = (_o2 != noone) ? 0.8 : 0.35;
    draw_sprite_ext(spr_HUD_Box, 0, _x2, _y2, _e2, _e2, 0, c_white, _a2);
    if (_o2 != noone && is_struct(_o2)) {
        draw_sprite_ext(_o2.sprite, 0, _x2 + _w2 / 2, _y2 + _h2 / 2, _e2 - 0.8, _e2 - 0.8, 0, scr_arma_tinte(_o2), 0.85);
        draw_set_font(fnt_menu);
        draw_set_halign(fa_center);
        var _t2 = (_o2.ammoType == "") ? "x" + string(_o2.ammo) : string(_o2.ammo);
        draw_text_transformed_color(_x2 + _w2 / 2, _y2 + _h2 + 8, _t2, 0.7, 0.7, 0, c_ltgray, c_ltgray, c_ltgray, c_ltgray, 1);
        if (!touch_mode()) {
            // Tecla para cambiar
            draw_set_color(make_color_rgb(44, 49, 69));
            draw_roundrect(_x2 + _w2 - 18, _y2 - 8, _x2 + _w2 + 4, _y2 + 12, false);
            draw_set_color(c_white);
            draw_text_transformed(_x2 + _w2 - 7, _y2 + 2, "E", 0.6, 0.6, 0);
        }
    }
    _gx_base = _x2 - 40;
}

// --- INDICADOR DE GRANADAS ---
if (granadas > 0) {
    var _gx = _gx_base;
    var _gy = _by + (_alto_cuadro / 2);
    draw_sprite_ext(spr_granada, 0, _gx, _gy, 2, 2, 0, scr_granada_col(variable_instance_exists(id, "granada_tipo") ? granada_tipo : ""), 1);
    draw_set_halign(fa_right);
    draw_text_transformed(_gx - 10, _gy - 10, "x" + string(granadas), 1, 1, 0);
}

draw_set_halign(fa_left);
}
