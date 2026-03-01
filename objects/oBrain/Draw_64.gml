if (global.game_over == false) 
{
#region --- TARJETA JUGADOR LOCAL ---
var gw = display_get_gui_width();
var gh = display_get_gui_height();

draw_set_font(fnt_menu); // o una font más grande si tienes
draw_set_halign(fa_center);
draw_set_valign(fa_top);

draw_set_alpha(0.8);
draw_set_color(c_black);
draw_roundrect_ext(20, gh - 80, 250, gh - 20, 10, 10, false); // Fondo negro traslúcido

draw_set_alpha(1);
draw_set_color(global.myTeam == "AZUL" ? c_aqua : c_red);
draw_set_halign(fa_left);
draw_text_transformed(40, gh - 65, global.myName, 1.2, 1.2, 0); // Tu nombre
#endregion
}
if (room == rm_menu) exit;

if (global.game_over == false) 
{
#region Dibujar Avisos(Flag Capture)
var gw = display_get_gui_width();
var xx3  = gw * 0.5;
var yy3  = 18;

draw_set_font(fnt_killfeed); // o una font más grande si tienes
draw_set_halign(fa_center);
draw_set_valign(fa_top);

for (var i = 0; i < array_length(alerts); i++)
{
    var it = alerts[i];

    draw_set_alpha(it.a);

    // sombra
    draw_set_color(c_black);
    draw_text_transformed(xx3+2, yy3 + it.yoff + i*26 + 2, it.text, 1.25, 1.25, 0);

    // texto
    draw_set_color(it.col);
    draw_text_transformed(xx3, yy3 + it.yoff + i*26, it.text, 1.25, 1.25, 0);
}

draw_set_alpha(1);
draw_set_color(c_white);
draw_set_halign(fa_left);
draw_set_valign(fa_top);

#endregion

#region // ====== evita error xx/yy/scale ======
var xx = 20;
var yy = 20;
var scale = 1.35;

// ===== OFFSCREEN INDICATOR =====
var cam = view_camera[0];

// view en ROOM
var vx = camera_get_view_x(cam);
var vy = camera_get_view_y(cam);
var vw = camera_get_view_width(cam);
var vh = camera_get_view_height(cam);

// GUI real
var gw = display_get_gui_width();
var gh = display_get_gui_height();

// centro GUI
var cx = gw * 0.5;
var cy = gh * 0.5;

// padding para que no quede pegado al borde
var pad = 24;

// targets (listo para multi: todos los proxies)
var targets = array_create(0);
with (oOtherPlayer) targets[array_length(targets)] = id;

for (var i = 0; i < array_length(targets); i++)
{
    var t = targets[i];
    if (!instance_exists(t)) continue;

    if (variable_instance_exists(t, "state") && t.state == PLAYERSTATE.DEAD) continue;
    if (variable_instance_exists(t, "visible") && !t.visible) continue;

    // ¿está en pantalla? (ROOM check)
    if (t.x >= vx && t.x <= vx + vw && t.y >= vy && t.y <= vy + vh) continue;

    // ===== convertir pos objetivo ROOM -> GUI =====
    var tx = (t.x - vx) * (gw / vw);
    var ty = (t.y - vy) * (gh / vh);

    // vector desde centro GUI hacia target
    var dx = tx - cx;
    var dy = ty - cy;

    // ángulo para rotar flecha
    var ang = point_direction(cx, cy, tx, ty);

    if (dx == 0 && dy == 0) continue;

    // ===== intersección rayo con rectángulo (pad) =====
    var left   = pad;
    var right  = gw - pad;
    var top    = pad;
    var bottom = gh - pad;

    var tMin = 1000000000;

    if (dx != 0)
    {
        var k = (left - cx) / dx;
        if (k > 0)
        {
            var yhit = cy + dy * k;
            if (yhit >= top && yhit <= bottom) tMin = min(tMin, k);
        }

        k = (right - cx) / dx;
        if (k > 0)
        {
            var yhit2 = cy + dy * k;
            if (yhit2 >= top && yhit2 <= bottom) tMin = min(tMin, k);
        }
    }

    if (dy != 0)
    {
        var k2 = (top - cy) / dy;
        if (k2 > 0)
        {
            var xhit = cx + dx * k2;
            if (xhit >= left && xhit <= right) tMin = min(tMin, k2);
        }

        k2 = (bottom - cy) / dy;
        if (k2 > 0)
        {
            var xhit2 = cx + dx * k2;
            if (xhit2 >= left && xhit2 <= right) tMin = min(tMin, k2);
        }
    }

    var guiX = cx + dx * tMin;
    var guiY = cy + dy * tMin;

    guiX -= lengthdir_x(18, ang);
    guiY -= lengthdir_y(18, ang);

    var pulse = 1 + 0.12 * sin(current_time * 0.01);

    var col = (t.team == global.myTeam) ? c_blue : c_red;

    var r = 10 * pulse;
    draw_set_color(col);
    draw_triangle(
        guiX + lengthdir_x(r*1.4, ang),
        guiY + lengthdir_y(r*1.4, ang),
        guiX + lengthdir_x(r, ang + 140),
        guiY + lengthdir_y(r, ang + 140),
        guiX + lengthdir_x(r, ang - 140),
        guiY + lengthdir_y(r, ang - 140),
        false
    );

    var icon_dist = 34;
    var ix = guiX - lengthdir_x(icon_dist, ang);
    var iy = guiY - lengthdir_y(icon_dist, ang);

    if (sprite_exists(spr_player_icon))
    {
        draw_set_alpha(0.35);
        draw_set_color(c_black);
        draw_sprite_ext(spr_player_icon, 0, ix+2, iy+2, 1, 1, 0, c_black, 1);

        draw_set_alpha(1);
        draw_set_color(c_white);
        draw_sprite_ext(spr_player_icon, 0, ix, iy, 1, 1, 0, c_white, 1);

        draw_set_color(col);
        draw_set_alpha(0.9);
        draw_circle(ix, iy, 14, false);
        draw_set_alpha(1);
    }
}

draw_set_alpha(1);
draw_set_color(c_white);
#endregion

#region // Textos de kill
draw_set_valign(fa_top);
draw_set_halign(fa_left);

var line_h = 22;                  
var line_step = line_h * scale; 

for (var i = 0; i < array_length(kill_feed); i++)
{
    var it = kill_feed[i];

    var dx = xx + it.xoff;
    var dy = yy + i * line_step + it.yoff;

    // sombra
    draw_set_alpha(it.a);
    draw_set_color(c_black);
    draw_text_transformed(dx + 1, dy + 1, it.text, scale, scale, 0);

    // texto
    draw_set_color(c_white);
    draw_text_transformed(dx, dy, it.text, scale, scale, 0);
}

draw_set_alpha(1);
draw_set_color(c_white);
#endregion

#region Tracer queue
if (variable_global_exists("tracer_queue"))
{
    for (var i = array_length(global.tracer_queue)-1; i >= 0; i--)
    {
        var t = global.tracer_queue[i];
        draw_line_width(t[0], t[1], t[2], t[3], 2);

        t[4] -= 1;
        global.tracer_queue[i] = t;

        if (t[4] <= 0) array_delete(global.tracer_queue, i, 1);
    }
}
#endregion

#region // --- TARJETA RIVAL (Lado Derecho) ---
if (instance_exists(oOtherPlayer)) 
{
    var gw = display_get_gui_width();
    var gh = display_get_gui_height();

    // 1. FONDO (Rectángulo negro traslúcido)
    draw_set_alpha(0.8);
    draw_set_color(c_black);
    draw_roundrect_ext(gw - 270, gh - 80, gw - 20, gh - 20, 10, 10, false);

    // 2. TEXTO DEL NOMBRE
    draw_set_alpha(1);
    draw_set_color(global.myTeam == "AZUL" ? c_red : c_aqua); 
    draw_set_halign(fa_right); // Alineado a la derecha
    draw_set_valign(fa_middle);

    var rivalName = "Oponente";
    
    if (oOtherPlayer.sharedProperties != -1) {
        var SP_Data;
        if (is_string(oOtherPlayer.sharedProperties)) {
            SP_Data = json_parse(oOtherPlayer.sharedProperties);
        } else {
            SP_Data = oOtherPlayer.sharedProperties;
        }

        if (variable_struct_exists(SP_Data, "_NAME")) {
            rivalName = string(SP_Data._NAME);
        }
    }
    
    draw_text_transformed(gw - 40, gh - 60, rivalName, 1.2, 1.2, 0);

    // 3. INDICADOR DE ESTADO
    draw_set_color(c_lime);
    draw_set_halign(fa_right);
    draw_text_transformed(gw - 40, gh - 35, " ONLINE", 0.8, 0.8, 0);
    
    draw_set_alpha(1); // Reset
}
#endregion

#region // PING HUD
if(global.ONLINE){
    var pad = 10;
    var gw = display_get_gui_width();
    var xx2 = gw - pad;
    var yy2 = pad;

    if (sprite_exists(spr_ping))
    {
        draw_sprite_ext(spr_ping, 0, xx2 - 100, yy2 + 10, 1, 1, 0, c_white, 1);
    }

    var col_ping = c_lime;
    if (global.ping > 120) col_ping = c_yellow;
    if (global.ping > 200) col_ping = c_red;

    draw_set_font(fnt_killfeed);
    draw_set_halign(fa_right);
    draw_set_valign(fa_top);
    draw_set_color(c_black);
    draw_text_transformed(xx2 + 1, yy2 + 1, string(global.ping) + " ms",0.8,0.8,0);
    draw_set_color(col_ping);
    draw_text_transformed(xx2, yy2, string(global.ping) + " ms",0.8,0.8,0);
    draw_set_color(c_white);
}
#endregion
}
// ======================================================
// 2. MARCADOR DINÁMICO (VS)
// ======================================================
if (!global.game_over) {
    var _gui_w = display_get_gui_width();
    var _mx_base = _gui_w / 2;
    var _my_base = 90; 

    marcador_escala_azul = lerp(marcador_escala_azul, 1.6, 0.1);
    marcador_escala_rojo = lerp(marcador_escala_rojo, 1.6, 0.1);
    marcador_shake = lerp(marcador_shake, 0, 0.1);

    var _sx = random_range(-marcador_shake, marcador_shake);
    var _sy = random_range(-marcador_shake, marcador_shake);
    var _mx = _mx_base + _sx;
    var _my = _my_base + _sy + (sin(current_time * 0.002) * 3);

    var _glow_extra = marcador_shake * 0.05;
    var _glow = (abs(sin(current_time * 0.003)) * 0.4) + _glow_extra;
    draw_set_alpha(_glow);
    draw_circle_color(_mx - 60, _my, 40, c_aqua, c_black, false);
    draw_circle_color(_mx + 60, _my, 40, c_red, c_black, false);
    draw_set_alpha(1);

    draw_set_alpha(0.85);
    draw_roundrect_color_ext(_mx - 110, _my - 32, _mx + 110, _my + 32, 20, 20, c_black, c_black, false);
    draw_roundrect_color_ext(_mx - 105, _my - 28, _mx + 105, _my + 28, 18, 18, c_dkgray, c_black, false);
    draw_set_alpha(1);

    draw_set_font(fnt_menu);
    draw_set_valign(fa_middle);
    draw_set_halign(fa_center);

    var _dist = 60;
    draw_text_transformed_color(_mx - _dist + 2, _my + 2, string(global.puntos_azul), marcador_escala_azul, marcador_escala_azul, 0, c_black, c_black, c_black, c_black, 0.5);
    draw_text_transformed_color(_mx - _dist, _my, string(global.puntos_azul), marcador_escala_azul, marcador_escala_azul, 0, c_aqua, c_aqua, c_blue, c_blue, 1);
    draw_text_transformed_color(_mx, _my, "VS", 0.7, 0.7, 0, c_white, c_white, c_gray, c_gray, 1);
    draw_text_transformed_color(_mx + _dist + 2, _my + 2, string(global.puntos_rojo), marcador_escala_rojo, marcador_escala_rojo, 0, c_black, c_black, c_black, c_black, 0.5);
    draw_text_transformed_color(_mx + _dist, _my, string(global.puntos_rojo), marcador_escala_rojo, marcador_escala_rojo, 0, c_red, c_red, c_maroon, c_maroon, 1);

    var _flecha_x = (global.myTeam == "AZUL") ? _mx - _dist : _mx + _dist;
    var _bounce = abs(sin(current_time * 0.01)) * 8; 
    draw_set_color(c_white);
    draw_triangle(_flecha_x - 8, _my - 48 - _bounce, _flecha_x + 8, _my - 48 - _bounce, _flecha_x, _my - 38 - _bounce, false);
}

// ======================================================
// 3. CAPAS SUPERIORES (MENÚ DE PAUSA Y RESULTADOS)
// ======================================================

// --- MENÚ DE PAUSA FLOTANTE ---
if (global.pausa && !global.game_over) {
    var mid_x = display_get_gui_width() / 2;
    var mid_y = display_get_gui_height() / 2;
    
    draw_set_alpha(0.6);
    draw_set_color(c_black);
    draw_rectangle(0, 0, display_get_gui_width(), display_get_gui_height(), false);
    
    var mw = 400; var mh = (global.ONLINE) ? 200 : 300;
    draw_set_alpha(0.9);
    draw_set_color(make_color_rgb(30, 30, 35));
    draw_roundrect_ext(mid_x - mw/2, mid_y - mh/2, mid_x + mw/2, mid_y + mh/2, 20, 20, false);
    
    draw_set_color(c_orange);
    draw_roundrect_ext(mid_x - mw/2, mid_y - mh/2, mid_x + mw/2, mid_y + mh/2, 20, 20, true);
    
    draw_set_alpha(1);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_text_transformed(mid_x, mid_y - (mh/2 - 40), "--- PAUSA ---", 1.5, 1.5, 0);
    
    var opciones_actuales = (global.ONLINE) ? ["CONTINUAR", "ABANDONAR PARTIDA"] : ["CONTINUAR", "REINICIAR", "SALIR AL MENU"];
    
    for (var i = 0; i < array_length(opciones_actuales); i++) {
        var color = (pause_index == i) ? c_yellow : c_white;
        var escala = (pause_index == i) ? 1.2 : 1.0;
        var texto = (pause_index == i) ? "> " + opciones_actuales[i] + " <" : opciones_actuales[i];
        draw_set_color(color);
        draw_text_transformed(mid_x, mid_y + (i * 50), texto, escala, escala, 0);
    }
}

// --- 4. PANTALLA DE RESULTADOS (CORREGIDA) ---
if (global.game_over) 
{
    var mid_x = display_get_gui_width() / 2;
    var mid_y = display_get_gui_height() / 2;
    var pulse = 1 + sin(get_timer() / 200000) * 0.05;

    draw_set_alpha(victory_alpha); 
    draw_set_color(c_black);
    draw_rectangle(0, 0, display_get_gui_width(), display_get_gui_height(), false);

    var p_w = 600; 
    var p_h = 520; // Aumentamos un poquito el alto del fondo para que quepa todo
    
    draw_set_color(c_black);
    draw_roundrect_ext(mid_x - p_w/2 + 8, mid_y - p_h/2 + 8, mid_x + p_w/2 + 8, mid_y + p_h/2 + 8, 30, 30, false);
    draw_set_color(make_color_rgb(40, 40, 45));
    draw_roundrect_ext(mid_x - p_w/2, mid_y - p_h/2, mid_x + p_w/2, mid_y + p_h/2, 30, 30, false);
    
    var _col_ganador = (global.winner_team == 1) ? c_red : c_aqua;
    draw_set_color(_col_ganador);
    draw_roundrect_ext(mid_x - p_w/2, mid_y - p_h/2, mid_x + p_w/2, mid_y + p_h/2, 30, 30, true);

    // Partículas
    for(var p=0; p<10; p++) {
        var angle = random(360);
        var dist = (get_timer()/1000 % 500) * (p/10);
        var px = mid_x + lengthdir_x(dist, angle);
        var py = mid_y + lengthdir_y(dist, angle);
        draw_circle_color(px, py, 2, _col_ganador, c_white, false);
    }

    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    var _ganador_txt = (global.winner_team == 1) ? "VICTORIA ROJA!" : "VICTORIA AZUL!";
    draw_set_color(_col_ganador);
    draw_text_transformed(mid_x, mid_y - 160, _ganador_txt, 3 * pulse, 3 * pulse, 0);

    // --- BANDERAS ---
    var spacing = 100;
    var start_x = mid_x - spacing; 
    for (var i = 1; i <= 3; i++) {
        var bx = start_x + ((i-1) * spacing);
        if (global.puntos_azul >= i) draw_sprite_ext(spr_flag_blue, 0, bx, mid_y - 60, 1.3 * pulse, 1.3 * pulse, 0, c_white, victory_alpha);
        else draw_sprite_ext(spr_flagvacia, 0, bx, mid_y - 60, 1.1, 1.1, 0, c_black, victory_alpha * 0.3);
        
        if (global.puntos_rojo >= i) draw_sprite_ext(spr_flag_red, 0, bx, mid_y + 20, 1.3 * pulse, 1.3 * pulse, 0, c_white, victory_alpha);
        else draw_sprite_ext(spr_flagvacia, 0, bx, mid_y + 20, 1.1, 1.1, 0, c_black, victory_alpha * 0.3);
    }

    // --- RECOMPENSAS PERSONALES (Subidas un poco para que no choquen) ---
    if (global.ONLINE && victory_alpha > 0.8) 
    {
        var mi_equipo = (global.myTeam == "ROJO") ? 1 : 2;
        var gane = (global.winner_team == mi_equipo);
        var recompensas_y = mid_y + 105; // Ajuste fino de altura

        if (gane) {
            draw_set_color(c_yellow);
            draw_set_font(fnt_menu); 
            draw_text_transformed(mid_x, recompensas_y, "+25 TROFEOS", 1.1 * pulse, 1.1 * pulse, 0);
            draw_set_color(c_lime);
            draw_set_font(fnt_small);
            draw_text(mid_x, recompensas_y + 30, "+50 XP"); // Reduje de +35 a +30
        } else {
            draw_set_color(c_red);
            draw_set_font(fnt_menu);
            draw_text_transformed(mid_x, recompensas_y, "-15 TROFEOS", 1.0, 1.0, 0);
            draw_set_color(c_white);
            draw_set_font(fnt_small);
            draw_text(mid_x, recompensas_y + 30, "+5 XP");
        }
    }

    // --- OPCIONES DINÁMICAS (BAJADAS PARA LIMPIEZA) ---
    if (victory_alpha >= 0.9) {
        var opciones_vic = (global.ONLINE) ? ["EXIT"] : ["RESTART", "EXIT"];

        for (var i = 0; i < array_length(opciones_vic); i++) {
            var color = (victory_index == i) ? c_yellow : c_white;
            var escala = (victory_index == i) ? 1.3 : 1.1;
            var txt = (victory_index == i) ? ">> " + opciones_vic[i] + " <<" : opciones_vic[i];
            
            // 🔥 AQUÍ ESTÁ EL CAMBIO: Sumamos +190 en lugar de +140 para alejarlo de la XP
            draw_set_color(color);
            draw_text_transformed(mid_x, mid_y + 190 + (i * 45), txt, escala, escala, 0);
        }
    }
    
    draw_set_alpha(1); 
}

// Reset Final
draw_set_alpha(1);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);






