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
#region --- TARJETA JUGADOR LOCAL (solo en el menú; en la partida tu nombre va arriba, con tu vida) ---
if (room == rm_menu) {
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
}
#endregion

#region // PING HUD (en la partida: chiquito abajo al centro)
opt_init();
if (global.ONLINE && (room == rm_menu || global.opt.ping == 1)) scr_red_draw_hud(room != rm_menu);
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

// Jugadores fuera de pantalla: burbuja con cara, anillo de vida y metros (scr_feedback).
// Reemplaza las flechitas viejas.
fb_indicadores();
#endregion

#region // Textos de kill (a la derecha, debajo del arma: arriba a la izquierda van tu nombre y tu vida)
draw_set_valign(fa_top);
draw_set_halign(fa_right);

var line_h = 22;                  
var line_step = line_h * scale; 
var _kf_x = display_get_gui_width() - 20;
var _kf_y = 200;

for (var i = 0; i < array_length(kill_feed); i++)
{
    var it = kill_feed[i];

    var dx = _kf_x - it.xoff;
    var dy = _kf_y + i * line_step + it.yoff;

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
draw_set_halign(fa_left);
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

#region // --- TARJETA RIVAL ---
// Ya no se dibuja: abajo a la derecha queda debajo del joystick en el celular,
// y solo mostraba a un rival. Los nombres ya salen encima de cada jugador.
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

    if (room != rm_menu) {
        // Marcador vivo, flechas, banners, anotacion y avisos (scr_feedback).
        // Ahora funciona tanto en linea como en local.
        fb_draw_marcador(_mx_base, 14);
        fb_draw_gui();
        minimapa_draw(); // mini mapa (se apaga o cambia en AJUSTES)
    } else {

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

    // Reloj de la partida, debajo del marcador (solo en línea y con límite de tiempo)
    if (room != rm_menu) scr_reloj_draw(_mx_base, _my_base + 52);
    } // fin del marcador viejo (solo rm_menu)
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
    
    var opciones_actuales = (global.ONLINE) ? ["CONTINUAR", "ABANDONAR PARTIDA"] : (global.bot_partida ? ["CONTINUAR", "SALIR AL MENU"] : ["CONTINUAR", "REINICIAR", "SALIR AL MENU"]);
    
    for (var i = 0; i < array_length(opciones_actuales); i++) {
        var color = (pause_index == i) ? c_yellow : c_white;
        var escala = (pause_index == i) ? 1.2 : 1.0;
        var texto = (pause_index == i) ? "> " + opciones_actuales[i] + " <" : opciones_actuales[i];
        draw_set_color(color);
        draw_text_transformed(mid_x, mid_y + (i * 50), texto, escala, escala, 0);
    }
}

// --- 4. PANTALLA DE RESULTADOS (diseno A: GANASTE / PERDISTE, marcador, equipos, premio) ---
if (global.game_over && !abandono_activo)
{
    var gw = display_get_gui_width();
    var gh = display_get_gui_height();
    var mid_x = gw / 2;
    var mid_y = gh / 2;
    var pulse = 1 + sin(get_timer() / 200000) * 0.04;

    var _azul_c = make_color_rgb(61, 157, 240);
    var _rojo_c = make_color_rgb(229, 72, 77);
    var _oro_c  = make_color_rgb(242, 182, 50);
    var _gris_c = make_color_rgb(138, 143, 163);
    var _verde_c = make_color_rgb(79, 194, 122);

    var _mi_eq   = scr_my_team();                                   // "AZUL" o "ROJO"
    var _gana_eq = (global.winner_team == 1) ? "ROJO" : "AZUL";
    var _gane    = (_mi_eq == _gana_eq);
    var _col_ganador = (_gana_eq == "ROJO") ? _rojo_c : _azul_c;
    var _en_linea = global.ONLINE;
    var _con_bots = global.bot_partida || (variable_global_exists("botnet_partida") && global.botnet_partida);

    // Quienes jugaron (solo en linea): yo y los demas, por equipo
    var _l_az = [];
    var _l_ro = [];
    if (_en_linea) {
        var _yo = [global.myName, 1];
        if (_mi_eq == "ROJO") array_push(_l_ro, _yo); else array_push(_l_az, _yo);
        with (oOtherPlayer) {
            var _tm = (team != "") ? team : lobby_team;
            var _it = [string(Name), es_bot ? 2 : 0];
            if (_tm == "ROJO") array_push(_l_ro, _it); else array_push(_l_az, _it);
        }
    }
    var _filas = max(array_length(_l_az), array_length(_l_ro));

    // Medidas del panel (crece con las listas de equipos)
    var p_w = 600;
    var _con_premio = global.bot_partida || (_en_linea && !scr_fin_es_privada());   // en sala privada no hay premio
    var p_h = 400 + (_en_linea ? 44 + _filas * 26 : 0) + (_con_premio ? 46 : 0);
    var p_y1 = mid_y - p_h / 2;

    // Fondo oscuro
    draw_set_alpha(victory_alpha * 0.8);
    draw_set_color(c_black);
    draw_rectangle(0, 0, gw, gh, false);

    // Panel con sombra y borde del color del equipo que gano
    draw_set_alpha(victory_alpha);
    draw_set_color(c_black);
    draw_roundrect_ext(mid_x - p_w/2 + 10, p_y1 + 10, mid_x + p_w/2 + 10, p_y1 + p_h + 10, 30, 30, false);
    draw_set_color(make_color_rgb(26, 30, 43));
    draw_roundrect_ext(mid_x - p_w/2, p_y1, mid_x + p_w/2, p_y1 + p_h, 30, 30, false);
    draw_set_color(_col_ganador);
    draw_roundrect_ext(mid_x - p_w/2, p_y1, mid_x + p_w/2, p_y1 + p_h, 30, 30, true);
    draw_roundrect_ext(mid_x - p_w/2 + 1, p_y1 + 1, mid_x + p_w/2 - 1, p_y1 + p_h - 1, 29, 29, true);

    // Particulas
    for (var p = 0; p < 8; p++) {
        var angle = (get_timer() / 5000 + (p * 45)) % 360;
        var dist = p_w / 2 + 20 + (sin(get_timer() / 100000) * 14);
        draw_circle_color(mid_x + lengthdir_x(dist, angle), mid_y + lengthdir_y(dist * 0.8, angle), 3 * victory_alpha, _col_ganador, c_white, false);
    }

    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    var _cy = p_y1 + 34;

    // Titulo: lo que te paso a TI, y abajo que equipo gano
    draw_set_font(fnt_small);
    draw_set_color(_gris_c);
    draw_text_transformed(mid_x, _cy, "FIN DE LA PARTIDA", 0.75, 0.75, 0);
    _cy += 52;
    draw_set_font(fnt_menu);
    draw_set_color(c_black);
    draw_text_transformed(mid_x + 3, _cy + 3, _gane ? "GANASTE!" : "PERDISTE", 2.4 * pulse, 2.4 * pulse, 0);
    draw_set_color(_gane ? _oro_c : make_color_rgb(207, 211, 224));
    draw_text_transformed(mid_x, _cy, _gane ? "GANASTE!" : "PERDISTE", 2.4 * pulse, 2.4 * pulse, 0);
    _cy += 52;
    draw_set_font(fnt_small);
    draw_set_color(_col_ganador);
    draw_text_transformed(mid_x, _cy, "VICTORIA " + _gana_eq, 1, 1, 0);

    // Marcador: tus banderas a cada lado y el numero en medio
    _cy += 64;
    var _nb = clamp(scr_banderas_para_ganar(), 1, 10);
    var _sp = min(44, 210 / _nb);
    var _esc = (_nb > 5) ? 0.8 : 1.0;
    for (var i = 0; i < _nb; i++) {
        var _bxa = mid_x - 70 - (_nb - 1 - i) * _sp - _sp / 2;
        var _bxr = mid_x + 70 + i * _sp + _sp / 2;
        if (global.puntos_azul > i) draw_sprite_ext(spr_flag_blue, 0, _bxa, _cy, 1.1 * _esc, 1.1 * _esc, 0, c_white, victory_alpha);
        else draw_sprite_ext(spr_flagvacia, 0, _bxa, _cy, _esc, _esc, 0, c_white, victory_alpha * 0.25);
        if (global.puntos_rojo > i) draw_sprite_ext(spr_flag_red, 0, _bxr, _cy, 1.1 * _esc, 1.1 * _esc, 0, c_white, victory_alpha);
        else draw_sprite_ext(spr_flagvacia, 0, _bxr, _cy, _esc, _esc, 0, c_white, victory_alpha * 0.25);
    }
    draw_set_font(fnt_menu);
    draw_set_color(_azul_c);
    draw_text_transformed(mid_x - 30, _cy, string(global.puntos_azul), 1.8, 1.8, 0);
    draw_set_color(_gris_c);
    draw_text_transformed(mid_x, _cy, "-", 1.6, 1.6, 0);
    draw_set_color(_rojo_c);
    draw_text_transformed(mid_x + 30, _cy, string(global.puntos_rojo), 1.8, 1.8, 0);
    _cy += 48;

    // Equipos (en linea): tu en dorado, los bots en gris
    if (_en_linea) {
        var _cols = [[_l_az, _azul_c, "EQUIPO AZUL", mid_x - 140], [_l_ro, _rojo_c, "EQUIPO ROJO", mid_x + 140]];
        for (var t = 0; t < 2; t++) {
            var _c = _cols[t];
            draw_set_color(_c[1]);
            draw_rectangle(_c[3] - 110, _cy - 2, _c[3] + 110, _cy, false);
            draw_set_font(fnt_small);
            draw_text_transformed(_c[3], _cy + 16, _c[2], 0.7, 0.7, 0);
            var _lista = _c[0];
            for (var k = 0; k < array_length(_lista); k++) {
                var _p = _lista[k];
                draw_set_color((_p[1] == 1) ? _oro_c : ((_p[1] == 2) ? c_ltgray : c_white));
                draw_text_transformed(_c[3], _cy + 44 + k * 26, _p[0], 0.8, 0.8, 0);
            }
        }
        _cy += 44 + _filas * 26;
    }

    // Premio (en linea y contra el bot de partida rapida). Con bots es menos.
    if (_con_premio && victory_alpha > 0.8) {
        _cy += 20;
        var _t1, _t2, _c1;
        if (_gane) { _t1 = _con_bots ? "+10 TROFEOS" : "+25 TROFEOS"; _t2 = _con_bots ? "+20 XP" : "+50 XP"; _c1 = _oro_c; }
        else       { _t1 = _con_bots ? "-5 TROFEOS"  : "-15 TROFEOS"; _t2 = "+5 XP"; _c1 = _rojo_c; }
        draw_set_font(fnt_menu);
        draw_set_color(_c1);
        draw_text_transformed(mid_x - 90, _cy, _t1, 0.85 * (_gane ? pulse : 1), 0.85 * (_gane ? pulse : 1), 0);
        draw_set_color(_gris_c);
        draw_text_transformed(mid_x, _cy, "|", 0.85, 0.85, 0);
        draw_set_color(_verde_c);
        draw_text_transformed(mid_x + 80, _cy, _t2, 0.85, 0.85, 0);
        if (_en_linea && global.botnet_partida) {
            draw_set_font(fnt_small);
            draw_set_color(_gris_c);
            draw_text_transformed(mid_x, _cy + 26, "PARTIDA CON BOTS", 0.6, 0.6, 0);
        }
        _cy += 26;
    }

    // Botones (cambian segun el modo: scr_fin_opciones)
    if (victory_alpha >= 0.9) {
        var opciones_vic = scr_fin_opciones();
        var btn_w = 230;
        var btn_h = 50;
        var total_btns = array_length(opciones_vic);
        var separation = 26;
        var total_w = (total_btns * btn_w) + ((total_btns - 1) * separation);
        var btn_start_x = mid_x - total_w / 2;
        var by = p_y1 + p_h - 80;

        for (var i = 0; i < total_btns; i++) {
            var bx = btn_start_x + (i * (btn_w + separation));
            var is_selected = (victory_index == i);
            var _bc = is_selected ? _oro_c : make_color_rgb(74, 80, 104);
            ctf_ui_para(bx, by, btn_w, btn_h, 10, make_color_rgb(23, 27, 40), 1, false);
            ctf_ui_para(bx, by, btn_w, btn_h, 10, _bc, 1, true);
            ctf_ui_para(bx + 1, by + 1, btn_w - 2, btn_h - 2, 10, _bc, 0.5, true);
            draw_set_font(fnt_small);
            draw_set_color(is_selected ? _oro_c : make_color_rgb(207, 211, 224));
            var b_scale = is_selected ? 1.05 : 1.0;
            draw_text_transformed(bx + btn_w / 2, by + btn_h / 2, opciones_vic[i], b_scale, b_scale, 0);
        }
    }
}

// Resets
draw_set_alpha(1);
draw_set_halign(fa_left);
draw_set_valign(fa_top);




if (!intro_disparada && room != rm_menu && (global.ONLINE == true || global.bot_partida)) {
    var sw = display_get_gui_width();
    var sh = display_get_gui_height();
    var _yo = scr_my_team();   // mi equipo desde que entro a la sala (antes salía vacío y todo se veía rojo)

    // 1. FONDO CON GRADIENTE
    draw_set_alpha(0.9);
    draw_rectangle_color(0, 0, sw, sh, c_black, c_black, make_color_rgb(10, 30, 50), make_color_rgb(10, 30, 50), false);
    draw_set_alpha(1);

    // 2. TÍTULO Y CRONÓMETRO
    draw_set_font(fnt_menu);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    var segs = ceil(timer_intro / 60);
    draw_text_transformed_color(sw/2 + 3, 40 + 3, "ELIGE TU PERSONAJE", 1.8, 1.8, 0, c_black, c_black, c_black, c_black, 1);
    draw_text_transformed_color(sw/2, 40, "ELIGE TU PERSONAJE", 1.8, 1.8, 0, c_white, c_white, c_white, c_white, 1);
    draw_text_transformed_color(sw/2, 84, string(segs), 1.3, 1.3, 0, c_yellow, c_yellow, c_orange, c_orange, 1);

    // 3. ¿QUIÉN VA EN CADA EQUIPO?
    var _az = [];   // cada uno: [pj, nombre, listo, soy_yo]
    var _ro = [];
    var _mine = [global.pj_selected, global.myName, global.mi_listo, true];
    if (_yo == "AZUL") array_push(_az, _mine); else array_push(_ro, _mine);
    with (oOtherPlayer) {
        var _pj  = variable_instance_exists(id, "mySelectedPJ") ? mySelectedPJ : 0;
        var _rdy = variable_instance_exists(id, "isReady") ? isReady : false;
        var _it  = [_pj, Name, _rdy, false];
        var _tm  = (variable_instance_exists(id, "lobby_team") && lobby_team != "") ? lobby_team : team;
        if (_tm == "AZUL") array_push(_az, _it); else array_push(_ro, _it);
    }
    // Contra el bot: el rival sale como un jugador más
    if (global.bot_partida) {
        var _bt = [global.bot_pj_vista, global.bot_nombre, global.bot_listo, false];
        if (_yo == "AZUL") array_push(_ro, _bt); else array_push(_az, _bt);
    }

    // 4. DOS COLUMNAS CON SU LETRERO
    var box_w = 220;
    var box_h = 360;
    var _cy = 140 + 20 + box_h / 2 + 10;
    for (var _t = 0; _t < 2; _t++) {
        var _list = (_t == 0) ? _az : _ro;
        var _team = (_t == 0) ? "AZUL" : "ROJO";
        var _colx = (_t == 0) ? sw * 0.25 : sw * 0.75;
        var _col  = scr_team_color(_team);

        // letrero
        draw_set_alpha(0.95);
        draw_rectangle_color(_colx - 260, 102, _colx + 260, 140, _col, _col, merge_color(_col, c_black, 0.4), merge_color(_col, c_black, 0.4), false);
        draw_set_alpha(1);
        draw_text_transformed_color(_colx + 3, 121 + 3, "EQUIPO " + _team, 1.3, 1.3, 0, c_black, c_black, c_black, c_black, 1);
        draw_text_transformed_color(_colx, 121, "EQUIPO " + _team, 1.3, 1.3, 0, c_white, c_white, c_white, c_white, 1);

        // cuadros, uno al lado del otro
        var _n = array_length(_list);
        for (var k = 0; k < _n; k++) {
            var _it2 = _list[k];
            var _sx = _colx + (k - (_n - 1) / 2) * (box_w + 26);
            draw_bomb_slot(_sx, _cy, _it2[0], _it2[1], _it2[2], _it2[3], _team, box_w, box_h);
        }
    }

    // VS en el medio
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_text_transformed_color(sw/2 + 4, _cy + 4, "VS", 2.6, 2.6, 0, c_black, c_black, c_black, c_black, 1);
    draw_text_transformed_color(sw/2, _cy, "VS", 2.6, 2.6, 0, c_white, c_white, c_white, c_white, 1);

    // 5. EL OBJETIVO, SIEMPRE A LA VISTA
    var _rival = (_yo == "AZUL") ? "ROJO" : "AZUL";
    var _gy = sh - 90;
    draw_set_alpha(0.65);
    draw_set_colour(c_black);
    draw_roundrect_ext(40, _gy - 40, sw - 40, _gy + 40, 12, 12, false);
    draw_set_alpha(1);
    var _flag_r = (_rival == "ROJO") ? spr_flag_red_big : spr_flag_blue_big;
    var _txt = "ROBA LA BANDERA " + _rival + "   >   LLEVALA A TU BASE " + _yo + "   >   PRIMERO EN 3 GANA";
    draw_sprite_ext(_flag_r, 0, sw/2 - string_width(_txt) * 0.5 - 30, _gy, 2, 2, 0, c_white, 1);
    draw_text_transformed_color(sw/2, _gy, _txt, 1, 1, 0, c_yellow, c_yellow, c_white, c_white, 1);

    // ayuda de controles
    var _ayuda = touch_mode() ? "FLECHAS: cambiar personaje   -   OK: listo" : "ARRIBA / ABAJO: cambiar personaje   -   ENTER: listo";
    draw_text_transformed_color(sw/2, sh - 28, _ayuda, 0.7, 0.7, 0, c_ltgray, c_ltgray, c_ltgray, c_ltgray, 1);

    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_colour(c_white);
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

// --- AVISO DE RED: pantalla de sin conexión y aviso de recuperada (encima de todo) ---
scr_red_draw_overlay();
