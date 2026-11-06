
// Botones que se pueden tocar/clickear este frame (los lee el Step)
global.ui_taps = [];

// 1. OBTENER EL CENTRO REAL DE LA PANTALLA (Indispensable para centrar)
var gui_w = display_get_gui_width();
var gui_h = display_get_gui_height();
var cx = gui_w / 2;
var cy = gui_h / 2;
var spacing = 60;

// Configuración inicial de dibujo
draw_set_font(fnt_menu);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);

draw_text(200,200,string(global.ultimo_rival_tag));

if (global.registrado == 0) {
    if (input_activo) global.myName = texto_input;

    // USAMOS SIEMPRE GUI PARA QUE NO SE DESPLACE
    var gui_w = display_get_gui_width();
    var gui_h = display_get_gui_height();
    var _ru = clamp(min(gui_w / 1280, gui_h / 720), 0.6, 1.6);

    var mid_x = gui_w / 2;
    var mid_y = gui_h / 2 - 150; // (misma posicion de siempre para que el clic no cambie)

    ctf_ui_fondo(gui_w, gui_h);
    ctf_ui_header(gui_w, "CAPTURE THE FLAG", "A R E N A   E D I T I O N", _ru);

    // Etiqueta
    draw_set_font(fnt_small);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_color(make_color_rgb(169, 180, 208));
    draw_set_alpha(0.55);
    draw_text_transformed(mid_x, mid_y - 48, "ESCRIBE TU NOMBRE", 0.65, 0.65, 0);
    draw_set_alpha(1);

    // 1. Cuadro del nombre
    var _bcol = input_activo ? make_color_rgb(31, 155, 255) : make_color_rgb(169, 180, 208);
    ctf_ui_para(mid_x - 200, mid_y - 30, 400, 60, 12, make_color_rgb(11, 15, 26), 0.92, false);
    ctf_ui_para(mid_x - 200, mid_y - 30, 400, 60, 12, _bcol, input_activo ? 1 : 0.35, true);

    // 2. Texto del nombre
    draw_set_font(fnt_menu);
    draw_set_color(c_white);
    var display_text = texto_input;
    cursor_timer++;
    if (input_activo && (cursor_timer mod 40 < 20)) {
        display_text += "|";
    }
    draw_text_transformed(mid_x, mid_y, display_text, 1.2, 1.2, 0);

    // 3. Instruccion abajo
    draw_set_font(fnt_small);
    draw_set_color(make_color_rgb(255, 212, 71));
    draw_text_transformed(mid_x, mid_y + 70, "PRESIONA ENTER PARA ENTRAR A LA BATALLA", 0.7, 0.7, 0);
    draw_set_font(fnt_menu);
}


// AL PURO INICIO DEL DRAW GUI
if (room == rm_menu) {
    if (!global.registrado) exit; 
    
}

// ==========================================
// LÓGICA DE DIBUJO DE MENÚS (MAIN vs PRIVATE)
// ==========================================
var gui_w = display_get_gui_width();
var gui_h = display_get_gui_height();
var spacing = 60;


// Colores y escala para todas las pantallas del menu
var ui_u     = clamp(min(gui_w / 1280, gui_h / 720), 0.6, 1.6);
var ui_tinta = make_color_rgb(11, 15, 26);
var ui_azul  = make_color_rgb(31, 155, 255);
var ui_rojo  = make_color_rgb(255, 42, 58);
var ui_oro   = make_color_rgb(255, 212, 71);
var ui_gris  = make_color_rgb(169, 180, 208);
var ui_verde = make_color_rgb(78, 255, 145);

// --- DIBUJO DEL MENÚ PRINCIPAL (CYBERPUNK, PANTALLA COMPLETA) ---
if (menu_state == "main") {
    var C_TINTA = make_color_rgb(11, 15, 26);
    var C_AZUL  = make_color_rgb(31, 155, 255);
    var C_ROJO  = make_color_rgb(255, 42, 58);
    var C_ORO   = make_color_rgb(255, 212, 71);
    var C_GRIS  = make_color_rgb(169, 180, 208);
    var C_VERDE = make_color_rgb(78, 255, 145);
    var _n = array_length(menu_options);

    // Fondo oscuro en toda la pantalla
    ctf_ui_fondo(gui_w, gui_h);

    // Escala segun la pantalla (PC, Android, HTML5)
    var u = clamp(min(gui_w / 1280, gui_h / 720), 0.6, 1.6);

    draw_set_font(fnt_menu);
    var _th = string_height("A");
    draw_set_font(fnt_small);
    var _sh = string_height("A");

    var hud_h    = 52 * u;
    var flags_h  = 30;
    var title_sc = 1.9;
    var line_h   = _th * title_sc;
    var btn_h    = 46;
    var btn_gap  = 10;
    var btn_w    = 320;
    var block_h  = flags_h + 10 + (line_h * 2) + 8 + (_sh * 0.8) + 14 + 2 + 36 + (_n * btn_h) + ((_n - 1) * btn_gap) + 26 + (_sh * 0.6);
    var avail    = gui_h - hud_h - 30 * u;
    var k        = min(u, avail / block_h, gui_w / 420);
    var ly       = hud_h + 15 * u + max(0, (avail - (block_h * k)) / 2);

    // ── HUD TOP ──
    draw_set_color(c_black); draw_set_alpha(0.45);
    draw_rectangle(0, 0, gui_w, hud_h, false);
    draw_set_color(C_GRIS); draw_set_alpha(0.15);
    draw_line(0, hud_h, gui_w, hud_h);

    draw_set_font(fnt_small);
    draw_set_valign(fa_middle);
    draw_set_halign(fa_left);
    draw_set_color(C_GRIS); draw_set_alpha(0.45);
    draw_text_transformed(20 * u, 17 * u, "SERVIDOR", 0.55 * u, 0.55 * u, 0);
    draw_set_alpha(1); draw_set_color(C_ORO);
    draw_text_transformed(20 * u, 35 * u, "US-EAST-1", 0.75 * u, 0.75 * u, 0);

    // (Se quito el contador de JUGADORES EN LINEA)
    draw_set_alpha(1);

    // ── BANDERAS + VS ──
    var _fy = ly + (flags_h * k) / 2;
    draw_set_color(C_ROJO);
    draw_rectangle(cx - 56 * k, _fy - 14 * k, cx - 53 * k, _fy + 14 * k, false);
    draw_triangle(cx - 53 * k, _fy - 14 * k, cx - 53 * k, _fy + 2 * k, cx - 31 * k, _fy - 6 * k, false);
    draw_set_color(C_AZUL);
    draw_rectangle(cx + 53 * k, _fy - 14 * k, cx + 56 * k, _fy + 14 * k, false);
    draw_triangle(cx + 53 * k, _fy - 14 * k, cx + 53 * k, _fy + 2 * k, cx + 31 * k, _fy - 6 * k, false);
    draw_set_font(fnt_menu);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_color(C_ORO);
    draw_text_transformed(cx, _fy, "VS", 0.55 * k, 0.55 * k, 0);
    ly += (flags_h + 10) * k;

    // ── TITULO con brillo azul ──
    var _t1y = ly + (line_h * k) / 2;
    var _t2y = _t1y + (line_h * k);
    var _tsc = title_sc * k;
    draw_set_color(C_AZUL);
    draw_set_alpha(0.22);
    for (var _o = 0; _o < 4; _o++) {
        var _ox = (_o == 0) ? -3 : ((_o == 1) ? 3 : 0);
        var _oy = (_o == 2) ? -3 : ((_o == 3) ? 3 : 0);
        draw_text_transformed(cx + _ox, _t1y + _oy, "CAPTURE", _tsc, _tsc, 0);
        draw_text_transformed(cx + _ox, _t2y + _oy, "THE FLAG", _tsc, _tsc, 0);
    }
    draw_set_alpha(1);
    draw_set_color(c_white);
    draw_text_transformed(cx, _t1y, "CAPTURE", _tsc, _tsc, 0);
    draw_text_transformed(cx, _t2y, "THE FLAG", _tsc, _tsc, 0);
    ly += (line_h * 2 + 8) * k;

    // ── SUBTITULO ──
    draw_set_font(fnt_small);
    draw_set_color(C_ORO);
    draw_text_transformed(cx, ly + (_sh * 0.8 * k) / 2, "A R E N A   E D I T I O N", 0.8 * k, 0.8 * k, 0);
    ly += (_sh * 0.8 + 14) * k;

    // ── DIVISOR ──
    var _dw = 220 * k;
    var _dsteps = 44;
    for (var _s = 0; _s < _dsteps; _s++) {
        var _t = _s / (_dsteps - 1);
        draw_set_color(merge_colour(C_AZUL, C_ROJO, _t));
        draw_set_alpha(min(1, sin(pi * _t) * 1.6));
        var _sx = cx - _dw / 2 + _t * _dw;
        draw_rectangle(_sx, ly, _sx + (_dw / _dsteps) + 1, ly + 1, false);
    }
    draw_set_alpha(1);
    ly += 2 + 36 * k;

    // ── BOTONES ──
    var _bw = btn_w * k;
    var _bh = btn_h * k;
    var _sk = 10 * k;
    var _bL = cx - _bw / 2;
    var _bR = cx + _bw / 2;
    for (var i = 0; i < _n; i++) {
        var _bT = ly + i * (btn_h + btn_gap) * k;
        var _sel = (i == index);

        ctf_ui_para(_bL, _bT, _bw, _bh, _sk, C_TINTA, 0.85, false);
        if (_sel) ctf_ui_para(_bL, _bT, _bw, _bh, _sk, C_AZUL, 0.12, false);
        ctf_ui_para(_bL, _bT, _bw, _bh, _sk, _sel ? C_AZUL : C_GRIS, _sel ? 1 : 0.22, true);
        if (_sel) ctf_ui_para(_bL, _bT, _sk + 3, _bh, _sk, C_AZUL, 1, false);

        draw_set_font(fnt_menu);
        draw_set_valign(fa_middle);
        draw_set_halign(fa_left);
        draw_set_color(_sel ? C_AZUL : C_GRIS);
        draw_text_transformed(_bL + 28 * k, _bT + _bh / 2, string_upper(menu_options[i]), 0.72 * k, 0.72 * k, 0);
        draw_set_halign(fa_right);
        draw_set_alpha(_sel ? 1 : 0.4);
        draw_text_transformed(_bR - _sk - 18 * k, _bT + _bh / 2, ">", 0.72 * k, 0.72 * k, 0);
        draw_set_alpha(1);
        ui_tap_add(_bL, _bT, _bR, _bT + _bh, i, vk_enter);
    }
    ly += ((_n * btn_h) + ((_n - 1) * btn_gap) + 26) * k;

    // ── FOOTER ──
    draw_set_font(fnt_small);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_color(C_GRIS); draw_set_alpha(0.35);
    draw_text_transformed(cx, ly + (_sh * 0.6 * k) / 2, "v2.1.0  -  RYANGAMES  -  2024", 0.6 * k, 0.6 * k, 0);
    draw_set_alpha(1);

    // ── SOBRE (correo): arriba a la derecha, debajo del HUD ──
    mail_x = gui_w - 70 * u;
    mail_y = hud_h + 55 * u;
    var mx = device_mouse_x_to_gui(0);
    var my = device_mouse_y_to_gui(0);
    var _mhover = (mx > mail_x - 40 && mx < mail_x + 40 && my > mail_y - 40 && my < mail_y + 40);
    var scale = 1.5 * u * (_mhover ? 1.1 : 1);
    draw_sprite_ext(spr_textbox, 0, mail_x, mail_y, scale, scale, 0, c_white, 1);

    if (hay_solicitud_pendiente) {
        var wave = abs(sin(current_time / 200));
        draw_set_color(C_ROJO);
        draw_circle(mail_x + 20 * u, mail_y - 15 * u, (5 + (wave * 2)) * u, false);
    }
    draw_set_font(fnt_small);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_color(C_GRIS); draw_set_alpha(0.7);
    draw_text_transformed(mail_x, mail_y + 34 * u, "[M] CORREO", 0.6 * u, 0.6 * u, 0);
    draw_set_alpha(1);
    draw_set_color(c_white);
}

// --- DIBUJO DEL ESTADO BUZÓN (Capa superior) ---
else if (menu_state == "mailbox") {
    var cx = gui_w / 2;
    var cy = gui_h / 2;

    ctf_ui_fondo(gui_w, gui_h);
    ctf_ui_header(gui_w, "BUZON", "MENSAJES Y SOLICITUDES", ui_u);

    var _pw = 560 * ui_u;
    var _ph = 210 * ui_u;
    ctf_ui_panel(cx - _pw / 2, cy - _ph / 2, cx + _pw / 2, cy + _ph / 2, ui_azul);

    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    if (hay_solicitud_pendiente && is_struct(datos_solicitud_recibida)) {
        draw_set_font(fnt_small);
        draw_set_color(ui_gris); draw_set_alpha(0.55);
        draw_text_transformed(cx, cy - 55 * ui_u, "SOLICITUD DE AMISTAD DE", 0.6 * ui_u, 0.6 * ui_u, 0);
        draw_set_alpha(1);
        draw_set_font(fnt_menu);
        draw_set_color(c_white);
        draw_text_transformed(cx, cy - 15 * ui_u, string_upper(string(datos_solicitud_recibida.desde_nombre)), 1.0 * ui_u, 1.0 * ui_u, 0);
        draw_set_font(fnt_small);
        var _yw = 160 * ui_u; var _yh = 40 * ui_u; var _yy = cy + 50 * ui_u - _yh / 2;
        ctf_ui_para(cx - 95 * ui_u - _yw / 2, _yy, _yw, _yh, 8 * ui_u, ui_verde, 0.1, false);
        ctf_ui_para(cx - 95 * ui_u - _yw / 2, _yy, _yw, _yh, 8 * ui_u, ui_verde, 0.6, true);
        ctf_ui_para(cx + 95 * ui_u - _yw / 2, _yy, _yw, _yh, 8 * ui_u, ui_rojo, 0.1, false);
        ctf_ui_para(cx + 95 * ui_u - _yw / 2, _yy, _yw, _yh, 8 * ui_u, ui_rojo, 0.6, true);
        draw_set_color(ui_verde);
        draw_text_transformed(cx - 95 * ui_u, cy + 50 * ui_u, touch_mode() ? "ACEPTAR" : "[Y] ACEPTAR", 0.7 * ui_u, 0.7 * ui_u, 0);
        draw_set_color(ui_rojo);
        draw_text_transformed(cx + 95 * ui_u, cy + 50 * ui_u, touch_mode() ? "RECHAZAR" : "[N] RECHAZAR", 0.7 * ui_u, 0.7 * ui_u, 0);
        ui_tap_add(cx - 95 * ui_u - _yw / 2, _yy, cx - 95 * ui_u + _yw / 2, _yy + _yh, -1, ord("Y"));
        ui_tap_add(cx + 95 * ui_u - _yw / 2, _yy, cx + 95 * ui_u + _yw / 2, _yy + _yh, -1, ord("N"));
    } else {
        draw_set_font(fnt_menu);
        draw_set_color(ui_gris); draw_set_alpha(0.5);
        draw_text_transformed(cx, cy, "NO HAY MENSAJES NUEVOS", 0.8 * ui_u, 0.8 * ui_u, 0);
        draw_set_alpha(1);
    }

    ctf_ui_hint(cx, cy + _ph / 2 + 40 * ui_u, "[ESC] VOLVER", ui_u);
}
else if (menu_state == "private") {
    ctf_ui_fondo(gui_w, gui_h);
    var _hy = ctf_ui_header(gui_w, "LOBBY PRIVADO", "CREA O UNETE A UNA SALA", ui_u);
    var _tot = array_length(private_options) * 56 * ui_u;
    ctf_ui_lista(gui_w / 2, max(_hy + 20 * ui_u, gui_h / 2 - _tot / 2), private_options, p_index, ui_u);
    ctf_ui_hint(gui_w / 2, gui_h - 40 * ui_u, "[W/S] ELEGIR     [ENTER] ACEPTAR     [ESC] VOLVER", ui_u);
}

else if (menu_state == "join_code") {
    var cx = gui_w / 2;
    var cy = gui_h / 2;
    ctf_ui_fondo(gui_w, gui_h);
    ctf_ui_header(gui_w, "UNIRSE A SALA", "ESCRIBE EL CODIGO QUE TE PASARON", ui_u);

    var _iw = 520 * ui_u; var _ih = 64 * ui_u;
    var _ix = cx - _iw / 2; var _iy = cy - _ih / 2 - 20 * ui_u;
    ctf_ui_para(_ix, _iy, _iw, _ih, 12 * ui_u, ui_tinta, 0.92, false);
    ctf_ui_para(_ix, _iy, _iw, _ih, 12 * ui_u, input_activo ? ui_azul : ui_gris, input_activo ? 1 : 0.35, true);
    draw_set_font(fnt_menu);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_color(ui_oro);
    var _cur = (input_activo && (current_time mod 1000 < 500)) ? "|" : "";
    draw_text_transformed(cx, _iy + _ih / 2, join_input + _cur, 1.0 * ui_u, 1.0 * ui_u, 0);

    // Boton UNIRME
    var _jw = 240 * ui_u; var _jh = 48 * ui_u; var _jy = _iy + _ih + 30 * ui_u;
    var _ok = (join_input != "");
    ctf_ui_para(cx - _jw / 2, _jy, _jw, _jh, 10 * ui_u, ui_tinta, 0.9, false);
    ctf_ui_para(cx - _jw / 2, _jy, _jw, _jh, 10 * ui_u, ui_azul, _ok ? 0.15 : 0.03, false);
    ctf_ui_para(cx - _jw / 2, _jy, _jw, _jh, 10 * ui_u, _ok ? ui_azul : ui_gris, _ok ? 1 : 0.3, true);
    draw_set_color(_ok ? ui_azul : ui_gris);
    draw_text_transformed(cx, _jy + _jh / 2, "UNIRME", 0.8 * ui_u, 0.8 * ui_u, 0);
    ui_tap_add(cx - _jw / 2, _jy, cx + _jw / 2, _jy + _jh, -1, vk_enter);

    // Tocar el cuadro vuelve a abrir el teclado del celular
    ui_tap_add(_ix, _iy, _ix + _iw, _iy + _ih, -1, -1);
    if (touch_mode() && device_mouse_check_button_pressed(0, mb_left) && point_in_rectangle(device_mouse_x_to_gui(0), device_mouse_y_to_gui(0), _ix, _iy, _ix + _iw, _iy + _ih)) {
        input_activo = true;
        keyboard_virtual_show(kbv_type_default, kbv_returnkey_go, kbv_autocapitalize_characters, false);
    }

    ctf_ui_hint(cx, gui_h - 40 * ui_u, "[ENTER] UNIRME     [ESC] VOLVER", ui_u);
}

else if (menu_state == "options") {
    // ===== AJUSTES =====
    ctf_ui_fondo(gui_w, gui_h);
    var _hy = ctf_ui_header(gui_w, "AJUSTES", "SE GUARDAN SOLOS EN ESTE APARATO", ui_u);
    var _of = opt_filas();
    var _cw  = min(520 * ui_u, (gui_w - 90 * ui_u) / 2);
    var _cg  = 30 * ui_u;
    var _cx0 = gui_w / 2 - _cw - _cg / 2;
    var _cx1 = gui_w / 2 + _cg / 2;
    var _rh  = 54 * ui_u;
    var _rg  = 8 * ui_u;
    var _sech = 36 * ui_u;
    var _oy  = [_hy, _hy];
    for (var i = 0; i < array_length(_of); i++) {
        var _r = _of[i];
        var _c = _r.col;
        var _X = (_c == 0) ? _cx0 : _cx1;

        // Titulo de seccion
        if (variable_struct_exists(_r, "sec")) {
            draw_set_colour(ui_azul);
            draw_rectangle(_X, _oy[_c] + 8 * ui_u, _X + 2, _oy[_c] + 20 * ui_u, false);
            draw_set_font(fnt_small);
            draw_set_halign(fa_left);
            draw_set_valign(fa_middle);
            draw_set_colour(ui_gris); draw_set_alpha(0.6);
            draw_text_transformed(_X + 12 * ui_u, _oy[_c] + 16 * ui_u, _r.sec, 0.72 * ui_u, 0.72 * ui_u, 0);
            draw_set_alpha(1);
            _oy[_c] += _sech;
        }

        var _T = _oy[_c];
        var _on = (i == opt_sel);
        var _sk = 10 * ui_u;
        ctf_ui_para(_X, _T, _cw, _rh, _sk, ui_tinta, 0.85, false);
        if (_on) ctf_ui_para(_X, _T, _cw, _rh, _sk, ui_azul, 0.12, false);
        ctf_ui_para(_X, _T, _cw, _rh, _sk, _on ? ui_azul : ui_gris, _on ? 1 : 0.22, true);
        if (_on) ctf_ui_para(_X, _T, _sk + 3, _rh, _sk, ui_azul, 1, false);

        // Nombre
        draw_set_font(fnt_small);
        draw_set_halign(fa_left);
        draw_set_valign(fa_middle);
        draw_set_colour(_on ? ui_azul : ui_gris);
        draw_text_transformed(_X + 24 * ui_u, _T + _rh / 2, _r.n, 0.88 * ui_u, 0.88 * ui_u, 0);

        // Valor:  <  VALOR  >
        var _vr = _X + _cw - _sk - 14 * ui_u;
        var _vtxt = opt_valor_txt(_r);
        draw_set_halign(fa_right);
        draw_set_colour(_on ? ui_azul : ui_gris); draw_set_alpha(_on ? 1 : 0.5);
        draw_text_transformed(_vr, _T + _rh / 2, ">", 0.7 * ui_u, 0.7 * ui_u, 0);
        draw_set_alpha(1);
        var _vx = _vr - 22 * ui_u;
        draw_set_colour(ui_oro);
        draw_text_transformed(_vx, _T + _rh / 2, _vtxt, 0.7 * ui_u, 0.7 * ui_u, 0);
        var _vw = string_width(_vtxt) * 0.7 * ui_u;
        var _lx = _vx - _vw - 14 * ui_u;
        if (variable_struct_exists(_r, "slider")) {
            // barrita
            var _bw = 110 * ui_u;
            var _bx = _lx - _bw;
            var _byy = _T + _rh / 2 - 3 * ui_u;
            draw_set_colour(ui_gris); draw_set_alpha(0.12);
            draw_rectangle(_bx, _byy, _bx + _bw, _byy + 6 * ui_u, false);
            draw_set_alpha(1);
            var _fw = _bw * global.opt[$ _r.k] / 100;
            if (_fw > 1) draw_rectangle_colour(_bx, _byy, _bx + _fw, _byy + 6 * ui_u, ui_azul, merge_colour(ui_azul, ui_oro, _fw / _bw), merge_colour(ui_azul, ui_oro, _fw / _bw), ui_azul, false);
            _lx = _bx - 14 * ui_u;
        }
        draw_set_colour(_on ? ui_azul : ui_gris); draw_set_alpha(_on ? 1 : 0.5);
        draw_text_transformed(_lx, _T + _rh / 2, "<", 0.7 * ui_u, 0.7 * ui_u, 0);
        draw_set_alpha(1);

        // Toque / clic: izquierda baja, derecha sube. La linea que los separa queda a la mitad
        // entre la flechita "<" y la ">" (antes estaba al 35% y la "<" caia del lado de subir)
        var _corte = (_lx + _vr) / 2;
        ui_tap_add(_X, _T, _corte, _T + _rh, i, vk_left);
        ui_tap_add(_corte, _T, _X + _cw, _T + _rh, i, vk_right);

        _oy[_c] += _rh + _rg;
    }

    // Nota en PC sobre los controles del celular
    if (!touch_mode()) {
        draw_set_font(fnt_small);
        draw_set_halign(fa_left);
        draw_set_valign(fa_top);
        draw_set_colour(ui_gris); draw_set_alpha(0.45);
        draw_text_transformed(_cx1, _oy[1] + 4 * ui_u, "ESTOS SE USAN CUANDO JUEGAS EN EL CELULAR", 0.5 * ui_u, 0.5 * ui_u, 0);
        draw_set_alpha(1);
    }

    ctf_ui_hint(gui_w / 2, gui_h - 40 * ui_u, "[W/S] ELEGIR     [A/D] CAMBIAR     [ESC] VOLVER", ui_u);
}

// ==========================================
// PANTALLA DE CARGA (TU EFECTO DEL ORBE)
// ==========================================
else if (menu_state == "connecting")
{
    var cx = gui_w * 0.5;
    var cy = gui_h * 0.5;

    // --- Tiempo ---
    var t = current_time * 0.001;
    var pulse  = 0.5 + 0.5 * sin(t * 2.5);
    var pulse2 = 0.5 + 0.5 * sin(t * 1.3 + 1.2);

    // --- Fondo ---
    ctf_ui_fondo(gui_w, gui_h);

    // --- Glow central ---
    for (var r = 420; r > 0; r -= 30) {
        draw_set_alpha((r / 420) * 0.06);
        draw_set_color(ui_azul);
        draw_circle(cx, cy, r + pulse * 18, false);
    }
    draw_set_alpha(1);

    // --- Estrellitas ---
    draw_set_alpha(0.35); draw_set_color(c_white);
    for (var i = 0; i < 40; i++) {
        var px = (sin(i * 123.45 + t * 0.6) * 9999); px = (px - floor(px)) * gui_w;
        var py = (sin(i * 54.321 + t * 0.9) * 8888); py = (py - floor(py)) * gui_h;
        draw_rectangle(px, py, px + 2, py + 2, false);
    }
    draw_set_alpha(1);

    // --- Panel central ---
    var panel_w = 560; var panel_h = 260;
    var px1 = cx - panel_w * 0.5; var py1 = cy - panel_h * 0.5;
    ctf_ui_panel(px1, py1, px1 + panel_w, py1 + panel_h, ui_azul);

    // --- Orbe + anillo ---
    var orb_r  = 46 + pulse * 6;
    var ring_r = 70 + pulse2 * 8;
    draw_set_alpha(0.18); draw_set_color(ui_azul);
    draw_circle(cx - 170, cy - 10, ring_r + 24, false);
    draw_set_alpha(0.9); draw_set_color(merge_colour(ui_azul, c_white, 0.35));
    draw_circle(cx - 170, cy - 10, orb_r, false);

    // Anillo giratorio
    for (var s = 0; s < 24; s++) {
        var a2 = (t * 120) + (s * (360 / 24));
        var rx = (cx - 170) + lengthdir_x(ring_r, a2);
        var ry = (cy - 10)  + lengthdir_y(ring_r, a2);
        draw_set_color((s mod 6 == 0) ? ui_oro : ui_azul);
        draw_circle(rx, ry, (s mod 3 == 0) ? 3 : 2, false);
    }
    draw_set_alpha(1);

    // --- TEXTOS DINAMICOS ---
    draw_set_font(fnt_menu); draw_set_halign(fa_left); draw_set_valign(fa_top);
    draw_set_color(c_white);

    var es_random = string_count("auto_matchmake", string(global.roomId));
    draw_text(px1 + 210, py1 + 50, es_random ? "BUSCANDO RIVAL" : "SALA PRIVADA");

    var dots = string_repeat(".", (waiting_timer div 12) mod 4);
    draw_set_font(fnt_small);
    draw_set_color(ui_gris);
    draw_text_transformed(px1 + 210, py1 + 92, string_upper(es_random ? waiting_message : "Creando sala") + dots, 0.75, 0.75, 0);

    if (!es_random && global.myRoomCode != "") {
        draw_set_color(ui_oro);
        draw_text_transformed(px1 + 210, py1 + 118, "CODIGO: " + string(global.myRoomCode), 0.8, 0.8, 0);
    }

    // --- Barra de progreso ---
    var bar_x1 = px1 + 210; var bar_y1 = py1 + 160;
    draw_set_color(ui_gris); draw_set_alpha(0.1);
    draw_rectangle(bar_x1, bar_y1, bar_x1 + 300, bar_y1 + 6, false);
    draw_set_alpha(1);
    var fill = 300 * ((t * 0.35) % 1);
    for (var _b = 0; _b < 20; _b++) {
        var _bt = _b / 20;
        draw_set_color(merge_colour(ui_azul, ui_oro, _bt));
        draw_rectangle(bar_x1 + _bt * fill, bar_y1, bar_x1 + (_bt + 0.05) * fill, bar_y1 + 6, false);
    }

    // --- Footer ---
    ctf_ui_hint(cx, py1 + panel_h + 30, "[ESC] CANCELAR", 1);
}
else if (menu_state == "verifying") {
    ctf_ui_fondo(gui_w, gui_h);
    var dots = string_repeat(".", (current_time div 250) mod 4);
    draw_set_font(fnt_menu);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_color(c_white);
    draw_text_transformed(gui_w / 2, gui_h / 2, "VERIFICANDO CODIGO" + dots, ui_u, ui_u, 0);
}
else if (menu_state == "lobby_espera") {
    var gui_w = display_get_gui_width();
    var gui_h = display_get_gui_height();

    // --- 1. DETECTAR LIMITE DE SALA ---
    if (!oBrain.AmIPseudoHost) {
        if (string_copy(global.myRoomCode, 1, 3) == "MAX") {
            global.max_players_allowed = real(string_digits(string_copy(global.myRoomCode, 4, 1)));
        } else {
            global.max_players_allowed = 8;
        }
    }

    // Fondo
    ctf_ui_fondo(gui_w, gui_h);

    // --- CODIGO DE SALA (clic para copiar) ---
    var tx = gui_w / 2;
    var ty = 50;
    var room_text = "SALA: " + string(global.myRoomCode);

    var mx = device_mouse_x_to_gui(0);
    var my = device_mouse_y_to_gui(0);
    var hover_room = point_in_rectangle(mx, my, tx - 150, ty - 20, tx + 150, ty + 20);

    ctf_ui_para(tx - 150, ty - 20, 300, 40, 10, ui_tinta, 0.9, false);
    ctf_ui_para(tx - 150, ty - 20, 300, 40, 10, (copiado_timer > 0) ? ui_verde : ui_oro, hover_room ? 0.9 : 0.4, true);

    draw_set_font(fnt_small);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    if (copiado_timer > 0) {
        copiado_timer--;
        draw_set_color(ui_verde);
        draw_text_transformed(tx, ty - 32, "COPIADO!", 0.65, 0.65, 0);
    } else if (hover_room) {
        draw_set_color(ui_azul);
        draw_text_transformed(tx, ty - 32, "CLIC PARA COPIAR", 0.65, 0.65, 0);
        if (mouse_check_button_pressed(mb_left)) {
            clipboard_set_text(string(global.myRoomCode));
            copiado_timer = 90;
        }
    } else {
        draw_set_color(ui_gris); draw_set_alpha(0.5);
        draw_text_transformed(tx, ty - 32, "CODIGO DE SALA", 0.65, 0.65, 0);
        draw_set_alpha(1);
    }
    draw_set_font(fnt_menu);
    draw_set_color(ui_oro);
    draw_text_transformed(tx, ty, room_text, 0.85, 0.85, 0);

    // --- 2. CASILLAS: cada quien en su equipo y lo que falta son bots (scr_objetivo) ---
    var _sl = scr_sala_slots();
    var slot_w = 400; var slot_h = 60;

    draw_set_font(fnt_small);
    draw_set_halign(fa_left);
    draw_set_valign(fa_middle);
    draw_set_color(ui_azul);
    draw_text_transformed((gui_w / 2) - 450, 178, "EQUIPO AZUL", 0.65, 0.65, 0);
    draw_set_color(ui_rojo);
    draw_text_transformed((gui_w / 2) + 50, 178, "EQUIPO ROJO", 0.65, 0.65, 0);

    var _n_bots = 0;
    for (var _t = 0; _t < 2; _t++) {
        var _lista = (_t == 0) ? _sl.azul : _sl.rojo;
        var color_equipo = (_t == 1) ? ui_rojo : ui_azul;
        for (var k = 0; k < array_length(_lista); k++) {
            var _s = _lista[k];
            var _pos = scr_sala_slot_pos(_t == 1, k);
            var _x = _pos[0];
            var _y = _pos[1];
            var _soy_yo = (_s.tipo == "yo");
            var _bot = (_s.tipo == "bot");
            if (_bot) _n_bots++;

            // Casilla (la del bot mas apagada)
            ctf_ui_para(_x, _y, slot_w, slot_h, 10, ui_tinta, 0.88, false);
            ctf_ui_para(_x, _y, slot_w, slot_h, 10, color_equipo, _bot ? 0.04 : 0.08, false);
            ctf_ui_para(_x, _y, slot_w, slot_h, 10, _soy_yo ? ui_oro : (_bot ? ui_gris : color_equipo), _bot ? 0.35 : 0.55, true);
            ctf_ui_para(_x, _y, 16, slot_h, 10, color_equipo, _bot ? 0.45 : 1, false);

            // Nombre
            draw_set_font(fnt_menu);
            draw_set_halign(fa_left);
            draw_set_valign(fa_middle);
            if (_soy_yo) draw_set_color(ui_oro);
            else if (_bot) draw_set_color(c_ltgray);
            else draw_set_color(c_white);
            draw_text_transformed(_x + 32, _y + (slot_h / 2), string(_s.nombre), 0.85, 0.85, 0);

            // Etiqueta a la derecha: LIDER o BOT
            if (_s.lider) {
                draw_set_font(fnt_small);
                draw_set_halign(fa_right);
                draw_set_color(ui_oro);
                draw_text_transformed(_x + slot_w - 22, _y + (slot_h / 2), "LIDER", 0.6, 0.6, 0);
            } else if (_bot) {
                var _cx = _x + slot_w - 92;
                var _cy = _y + (slot_h / 2) - 14;
                ctf_ui_para(_cx, _cy, 66, 28, 6, ui_gris, 0.25, false);
                ctf_ui_para(_cx, _cy, 66, 28, 6, ui_gris, 0.7, true);
                draw_set_font(fnt_small);
                draw_set_halign(fa_center);
                draw_set_color(c_ltgray);
                draw_text_transformed(_cx + 33, _y + (slot_h / 2), "BOT", 0.6, 0.6, 0);
            }
        }
    }

    // --- 4. FOOTER ---
    var _ftxt = "";
    var _fcol = ui_gris;
    if (oBrain.AmIPseudoHost) {
        // Ya no hay que esperar a que se llene: lo que falte lo juegan bots
        _fcol = ui_oro;
        var _tecla = touch_mode() ? "OK" : "ENTER";
        if (_n_bots == 0) _ftxt = "SALA LLENA! PRESIONA " + _tecla + " PARA EMPEZAR";
        else _ftxt = "PRESIONA " + _tecla + " PARA EMPEZAR (" + string(_n_bots) + ((_n_bots == 1) ? " BOT)" : " BOTS)");
    } else {
        _fcol = c_white;
        _ftxt = "ESPERANDO A QUE EL LIDER INICIE...";
    }
    draw_set_font(fnt_menu);
    var _fw = string_width(_ftxt) * 0.75 + 60;
    ctf_ui_para(gui_w / 2 - _fw / 2, gui_h - 80, _fw, 40, 10, ui_tinta, 0.9, false);
    ctf_ui_para(gui_w / 2 - _fw / 2, gui_h - 80, _fw, 40, 10, _fcol, 0.5, true);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_color(_fcol);
    draw_text_transformed(gui_w / 2, gui_h - 60, _ftxt, 0.75, 0.75, 0);

    // --- 5. BOTON SALIR (arriba a la izquierda) ---
    var _sx = 20 * ui_u; var _sy = 20 * ui_u;
    var _sw = 150 * ui_u; var _sh2 = 44 * ui_u;
    var _shover = point_in_rectangle(mx, my, _sx, _sy, _sx + _sw, _sy + _sh2) && !confirmar_salida;
    ctf_ui_para(_sx, _sy, _sw, _sh2, 10 * ui_u, ui_tinta, 0.9, false);
    ctf_ui_para(_sx, _sy, _sw, _sh2, 10 * ui_u, ui_rojo, _shover ? 0.18 : 0.06, false);
    ctf_ui_para(_sx, _sy, _sw, _sh2, 10 * ui_u, ui_rojo, _shover ? 1 : 0.5, true);
    draw_set_font(fnt_menu);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_color(ui_rojo);
    draw_text_transformed(_sx + _sw / 2, _sy + _sh2 / 2 - 2 * ui_u, "< SALIR", 0.7 * ui_u, 0.7 * ui_u, 0);
    if (!touch_mode()) {
        draw_set_font(fnt_small);
        draw_set_color(ui_gris); draw_set_alpha(0.5);
        draw_text_transformed(_sx + _sw / 2, _sy + _sh2 + 12 * ui_u, "[ESC]", 0.55 * ui_u, 0.55 * ui_u, 0);
        draw_set_alpha(1);
    }

    // --- 6. VENTANITA: SEGURO QUE QUIERES SALIR? ---
    if (confirmar_salida) {
        draw_set_color(c_black); draw_set_alpha(0.7);
        draw_rectangle(0, 0, gui_w, gui_h, false);
        draw_set_alpha(1);

        var _pw = 540 * ui_u; var _ph = 250 * ui_u;
        var _px = gui_w / 2 - _pw / 2;
        var _py = gui_h / 2 - _ph / 2 - 20 * ui_u;
        ctf_ui_panel(_px, _py, _px + _pw, _py + _ph, ui_rojo);

        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);
        draw_set_font(fnt_menu);
        draw_set_color(c_white);
        draw_text_transformed(gui_w / 2, _py + 45 * ui_u, "SALIR DE LA SALA?", 1.0 * ui_u, 1.0 * ui_u, 0);
        draw_set_font(fnt_small);
        draw_set_color(ui_gris); draw_set_alpha(0.65);
        var _otros = instance_number(oOtherPlayer);
        var _msg = "VAS A DEJAR LA SALA " + string(global.myRoomCode);
        if (oBrain.AmIPseudoHost) _msg = (_otros > 0) ? "ERES EL LIDER. OTRO JUGADOR QUEDARA COMO LIDER" : "ESTAS SOLO. LA SALA SE VA A CERRAR";
        draw_text_transformed(gui_w / 2, _py + 88 * ui_u, _msg, 0.65 * ui_u, 0.65 * ui_u, 0);
        draw_set_alpha(1);

        // Botones (mismas medidas que en el Step)
        var _bw  = 200 * ui_u;
        var _bh  = 48 * ui_u;
        var _by  = gui_h / 2 + 40 * ui_u;
        var _bxs = [gui_w / 2 - _bw - 12 * ui_u, gui_w / 2 + 12 * ui_u];
        var _btx = ["SI, SALIR", "NO, QUEDARME"];
        var _bcl = [ui_rojo, ui_azul];
        for (var b = 0; b < 2; b++) {
            var _on = (salir_sel == b);
            ctf_ui_para(_bxs[b], _by, _bw, _bh, 10 * ui_u, ui_tinta, 0.95, false);
            if (_on) ctf_ui_para(_bxs[b], _by, _bw, _bh, 10 * ui_u, _bcl[b], 0.2, false);
            ctf_ui_para(_bxs[b], _by, _bw, _bh, 10 * ui_u, _bcl[b], _on ? 1 : 0.3, true);
            if (_on) ctf_ui_para(_bxs[b], _by, 13 * ui_u, _bh, 10 * ui_u, _bcl[b], 1, false);
            draw_set_font(fnt_menu);
            draw_set_color(_on ? _bcl[b] : ui_gris);
            draw_text_transformed(_bxs[b] + _bw / 2, _by + _bh / 2, _btx[b], 0.7 * ui_u, 0.7 * ui_u, 0);
        }

        ctf_ui_hint(gui_w / 2, _by + _bh + 40 * ui_u, touch_mode() ? "TOCA UNA OPCION" : "[A/D] ELEGIR     [ENTER] ACEPTAR     [ESC] CANCELAR", ui_u);
    }
    draw_set_valign(fa_top);
}
else if (menu_state == "setup_room") {
    ctf_ui_fondo(gui_w, gui_h);
    var _hy = ctf_ui_header(gui_w, "CONFIGURACION DE PARTIDA", "", ui_u);
    var _tot = array_length(setup_options) * 56 * ui_u;
    ctf_ui_lista(gui_w / 2, max(_hy + 20 * ui_u, gui_h / 2 - _tot / 2), setup_options, s_index, ui_u, [0, 1, 2, 3]);
    ctf_ui_hint(gui_w / 2, gui_h - 40 * ui_u, "[W/S] ELEGIR     [A/D] CAMBIAR     [ENTER] ACEPTAR     [ESC] VOLVER", ui_u);
}
else if (menu_state == "offline_setup") {
    ctf_ui_fondo(gui_w, gui_h);
    var _hy = ctf_ui_header(gui_w, "ENTRENAMIENTO OFFLINE", "PRACTICA CONTRA BOTS", ui_u);
    var _tot = array_length(offline_options) * 56 * ui_u;
    ctf_ui_lista(gui_w / 2, max(_hy + 20 * ui_u, gui_h / 2 - _tot / 2), offline_options, off_index, ui_u, [0, 1, 2]);
    ctf_ui_hint(gui_w / 2, gui_h - 40 * ui_u, "[W/S] ELEGIR     [A/D] CAMBIAR     [ENTER] ACEPTAR     [ESC] VOLVER", ui_u);
}
if (menu_state == "play_selection") {
    ctf_ui_fondo(gui_w, gui_h);
    var _hy = ctf_ui_header(gui_w, "SELECT MODE", "ELIGE COMO QUIERES JUGAR", ui_u);
    var _tot = array_length(play_modes) * 56 * ui_u;
    ctf_ui_lista(gui_w / 2, max(_hy + 20 * ui_u, gui_h / 2 - _tot / 2), play_modes, play_index, ui_u);
    ctf_ui_hint(gui_w / 2, gui_h - 40 * ui_u, "[W/S] ELEGIR     [ENTER] ACEPTAR     [ESC] VOLVER", ui_u);
}
if (menu_state == "profile") {
    draw_player_profile(room_width/2, room_height/2);

    // --- RESULTADO DE BUSQUEDA ---
    if (estado_busqueda == "encontrado" && datos_busqueda_resultado != -1) {
        var _bx1 = gui_w / 2 - 240 * ui_u;
        var _by1 = gui_h / 2 - 170 * ui_u;
        var _bx2 = gui_w / 2 + 240 * ui_u;
        var _by2 = gui_h / 2 + 170 * ui_u;
        draw_set_color(c_black); draw_set_alpha(0.6);
        draw_rectangle(0, 0, gui_w, gui_h, false);
        draw_set_alpha(1);
        ctf_ui_panel(_bx1, _by1, _bx2, _by2, ui_verde);

        var _lx = _bx1 + 30 * ui_u;
        draw_set_halign(fa_left);
        draw_set_valign(fa_middle);
        draw_set_font(fnt_small);
        draw_set_color(ui_verde);
        draw_text_transformed(_lx, _by1 + 34 * ui_u, "JUGADOR ENCONTRADO", 0.7 * ui_u, 0.7 * ui_u, 0);
        draw_set_font(fnt_menu);
        draw_set_color(c_white);
        draw_text_transformed(_lx, _by1 + 80 * ui_u, string_upper(string(datos_busqueda_resultado.nombre)), 1.0 * ui_u, 1.0 * ui_u, 0);
        draw_set_font(fnt_small);
        draw_set_color(ui_oro);
        draw_text_transformed(_lx, _by1 + 130 * ui_u, "COPAS: " + string(datos_busqueda_resultado.copas), 0.7 * ui_u, 0.7 * ui_u, 0);
        draw_set_color(ui_gris);
        draw_text_transformed(_lx, _by1 + 160 * ui_u, "RANGO: " + string_upper(string(datos_busqueda_resultado.rank)), 0.7 * ui_u, 0.7 * ui_u, 0);
        draw_text_transformed(_lx, _by1 + 190 * ui_u, "KILLS: " + string(datos_busqueda_resultado.kills), 0.7 * ui_u, 0.7 * ui_u, 0);
        draw_set_halign(fa_center);
        draw_set_color(ui_azul);
        draw_text_transformed(gui_w / 2, _by2 - 70 * ui_u, "[ENTER] ENVIAR SOLICITUD", 0.7 * ui_u, 0.7 * ui_u, 0);
        draw_set_color(ui_gris); draw_set_alpha(0.6);
        draw_text_transformed(gui_w / 2, _by2 - 38 * ui_u, "[ESC] CERRAR", 0.6 * ui_u, 0.6 * ui_u, 0);
        draw_set_alpha(1);
    }
}
else if (menu_state == "achievements") {
    var cx = gui_w / 2;
    var cy = gui_h / 2;

    ctf_ui_fondo(gui_w, gui_h);
    var _hy = ctf_ui_header(gui_w, "LOGROS", "", ui_u);

    var tabla_ancho = 550;
    gmda_draw_achievements(cx - (tabla_ancho / 2), _hy + 10);

    ctf_ui_hint(cx, gui_h - 34 * ui_u, "[ESC] O [ENTER] PARA VOLVER", ui_u);
}
else if (menu_state == "friends_menu") {
    var cx = gui_w / 2;
    var cy = gui_h / 2;

    ctf_ui_fondo(gui_w, gui_h);

    if (friends_state == "main") {
        var _hy = ctf_ui_header(gui_w, "AMIGOS", "JUEGA CON TUS PANAS", ui_u);
        var _tot = array_length(friends_options) * 56 * ui_u;
        ctf_ui_lista(cx, max(_hy + 20 * ui_u, cy - _tot / 2), friends_options, friends_index, ui_u);
        ctf_ui_hint(cx, gui_h - 40 * ui_u, "[W/S] ELEGIR     [ENTER] ACEPTAR     [ESC] VOLVER", ui_u);
    }

else if (friends_state == "lista") {
    var cx = gui_w / 2;
    var cy = gui_h / 2;

    ctf_ui_header(gui_w, "TUS AMIGOS", "", 1);

    // --- LOGICA DE SCROLL SUAVE ---
    scroll_y = lerp(scroll_y, scroll_target, 0.15);

    var start_y = 180 + scroll_y;
    var card_h = 80;
    var card_w = 500;
    var gap = 15;

    var mx = device_mouse_x_to_gui(0);
    var my = device_mouse_y_to_gui(0);

    if (array_length(global.lista_amigos) > 0) {
        for (var i = 0; i < array_length(global.lista_amigos); i++) {
            var yy = start_y + (i * (card_h + gap));

            // Solo dibujamos si esta en pantalla
            if (yy > 100 && yy < gui_h - 100) {
                var amigo = global.lista_amigos[i];
                var es_seleccionado = (i == friend_selected);

                var _nombre = variable_struct_exists(amigo, "nombre") ? amigo.nombre : "??";
                var _tag    = variable_struct_exists(amigo, "tag")    ? amigo.tag    : "#0000";

                // --- TARJETA ---
                var _kx = cx - card_w / 2;
                var _ky = yy - card_h / 2;
                ctf_ui_para(_kx, _ky, card_w, card_h, 12, ui_tinta, 0.9, false);
                if (es_seleccionado) ctf_ui_para(_kx, _ky, card_w, card_h, 12, ui_azul, 0.12, false);
                ctf_ui_para(_kx, _ky, card_w, card_h, 12, es_seleccionado ? ui_azul : ui_gris, es_seleccionado ? 1 : 0.2, true);
                if (es_seleccionado) ctf_ui_para(_kx, _ky, 15, card_h, 12, ui_azul, 1, false);
                ui_tap_add(_kx, _ky, cx + card_w / 2 - 140, _ky + card_h, -1, -1, { tipo: "amigo", i: i });

                // Estado online/offline
                var _tag_amigo = amigo.tag;
                var _esta_online = gmda_status(_tag_amigo);
                draw_set_color(_esta_online ? ui_verde : ui_gris);
                draw_set_alpha(_esta_online ? 1 : 0.4);
                draw_circle(cx - card_w / 2 + 28, yy, 6, false);
                draw_set_alpha(1);

                // Nombre
                draw_set_valign(fa_middle);
                draw_set_halign(fa_left);
                draw_set_font(fnt_menu);
                draw_set_color(c_white);
                draw_text_transformed(cx - card_w / 2 + 44, yy, _nombre, 0.85, 0.85, 0);

                // Nivel
                var _lvl = variable_struct_exists(amigo, "lvl") ? amigo.lvl : 1;
                var _nw = string_width(_nombre) * 0.85;
                draw_set_font(fnt_small);
                draw_set_color(ui_oro);
                draw_text_transformed(cx - card_w / 2 + 54 + _nw, yy, "LV." + string(_lvl), 0.65, 0.65, 0);

                // Tag
                draw_set_halign(fa_right);
                draw_set_color(es_seleccionado ? c_white : ui_azul);
                draw_set_alpha(es_seleccionado ? 1 : 0.7);
                draw_text_transformed(cx + card_w / 2 - 40, yy + 22, "TAG: " + string(_tag), 0.55, 0.55, 0);
                draw_set_alpha(1);

                // Boton eliminar (X)
                var _bx = cx + card_w / 2 - 25;
                draw_set_color(ui_rojo);
                draw_set_alpha(es_seleccionado ? 0.85 : 0.3);
                draw_circle(_bx, yy, 12, false);
                draw_set_alpha(1);
                draw_set_color(c_white);
                draw_set_halign(fa_center);
                draw_text_transformed(_bx, yy, "X", 0.7, 0.7, 0);

                // Boton duelo (!)
                if (_esta_online) {
                    var _dx = cx + card_w / 2 - 110;
                    draw_set_color(ui_oro);
                    draw_circle(_dx, yy, 12, false);
                    draw_set_color(ui_tinta);
                    draw_set_halign(fa_center);
                    draw_set_valign(fa_middle);
                    draw_text_transformed(_dx, yy, "!", 0.8, 0.8, 0);

                    if (point_distance(mx, my, _dx, yy) < 15) {
                        var _tw = string_width("RETAR A DUELO") * 0.65 + 20;
                        draw_set_color(ui_tinta); draw_set_alpha(0.95);
                        draw_rectangle(mx + 10, my - 34, mx + 10 + _tw, my - 10, false);
                        draw_set_alpha(1);
                        draw_set_color(ui_oro);
                        draw_rectangle(mx + 10, my - 34, mx + 10 + _tw, my - 10, true);
                        draw_set_halign(fa_left);
                        draw_text_transformed(mx + 20, my - 22, "RETAR A DUELO", 0.65, 0.65, 0);
                    }
                }
            }
        }

        // Flechas de scroll
        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);
        draw_set_font(fnt_small);
        draw_set_color(ui_gris);
        if (scroll_target < 0) draw_text(cx, 140, "^ ^ ^");
        if (array_length(global.lista_amigos) > 4) draw_text(cx, gui_h - 120, "v v v");

    } else {
        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);
        draw_set_font(fnt_menu);
        draw_set_color(ui_gris); draw_set_alpha(0.55);
        draw_text_transformed(cx, cy - 15, "TU LISTA ESTA VACIA", 0.85, 0.85, 0);
        draw_set_alpha(1);
        draw_set_font(fnt_small);
        draw_set_color(ui_oro);
        draw_text_transformed(cx, cy + 25, "VE A ADD PARA BUSCAR AMIGOS", 0.65, 0.65, 0);
    }

    // --- BARRA DE ACCIONES ---
    if (array_length(global.lista_amigos) > 0) {
        var amigo_act = global.lista_amigos[friend_selected];
        var panel_y = gui_h - 180;

        draw_set_color(ui_tinta); draw_set_alpha(0.92);
        draw_rectangle(0, panel_y, gui_w, panel_y + 60, false);
        draw_set_color(ui_gris); draw_set_alpha(0.15);
        draw_line(0, panel_y, gui_w, panel_y);
        draw_line(0, panel_y + 60, gui_w, panel_y + 60);
        draw_set_alpha(1);

        draw_set_font(fnt_small);
        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);
        draw_set_color(ui_oro);
        draw_text_transformed(cx, panel_y + 30, touch_mode() ? "TOCA UN AMIGO PARA ELEGIRLO, TOCALO OTRA VEZ PARA VER SU PERFIL" : "[W/S] NAVEGAR     [P] O CLIC: VER PERFIL     [X] ELIMINAR     [ESC] VOLVER", 0.65, 0.65, 0);

        if (keyboard_check(vk_control)) {
            draw_set_color(c_white);
            draw_text_transformed(cx, panel_y - 20, "ID: " + string(amigo_act.id_largo), 0.7, 0.7, 0);
        }
    }
}
else if (friends_state == "anadir") {
    ctf_ui_header(gui_w, "AGREGAR AMIGO", "", ui_u);

    // Etiqueta
    draw_set_font(fnt_small);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_color(ui_gris); draw_set_alpha(0.55);
    draw_text_transformed(cx, cy - 200, "ESCRIBE EL ID DEL JUGADOR", 0.65, 0.65, 0);
    draw_set_alpha(1);

    // Cuadro de busqueda (misma posicion)
    ctf_ui_para(cx - 250, cy - 180, 500, 60, 12, ui_tinta, 0.92, false);
    ctf_ui_para(cx - 250, cy - 180, 500, 60, 12, input_activo ? ui_azul : ui_gris, input_activo ? 1 : 0.35, true);

    draw_set_font(fnt_menu);
    draw_set_color(c_white);
    var cursor = (input_activo && (current_time mod 1000 < 500)) ? "|" : "";
    draw_text(cx, cy - 150, friends_search_input + cursor);

    // 1. CARGA
    var es_buscando = (estado_busqueda == "buscando" || estado_busqueda == "buscando_nombre" || estado_busqueda == "buscando_perfil_final");
    if (es_buscando) {
        var dots = string_repeat(".", (current_time div 250) mod 4);
        draw_set_font(fnt_small);
        draw_set_color(ui_oro);
        draw_text_transformed(cx, cy, "BUSCANDO EN LA BASE DE DATOS" + dots, 0.75, 0.75, 0);
    }

    // 2. EXITO
    if (estado_busqueda == "encontrado" && datos_busqueda_resultado != -1) {
        ctf_ui_panel(cx - 230, cy - 60, cx + 230, cy + 150, ui_verde);
        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);
        draw_set_font(fnt_small);
        draw_set_color(ui_verde);
        draw_text_transformed(cx, cy - 30, "JUGADOR ENCONTRADO!", 0.75, 0.75, 0);
        draw_set_font(fnt_menu);
        draw_set_color(c_white);
        draw_text_transformed(cx, cy + 15, string_upper(string(datos_busqueda_resultado.nombre)), 1.0, 1.0, 0);
        draw_set_font(fnt_small);
        draw_set_color(ui_oro);
        draw_text_transformed(cx, cy + 55, "COPAS: " + string(datos_busqueda_resultado.copas), 0.7, 0.7, 0);
        ctf_ui_para(cx - 190, cy + 92, 380, 36, 8, ui_azul, 0.12, false);
        ctf_ui_para(cx - 190, cy + 92, 380, 36, 8, ui_azul, 0.7, true);
        draw_set_color(ui_azul);
        draw_text_transformed(cx, cy + 110, touch_mode() ? "TOCA AQUI PARA ENVIAR SOLICITUD" : "[F] ENVIAR SOLICITUD", 0.7, 0.7, 0);
        ui_tap_add(cx - 190, cy + 92, cx + 190, cy + 128, -1, ord("F"));
    }

    // 3. ERROR
    if (estado_busqueda == "error") {
        draw_set_font(fnt_small);
        draw_set_halign(fa_center);
        draw_set_color(ui_rojo);
        draw_text_transformed(cx, cy, string_upper(string(mensaje_texto)), 0.75, 0.75, 0);
    }

    ctf_ui_hint(cx, gui_h - 50, "[ESC] VOLVER", 1);
}
else if (friends_state == "perfil_amigo")
{
    var cx = gui_w / 2;
    var cy = gui_h / 2;

    if (estado_busqueda == "buscando") {
        var dots = string_repeat(".", (current_time div 250) mod 4);
        draw_set_font(fnt_menu);
        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);
        draw_set_color(c_white);
        draw_text_transformed(cx, cy, "OBTENIENDO DATOS" + dots, ui_u, ui_u, 0);
    }
    else if (estado_busqueda == "encontrado" && is_struct(datos_busqueda_resultado)) {

        var _n = datos_busqueda_resultado.nombre;
        var _t = datos_busqueda_resultado.friend_tag;
        var _l = datos_busqueda_resultado.lvl;
        var _c = datos_busqueda_resultado.copas;
        var _k = datos_busqueda_resultado.kills;
        var _w = datos_busqueda_resultado.wins;
        var _f = datos_busqueda_resultado.flags;

        var _hy = ctf_ui_header(gui_w, "PERFIL DE JUGADOR", "", ui_u);

        var _pw = 520 * ui_u;
        var _px1 = cx - _pw / 2;
        var _py1 = max(_hy + 10 * ui_u, cy - 230 * ui_u);
        var _py2 = _py1 + 420 * ui_u;
        ctf_ui_panel(_px1, _py1, _px1 + _pw, _py2, ui_azul);

        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);
        draw_set_font(fnt_menu);
        draw_set_color(c_white);
        draw_text_transformed(cx, _py1 + 50 * ui_u, string_upper(string(_n)), 1.1 * ui_u, 1.1 * ui_u, 0);

        var _tagtxt = "TAG: " + string(_t);
        draw_set_font(fnt_small);
        var _tw = string_width(_tagtxt) * 0.65 * ui_u + 30 * ui_u;
        ctf_ui_para(cx - _tw / 2, _py1 + 82 * ui_u, _tw, 24 * ui_u, 6 * ui_u, ui_oro, 0.1, false);
        ctf_ui_para(cx - _tw / 2, _py1 + 82 * ui_u, _tw, 24 * ui_u, 6 * ui_u, ui_oro, 0.4, true);
        draw_set_color(ui_oro);
        draw_text_transformed(cx, _py1 + 94 * ui_u, _tagtxt, 0.65 * ui_u, 0.65 * ui_u, 0);

        var _lbl = ["NIVEL", "COPAS", "KILLS", "VICTORIAS", "BANDERAS"];
        var _val = [_l, _c, _k, _w, _f];
        var _col = [ui_oro, ui_oro, c_white, ui_rojo, ui_azul];
        var _ry  = _py1 + 140 * ui_u;
        for (var q = 0; q < 5; q++) {
            var _yy = _ry + q * 48 * ui_u;
            draw_set_color(ui_gris); draw_set_alpha(0.08);
            draw_line(_px1 + 24 * ui_u, _yy - 24 * ui_u, _px1 + _pw - 24 * ui_u, _yy - 24 * ui_u);
            draw_set_alpha(0.55);
            draw_set_font(fnt_small);
            draw_set_halign(fa_left);
            draw_text_transformed(_px1 + 40 * ui_u, _yy, _lbl[q], 0.65 * ui_u, 0.65 * ui_u, 0);
            draw_set_alpha(1);
            draw_set_font(fnt_menu);
            draw_set_halign(fa_right);
            draw_set_color(_col[q]);
            draw_text_transformed(_px1 + _pw - 40 * ui_u, _yy, string(_val[q]), 0.85 * ui_u, 0.85 * ui_u, 0);
        }
    }

    ctf_ui_hint(cx, gui_h - 50, "[ESC] VOLVER A LA LISTA", 1);
}
}


// --- MENU DE KICK (misma posicion) ---
if (show_kick_menu) {
    ctf_ui_para(kick_menu_x, kick_menu_y, 120, 40, 8, ui_rojo, 0.9, false);
    ctf_ui_para(kick_menu_x, kick_menu_y, 120, 40, 8, c_white, 0.6, true);
    draw_set_font(fnt_small);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_color(c_white);
    draw_text_transformed(kick_menu_x + 60, kick_menu_y + 20, "EXPULSAR", 0.75, 0.75, 0);
}

// --- MENSAJES DE CONFIRMACION ---
if (mensaje_alpha > 0) {
    var gui_w = display_get_gui_width();

    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_font(fnt_small);
    var _mtxt = string_upper(string(mensaje_texto));
    var _mw = string_width(_mtxt) * 0.8 + 60;
    var _ma = min(1, mensaje_alpha);

    draw_set_alpha(_ma * 0.95);
    draw_set_color(ui_tinta);
    draw_rectangle(gui_w / 2 - _mw / 2, 100 - 22, gui_w / 2 + _mw / 2, 100 + 22, false);
    draw_set_alpha(_ma);
    draw_set_color(ui_oro);
    draw_rectangle(gui_w / 2 - _mw / 2, 100 - 22, gui_w / 2 + _mw / 2, 100 + 22, true);
    draw_rectangle(gui_w / 2 - _mw / 2, 100 - 22, gui_w / 2 - _mw / 2 + 4, 100 + 22, false);
    draw_set_color(c_white);
    draw_text_transformed(gui_w / 2, 100, _mtxt, 0.8, 0.8, 0);

    draw_set_alpha(1);
}



if (mostrando_reto) {
    draw_emergency_challenge(display_get_gui_width()/2, display_get_gui_height()/2);
}

// --- CUADRO DE CONTROLES (solo en PC, en el menu principal) ---
if (menu_state == "main" && !touch_mode())
{
    var _cu = clamp(min(gui_w / 1280, gui_h / 720), 0.6, 1.6);
    var cuadro_ancho = 300 * _cu;
    var cuadro_alto  = 250 * _cu;
    var cuadro_x = 40 * _cu;
    var cuadro_y = gui_h / 2 - cuadro_alto / 2 + 30 * _cu;

    ctf_ui_panel(cuadro_x, cuadro_y, cuadro_x + cuadro_ancho, cuadro_y + cuadro_alto, ui_azul);
    ctf_ui_section(cuadro_x, cuadro_y, cuadro_ancho, cuadro_alto, "CONTROLS", ui_azul, ui_gris);

    var _keys = ["A, D", "W", "MOUSE", "L-CLICK", "R-CLICK"];
    var _acts = ["MOVE", "JUMP", "AIM", "FIRE", "GRENADE / MELEE"];
    draw_set_font(fnt_small);
    draw_set_valign(fa_middle);
    for (var c = 0; c < 5; c++) {
        var _cy2 = cuadro_y + 62 * _cu + c * 36 * _cu;
        draw_set_halign(fa_left);
        draw_set_color(ui_oro);
        draw_text_transformed(cuadro_x + 20 * _cu, _cy2, _keys[c], 0.7 * _cu, 0.7 * _cu, 0);
        draw_set_color(ui_gris);
        draw_text_transformed(cuadro_x + 120 * _cu, _cy2, _acts[c], 0.7 * _cu, 0.7 * _cu, 0);
    }

    draw_set_color(c_white);
    draw_set_alpha(1);
}
