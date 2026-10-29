fx_draw_gui();

var player_name=global.myName;
var player_ID=gmda_getPlayerid();
var status=gmda_status();

if (!variable_global_exists("revancha_pendiente")) {
    global.revancha_pendiente = false;
}

draw_set_font(fnt_menu)
//draw_text(100,300,"ID: "+string(is_closing));
//draw_text(100,300+30,"Name: "+player_name);
//draw_text(100,300+60,"Status: "+string(status));

// Obtener los datos globales de puntaje
var globalscores = gmda_getTabledata(gmda_globaltable, 1);

// Dibujar los encabezados
//draw_text(480, 220, "Name:");
//draw_text(760, 220, "Score:");

// Si existen puntajes globales
if (globalscores > 0) {
    var tablesize = ds_map_size(globalscores);
    var rowinfo;
    
    // Iterar sobre los puntajes y nombres
    for (var i = 1; i <= tablesize; i++) {
        rowinfo = ds_map_find_value(globalscores, string(i));
        var name = ds_map_find_value(rowinfo, "name");
        var xscore = ds_map_find_value(rowinfo, "score");
        
        // Dibujar cada fila de la tabla con nombres y puntajes
        //draw_text(480, 220 + 32 * i, string(i) + ". " + string(name));
        //draw_text(780, 220 + 32 * i, string(xscore));
    }
}

if is_closing=true and room == rm_menu
{
gmda_draw_table(25,330,globalscores,player_name)//y=590


}


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

// --- 4. PANTALLA DE RESULTADOS (SIN REVANCHA) ---
if (global.game_over && !abandono_activo)
{
    var mid_x = display_get_gui_width() / 2;
    var mid_y = display_get_gui_height() / 2;
    var pulse = 1 + sin(get_timer() / 200000) * 0.05;

    // Fondo oscuro
    draw_set_alpha(victory_alpha * 0.8); 
    draw_set_color(c_black);
    draw_rectangle(0, 0, display_get_gui_width(), display_get_gui_height(), false);

    // Medidas del panel
    var p_w = 600; 
    var p_h = 520; 
    
    draw_set_alpha(victory_alpha);
    draw_set_color(c_black);
    draw_roundrect_ext(mid_x - p_w/2 + 10, mid_y - p_h/2 + 10, mid_x + p_w/2 + 10, mid_y + p_h/2 + 10, 30, 30, false);
    
    draw_set_color(make_color_rgb(26, 26, 32));
    draw_roundrect_ext(mid_x - p_w/2, mid_y - p_h/2, mid_x + p_w/2, mid_y + p_h/2, 30, 30, false);
    
    var _col_ganador = (global.winner_team == 1) ? make_color_rgb(204, 0, 0) : c_aqua;
    draw_set_color(_col_ganador);
    draw_roundrect_ext(mid_x - p_w/2, mid_y - p_h/2, mid_x + p_w/2, mid_y + p_h/2, 30, 30, true);

    // Partículas
    for(var p=0; p<8; p++) {
        var angle = (get_timer()/5000 + (p * 45)) % 360;
        var dist = 200 + (sin(get_timer()/100000) * 20);
        var px = mid_x + lengthdir_x(dist, angle);
        var py = mid_y + lengthdir_y(dist, angle);
        draw_circle_color(px, py, 3 * victory_alpha, _col_ganador, c_white, false);
    }

    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    
    // Título
    var _ganador_txt = (global.winner_team == 1) ? "VICTORIA ROJA!" : "VICTORIA AZUL!";
    draw_set_color(_col_ganador);
    draw_text_transformed(mid_x, mid_y - 190, _ganador_txt, 2.5 * pulse, 2.5 * pulse, 0);

    // Banderas
    var spacing = 90;
    var start_x = mid_x - spacing; 
    for (var i = 1; i <= 3; i++) {
        var bx = start_x + ((i-1) * spacing);
        if (global.puntos_azul >= i) draw_sprite_ext(spr_flag_blue, 0, bx, mid_y - 90, 1.2, 1.2, 0, c_white, victory_alpha);
        else draw_sprite_ext(spr_flagvacia, 0, bx, mid_y - 90, 1.0, 1.0, 0, c_white, victory_alpha * 0.2);
        
        if (global.puntos_rojo >= i) draw_sprite_ext(spr_flag_red, 0, bx, mid_y - 10, 1.2, 1.2, 0, c_white, victory_alpha);
        else draw_sprite_ext(spr_flagvacia, 0, bx, mid_y - 10, 1.0, 1.0, 0, c_white, victory_alpha * 0.2);
    }

    // Recompensas
    if (global.ONLINE && victory_alpha > 0.8) 
    {
        var mi_equipo = (global.myTeam == "ROJO") ? 1 : 2;
        var gane = (global.winner_team == mi_equipo);
        var recompensas_y = mid_y + 90; 

        if (gane) {
            draw_set_color(make_color_rgb(255, 235, 59));
            draw_text_transformed(mid_x, recompensas_y, "+25 TROFEOS", 1.2 * pulse, 1.2 * pulse, 0);
            draw_set_color(make_color_rgb(76, 175, 80));
            draw_text(mid_x, recompensas_y + 40, "+50 XP");
        } else {
            draw_set_color(c_red);
            draw_text(mid_x, recompensas_y, "-15 TROFEOS");
            draw_set_color(c_white);
            draw_text(mid_x, recompensas_y + 40, "+5 XP");
        }
    }

    // --- BOTONES ACTUALIZADOS (SIN REVANCHA) ---
    if (victory_alpha >= 0.9) {
        // Quitamos "REVANCHA" del array
        var opciones_vic = (global.ONLINE) ? ["ENV. SOLICT", "EXIT"] : ["RESTART", "EXIT"];
        
        var btn_w = 200; // Un poco más anchos para que luzcan mejor
        var btn_h = 50;
        var total_btns = array_length(opciones_vic);
        var separation = 30;
        var total_w = (total_btns * btn_w) + ((total_btns - 1) * separation);
        var btn_start_x = mid_x - total_w / 2;

        for (var i = 0; i < total_btns; i++) {
            var bx = btn_start_x + (i * (btn_w + separation));
            var by = mid_y + 180;
            
            var is_selected = (victory_index == i);
            var b_col_border = is_selected ? c_yellow : _col_ganador;
            var b_col_text = is_selected ? c_yellow : c_white;
            var b_scale = is_selected ? 1.05 : 1.0;

            // Caja del botón
            draw_set_color(make_color_rgb(20, 20, 25)); 
            draw_roundrect_ext(bx, by, bx + btn_w, by + btn_h, 10, 10, false);
            draw_set_color(b_col_border);
            draw_roundrect_ext(bx, by, bx + btn_w, by + btn_h, 10, 10, true);

            // Texto
            var txt = opciones_vic[i];
            if (txt == "EXIT") txt = "] EXIT ["; 

            draw_set_color(b_col_text);
            draw_set_font(fnt_small);
            draw_text_transformed(bx + btn_w/2, by + btn_h/2, txt, b_scale, b_scale, 0);
        }
    }
}

// Resets
draw_set_alpha(1);
draw_set_halign(fa_left);
draw_set_valign(fa_top);




if (!intro_disparada && room != rm_menu && global.ONLINE == true) {
    var sw = display_get_gui_width();
    var sh = display_get_gui_height();
    
    // 1. FONDO CON GRADIENTE
    draw_set_alpha(0.85);
    draw_rectangle_color(0, 0, sw, sh, c_black, c_black, make_color_rgb(10, 30, 50), make_color_rgb(10, 30, 50), false);
    draw_set_alpha(1);

    // 2. TÍTULO Y CRONÓMETRO
    draw_set_halign(fa_center);
    var segs = ceil(timer_intro / 60);
    draw_text_transformed_color(sw/2, 50, "SELECT YOUR WARRIOR: " + string(segs), 1.5, 1.5, 0, c_white, c_white, c_yellow, c_yellow, 1);

    // --- VARIABLES DE POSICIONAMIENTO ---
    var countAzul = 0;
    var countRojo = 0;
    var gapY = 480;      // Espacio vertical (Aumentado mucho para slots altos)
    var startY = sh * 0.15; // Empezamos más arriba
    var box_w = 260;     // Ancho del slot
    var box_h = 440;     // ALTO DEL SLOT (Aumentado para ver cuerpo completo)

    // 3. MI SLOT
    var myX = (global.myTeam == "AZUL") ? sw * 0.22 : sw * 0.78;
    var myY = startY + ((global.myTeam == "AZUL" ? countAzul : countRojo) * gapY);
    
    draw_bomb_slot(myX, myY, global.pj_selected, global.myName, global.mi_listo, true, global.myTeam, box_w, box_h);
    if (global.myTeam == "AZUL") countAzul++; else countRojo++;

    // 4. SLOTS DE OTROS JUGADORES
    with(oOtherPlayer) {
        var isAzul = (team == "AZUL");
        var drawX = isAzul ? sw * 0.22 : sw * 0.78;
        var drawY = startY + ((isAzul ? countAzul : countRojo) * gapY);
        
        var _pj = variable_instance_exists(id, "mySelectedPJ") ? mySelectedPJ : 0;
        var _rdy = variable_instance_exists(id, "isReady") ? isReady : false;
        
        draw_bomb_slot(drawX, drawY, _pj, Name, _rdy, false, team, box_w, box_h);
        if (isAzul) countAzul++; else countRojo++;
    }
}
	
// ======================================================
// 🚪 AVISO DE ABANDONO
// ======================================================
if (abandono_activo) {
    var _gw = display_get_gui_width();
    var _gh = display_get_gui_height();
    var _cx = _gw / 2;
    var _cy = _gh / 2;

    // Entrada suave y pulso
    var _t    = abandono_total - abandono_timer;
    var _in   = clamp(_t / 20, 0, 1);
    var _ease = 1 - power(1 - _in, 3);
    var _pulse = 1 + sin(current_time * 0.006) * 0.03;

    var _col = abandono_gano ? make_color_rgb(255, 205, 60) : make_color_rgb(150, 160, 175);
    var _col_team = (global.myTeam == "ROJO") ? make_color_rgb(220, 40, 40) : c_aqua;

    // Fondo oscuro
    draw_set_alpha(0.75 * _ease);
    draw_set_color(c_black);
    draw_rectangle(0, 0, _gw, _gh, false);

    // Tarjeta (sube un poco al aparecer)
    var _w = 560, _h = 300;
    var _yoff = (1 - _ease) * 40;
    var _x1 = _cx - _w/2, _y1 = _cy - _h/2 + _yoff;
    var _x2 = _cx + _w/2, _y2 = _cy + _h/2 + _yoff;

    draw_set_alpha(_ease);
    draw_set_color(c_black);
    draw_roundrect_ext(_x1 + 8, _y1 + 8, _x2 + 8, _y2 + 8, 28, 28, false); // sombra
    draw_set_color(make_color_rgb(24, 24, 30));
    draw_roundrect_ext(_x1, _y1, _x2, _y2, 28, 28, false);
    draw_set_color(_col_team);
    draw_roundrect_ext(_x1, _y1, _x2, _y2, 28, 28, true);
    draw_roundrect_ext(_x1 + 1, _y1 + 1, _x2 - 1, _y2 - 1, 27, 27, true);

    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_font(fnt_menu);

    // Título
    draw_set_color(c_black);
    draw_text_transformed(_cx + 3, _y1 + 70 + 3, abandono_titulo, 2 * _pulse, 2 * _pulse, 0);
    draw_set_color(_col);
    draw_text_transformed(_cx, _y1 + 70, abandono_titulo, 2 * _pulse, 2 * _pulse, 0);

    // Motivo
    draw_set_color(c_white);
    draw_text_transformed(_cx, _y1 + 135, abandono_texto, 0.9, 0.9, 0);

    // Recompensa (solo si la partida ya había empezado)
    if (abandono_gano) {
        draw_set_color(make_color_rgb(255, 235, 59));
        draw_text_transformed(_cx - 80, _y1 + 185, "+25 TROFEOS", 0.9, 0.9, 0);
        draw_set_color(make_color_rgb(76, 175, 80));
        draw_text_transformed(_cx + 110, _y1 + 185, "+50 XP", 0.9, 0.9, 0);
    }

    // Barra de cuenta regresiva
    var _p   = clamp(abandono_timer / abandono_total, 0, 1);
    var _bx1 = _x1 + 60, _bx2 = _x2 - 60, _by = _y2 - 55;
    draw_set_color(make_color_rgb(50, 50, 60));
    draw_roundrect_ext(_bx1, _by, _bx2, _by + 8, 8, 8, false);
    draw_set_color(_col_team);
    draw_roundrect_ext(_bx1, _by, _bx1 + (_bx2 - _bx1) * _p, _by + 8, 8, 8, false);

    draw_set_font(fnt_small);
    draw_set_color(c_ltgray);
    draw_text(_cx, _y2 - 25, "Volviendo al menu en " + string(ceil(abandono_timer / room_speed)) + "...   [ENTER] salir ya");

    // Reset
    draw_set_alpha(1);
    draw_set_color(c_white);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}
	
// --- DIBUJO DE MENSAJES DE ESTADO (Ponlo al final de todo el código) ---
if (mensaje_alpha > 0) {
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_font(fnt_menu);
    
    // Sombra
    draw_set_color(c_black);
    draw_set_alpha(mensaje_alpha);
    draw_text(display_get_gui_width()/2 + 2, display_get_gui_height() - 100 + 2, mensaje_texto);
    
    // Texto
    draw_set_color(c_white);
    draw_text(display_get_gui_width()/2, display_get_gui_height() - 100, mensaje_texto);
    
    mensaje_alpha -= 0.02; // Para que se vaya desvaneciendo
}
draw_set_alpha(1);


