/// @description Dibujar la intro
var gw = display_get_gui_width();
var gh = display_get_gui_height();
var _ease = function(_v) { _v = clamp(_v, 0, 1); return 1 - power(1 - _v, 3); };

// --- Barras de cine ---
var _bar = _ease(t / 18);
if (t > T_FIN - 20) _bar = _ease((T_FIN - t) / 20);
draw_set_alpha(0.4 * _bar);
draw_set_colour(c_black);
draw_rectangle(0, 0, gw, gh, false);
draw_set_alpha(1);
draw_rectangle(0, 0, gw, 110 * _bar, false);
draw_rectangle(0, gh - 110 * _bar, gw, gh, false);

draw_set_font(fnt_intro);
draw_set_valign(fa_middle);

// --- Los dos equipos ---
var _in  = _ease(t / T_ENTRA);
var _out = _ease((t - T_SALEN) / 22);
var _k   = _in - _out;   // 0 fuera, 1 en su lugar

for (var _s = 0; _s < 2; _s++) {
    var _team = (_s == 0) ? "AZUL" : "ROJO";
    var _list = (_s == 0) ? lista_azul : lista_rojo;
    var _col  = scr_team_color(_team);
    var _left = (_s == 0);
    var _pw   = gw * 0.46;
    var _x0   = _left ? lerp(-_pw, 0, _k) : lerp(gw, gw - _pw, _k);

    // panel de color que se desvanece hacia el centro
    draw_set_alpha(0.85 * _k);
    if (_left) draw_rectangle_color(_x0, 140, _x0 + _pw, gh - 140, _col, c_black, c_black, _col, false);
    else       draw_rectangle_color(_x0, 140, _x0 + _pw, gh - 140, c_black, _col, _col, c_black, false);
    draw_set_alpha(_k);

    // título del equipo
    var _tx = _left ? _x0 + 60 : _x0 + _pw - 60;
    draw_set_halign(_left ? fa_left : fa_right);
    var _titulo = "EQUIPO " + _team;
    if (_team == mi_equipo) _titulo = _left ? _titulo + "  (TU EQUIPO)" : "(TU EQUIPO)  " + _titulo;
    if (scr_modo_todos()) _titulo = "TODOS CONTRA TODOS";
    if (scr_modo_jefe()) _titulo = _left ? "TU EQUIPO" : "EL JEFE";   // JEFE GIGANTE (scr_reloj)
    draw_text_transformed_color(_tx + 3, 175 + 3, _titulo, 1.2, 1.2, 0, c_black, c_black, c_black, c_black, _k);
    draw_text_transformed_color(_tx, 175, _titulo, 1.2, 1.2, 0, c_white, c_white, c_white, c_white, _k);

    // cada jugador: cara + nombre
    var _n = array_length(_list);
    var _alto = min(150, (gh - 400) / max(1, _n));
    for (var i = 0; i < _n; i++) {
        var _p  = _list[i];
        var _cy = 225 + _alto / 2 + i * (_alto + 14);
        var _fw = _alto * 0.8;
        var _fx = _left ? _tx : _tx - _fw;
        // cara: la parte de arriba del retrato
        if (_p.pj >= 0 && _p.pj < array_length(global.pj_portraits)) {
            var _spr = global.pj_portraits[_p.pj];
            var _sw  = sprite_get_width(_spr);
            var _cw  = _sw * 0.6;
            var _ch  = _cw * (_alto / _fw);
            var _sc  = _fw / _cw;
            draw_set_colour(c_black);
            draw_rectangle(_fx - 4, _cy - _alto/2 - 4, _fx + _fw + 4, _cy + _alto/2 + 4, false);
            draw_sprite_part_ext(_spr, 0, _sw * 0.2, 0, _cw, _ch, _fx, _cy - _alto/2, _sc, _sc, c_white, _k);
            draw_set_colour(c_white);
            draw_rectangle(_fx - 4, _cy - _alto/2 - 4, _fx + _fw + 4, _cy + _alto/2 + 4, true);
        }
        var _nx = _left ? _fx + _fw + 24 : _fx - 24;
        var _esc = (string_length(_p.n) > 10) ? 1.4 : 1.9;
        draw_text_transformed_color(_nx + 4, _cy + 4, string_upper(_p.n), _esc, _esc, 0, c_black, c_black, c_black, c_black, _k);
        draw_text_transformed_color(_nx, _cy, string_upper(_p.n), _esc, _esc, 0, c_white, c_white, _col, _col, _k);
    }
}
draw_set_alpha(1);

// --- VS ---
draw_set_halign(fa_center);
if (t > 26 && t < T_SALEN + 20) {
    var _v = (t - 26) / 14;
    var _vs = (t < 40) ? lerp(7, 3.2, _ease(_v)) : 3.2 + sin(t * 0.15) * 0.08;
    var _va = (t > T_SALEN) ? 1 - _ease((t - T_SALEN) / 20) : min(1, _v * 2);
    if (t > T_SALEN) _vs *= (1 - _ease((t - T_SALEN) / 20) * 0.8);
    draw_text_transformed_color(gw/2 + 6, gh/2 + 6, "VS", _vs, _vs, 0, c_black, c_black, c_black, c_black, _va);
    draw_text_transformed_color(gw/2, gh/2, "VS", _vs, _vs, 0, c_white, c_white, c_white, c_white, _va);
}

// --- La misión ---
if (t > T_MISION) {
    var _ma = min(1, (t - T_MISION) / 20);
    if (t > T_FIN - 30) _ma = (T_FIN - t) / 30;
    var _my = gh/2 + (1 - _ease((t - T_MISION) / 20)) * 30;
    var _rival = (mi_equipo == "AZUL") ? "ROJO" : "AZUL";
    var _cr = scr_team_color(_rival);
    var _cm = scr_team_color(mi_equipo);

    draw_text_transformed_color(gw/2 + 3, _my - 110 + 3, "TU MISION", 1.1, 1.1, 0, c_black, c_black, c_black, c_black, _ma);
    draw_text_transformed_color(gw/2, _my - 110, "TU MISION", 1.1, 1.1, 0, c_yellow, c_yellow, c_orange, c_orange, _ma);

    // La mision segun el modo (scr_reloj)
    var _ml = scr_mision_lineas(_rival, mi_equipo);
    var _l1 = _ml[0];
    var _l2 = _ml[1];
    draw_text_transformed_color(gw/2 + 5, _my - 35 + 5, _l1, 2.2, 2.2, 0, c_black, c_black, c_black, c_black, _ma);
    draw_text_transformed_color(gw/2, _my - 35, _l1, 2.2, 2.2, 0, c_white, c_white, _cr, _cr, _ma);
    draw_text_transformed_color(gw/2 + 5, _my + 40 + 5, _l2, 2.2, 2.2, 0, c_black, c_black, c_black, c_black, _ma);
    draw_text_transformed_color(gw/2, _my + 40, _l2, 2.2, 2.2, 0, c_white, c_white, _cm, _cm, _ma);

    if (_ml[3]) {
        var _fl = (_rival == "ROJO") ? spr_flag_red_big : spr_flag_blue_big;
        var _fx2 = gw/2 + string_width(_l1) * 1.1 + 40;
        draw_sprite_ext(_fl, 0, _fx2, _my - 40, 3, 3, 0, c_white, _ma);
    }

    draw_text_transformed_color(gw/2 + 3, _my + 115 + 3, _ml[2], 1.1, 1.1, 0, c_black, c_black, c_black, c_black, _ma);
    draw_text_transformed_color(gw/2, _my + 115, _ml[2], 1.1, 1.1, 0, c_white, c_white, c_white, c_white, _ma);
}

draw_set_alpha(1);
draw_set_colour(c_white);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
