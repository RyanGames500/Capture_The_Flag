// ============================================================
// PERFIL DEL JUGADOR (estilo cyberpunk, pantalla completa)
// Columna izquierda: heroe, ID, estadisticas, progreso
// Columna derecha: logros
// ============================================================
function draw_player_profile(px, py) {
    var C_TINTA = make_color_rgb(11, 15, 26);
    var C_AZUL  = make_color_rgb(31, 155, 255);
    var C_ROJO  = make_color_rgb(255, 42, 58);
    var C_ORO   = make_color_rgb(255, 212, 71);
    var C_GRIS  = make_color_rgb(169, 180, 208);
    var C_VERDE = make_color_rgb(78, 255, 145);

    var gw = display_get_gui_width();
    var gh = display_get_gui_height();
    var mx = device_mouse_x_to_gui(0);
    var my = device_mouse_y_to_gui(0);
    var click = mouse_check_button_pressed(mb_left) && !mostrando_selector && !input_activo;

    var colw = 440;
    var gap  = 24;
    var totw = colw * 2 + gap;
    var H    = 640;

    // Fondo oscuro en toda la pantalla
    ctf_ui_fondo(gw, gh);

    // Todo el perfil se dibuja en un espacio fijo y se escala a la pantalla
    var LW = totw + 48;
    var LH = H + 36;
    var k  = clamp(min((gw - 40) / LW, (gh - 40) / LH), 0.5, 1.6);
    var ox = (gw - LW * k) / 2;
    var oy = (gh - LH * k) / 2;
    matrix_set(matrix_world, matrix_build(ox, oy, 0, 0, 0, 0, k, k, 1));
    mx = (mx - ox) / k;
    my = (my - oy) / k;

    var x0  = 24;
    var x1  = x0 + colw + gap;
    var top = 18;

    // Panel (con la estetica nueva no va: se ve el fondo con rayas)
    if (!MN_NUEVO) {
    draw_set_color(C_TINTA); draw_set_alpha(0.7);
    draw_rectangle(0, 0, LW, LH, false);
    draw_set_color(C_GRIS); draw_set_alpha(0.12);
    draw_rectangle(0, 0, LW, LH, true);
    }
    draw_set_alpha(1);

    // ── VOLVER ──
    draw_set_font(fnt_small);
    draw_set_halign(fa_left);
    draw_set_valign(fa_middle);
    var back_txt = "< MENU PRINCIPAL   [ESC]";
    var back_w = string_width(back_txt) * 0.65;
    var back_hover = point_in_rectangle(mx, my, x0, top, x0 + back_w, top + 20);
    draw_set_color(back_hover ? C_AZUL : C_GRIS);
    draw_set_alpha(back_hover ? 1 : 0.5);
    draw_text_transformed(x0, top + 10, back_txt, 0.65, 0.65, 0);
    draw_set_alpha(1);
    if (click && back_hover) menu_state = "main";

    // ========================================================
    // COLUMNA IZQUIERDA
    // ========================================================

    // ── HEROE ──
    var hy = top + 32;
    var hh = 215;
    ctf_ui_cut(x0, hy, colw, hh, 20, C_TINTA, 1, false);
    ctf_ui_cut(x0, hy, colw, hh, 20, C_AZUL, 0.07, false);
    ctf_ui_cut(x0, hy, colw, hh, 20, C_GRIS, 0.15, true);

    // Avatar con anillo pulsante
    var ax = x0 + colw / 2;
    var ay = hy + 28 + 45;
    var ar = 45;
    var _p = 0.5 + 0.5 * sin(current_time / 318);
    draw_set_color(C_TINTA); draw_set_alpha(1);
    draw_circle(ax, ay, ar, false);
    draw_set_color(C_AZUL); draw_set_alpha(0.08);
    draw_circle(ax, ay, ar, false);
    draw_set_alpha(0.4 - 0.3 * _p);
    draw_circle(ax, ay, (ar + 5) * (1 + 0.08 * _p), true);
    draw_set_alpha(0.15);
    draw_circle(ax, ay, ar + 2, true);
    draw_set_alpha(1);
    draw_circle(ax, ay, ar, true);
    draw_circle(ax, ay, ar - 1, true);
    if (sprite_exists(spr_player_icon)) {
        draw_sprite_ext(spr_player_icon, global.avatar_id, ax, ay, 5, 5, 0, c_white, 1);
    }

    // Nombre
    draw_set_font(fnt_menu);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_color(c_white);
    var cursor = (input_activo && (current_time mod 600 < 300)) ? "|" : "";
    var _nm = ctf_ui_fit(string_upper(global.myName), colw - 40, 1.0);
    draw_text_transformed(ax, hy + 140, _nm + cursor, 1.0, 1.0, 0);

    // Chips: nivel, rol, liga
    var rol = "NOOB";
    var rol_col = C_GRIS;
    if (global.flags_captured > global.flags_returned + 2) { rol = "ASALTANTE"; rol_col = C_VERDE; }
    else if (global.flags_returned > global.flags_captured + 2) { rol = "DEFENSOR"; rol_col = C_AZUL; }

    var chip_txt = ["LVL " + string(global.lvl), rol, "LIGA " + string_upper(string(global.rank)) + " - " + string(global.copas) + " COPAS"];
    var chip_col = [C_ORO, rol_col, C_ROJO];
    var chip_sc  = 0.6;
    draw_set_font(fnt_small);
    var chip_w = [0, 0, 0];
    var chip_tot = 0;
    for (var c = 0; c < 3; c++) {
        chip_w[c] = string_width(chip_txt[c]) * chip_sc + 28;
        chip_tot += chip_w[c] + ((c > 0) ? 8 : 0);
    }
    var chx = ax - chip_tot / 2;
    var chy = hy + 165;
    for (var c2 = 0; c2 < 3; c2++) {
        ctf_ui_para(chx, chy, chip_w[c2], 22, 6, chip_col[c2], 0.1, false);
        ctf_ui_para(chx, chy, chip_w[c2], 22, 6, chip_col[c2], 0.4, true);
        draw_set_color(chip_col[c2]);
        draw_set_halign(fa_center);
        draw_text_transformed(chx + chip_w[c2] / 2, chy + 11, chip_txt[c2], chip_sc, chip_sc, 0);
        chx += chip_w[c2] + 8;
    }

    // Ayuda
    if (input_activo) {
        draw_set_color(C_ORO); draw_set_alpha(0.9);
        draw_text_transformed(ax, hy + 200, "ESCRIBE TU NOMBRE  -  [ENTER] GUARDAR", 0.55, 0.55, 0);
    } else {
        // Dos botoncitos tocables
        var _pbw = 170; var _pbh = 24; var _pby = hy + 188;
        var _pbx = [ax - _pbw - 6, ax + 6];
        var _pbt = [touch_mode() ? "EDITAR NOMBRE" : "[E] EDITAR NOMBRE", touch_mode() ? "CAMBIAR ICONO" : "[A] CAMBIAR ICONO"];
        var _pbk = [ord("E"), ord("A")];
        for (var _pb = 0; _pb < 2; _pb++) {
            var _ph = point_in_rectangle(mx, my, _pbx[_pb], _pby, _pbx[_pb] + _pbw, _pby + _pbh);
            ctf_ui_para(_pbx[_pb], _pby, _pbw, _pbh, 6, C_AZUL, _ph ? 0.18 : 0.06, false);
            ctf_ui_para(_pbx[_pb], _pby, _pbw, _pbh, 6, C_AZUL, _ph ? 0.9 : 0.35, true);
            draw_set_color(_ph ? C_AZUL : C_GRIS);
            draw_text_transformed(_pbx[_pb] + _pbw / 2, _pby + _pbh / 2, _pbt[_pb], 0.5, 0.5, 0);
            // El toque se registra en coordenadas de pantalla
            if (!mostrando_selector) ui_tap_add(ox + _pbx[_pb] * k, oy + _pby * k, ox + (_pbx[_pb] + _pbw) * k, oy + (_pby + _pbh) * k, -1, _pbk[_pb]);
        }
    }
    draw_set_alpha(1);

    // ── BLOQUE ID ──
    var iy = hy + hh + 12;
    var ih = 64;
    draw_set_color(c_black); draw_set_alpha(0.3);
    draw_rectangle(x0, iy, x0 + colw, iy + ih, false);
    draw_set_color(C_GRIS); draw_set_alpha(0.12);
    draw_rectangle(x0, iy, x0 + colw, iy + ih, true);
    draw_set_alpha(0.4);
    draw_set_halign(fa_left);
    draw_text_transformed(x0 + 16, iy + 15, "ID DE JUGADOR", 0.5, 0.5, 0);
    draw_set_alpha(1);

    var cbw = 140; var cbh = 30;
    var cbx = x0 + colw - 16 - cbw;
    var cby = iy + 25;
    var copied = (copiado_timer > 0);
    if (copiado_timer > 0) copiado_timer--;
    var c_hover = point_in_rectangle(mx, my, cbx, cby, cbx + cbw, cby + cbh);
    var cb_col = copied ? C_VERDE : C_ORO;
    ctf_ui_para(cbx, cby, cbw, cbh, 6, cb_col, (c_hover && !copied) ? 0.15 : 0.07, false);
    ctf_ui_para(cbx, cby, cbw, cbh, 6, cb_col, copied ? 0.7 : 0.4, true);
    draw_set_color(cb_col);
    draw_set_halign(fa_center);
    draw_text_transformed(cbx + cbw / 2, cby + cbh / 2, copied ? "[ COPIADO! ]" : "[ COPIAR ID ]", 0.6, 0.6, 0);
    if (click && c_hover) {
        clipboard_set_text(string(global.miFriendTag));
        copiado_timer = 120;
    }

    draw_set_color(C_ORO);
    draw_set_halign(fa_left);
    draw_text_transformed(x0 + 16, cby + cbh / 2, ctf_ui_fit(string(global.miFriendTag), cbx - x0 - 32, 0.8), 0.8, 0.8, 0);

    // ── ESTADISTICAS (2 x 3) ──
    var sy = iy + ih + 12;
    var rows = 3;
    var cell_h = 56;
    var sh = 32 + rows * cell_h;
    ctf_ui_section(x0, sy, colw, sh, "ESTADISTICAS", C_AZUL, C_GRIS);

    var st_lbl = ["CAPTURAS", "KILLS", "VICTORIAS", "PARTIDAS", "DEVUELTAS", "DERROTAS"];
    var st_val = [global.flags_captured, global.kills, global.wins, global.wins + global.losses, global.flags_returned, global.losses];
    var st_col = [C_AZUL, c_white, C_ROJO, c_white, C_AZUL, c_white];
    var cw = colw / 2;
    draw_set_color(C_GRIS); draw_set_alpha(0.08);
    draw_line(x0 + cw, sy + 32, x0 + cw, sy + sh);
    for (var r = 1; r < rows; r++) draw_line(x0, sy + 32 + r * cell_h, x0 + colw, sy + 32 + r * cell_h);
    draw_set_alpha(1);
    for (var s = 0; s < 6; s++) {
        var _cx = x0 + (s mod 2) * cw + 18;
        var _cy = sy + 32 + floor(s / 2) * cell_h;
        draw_set_halign(fa_left);
        draw_set_valign(fa_middle);
        draw_set_font(fnt_menu);
        draw_set_color(st_col[s]);
        draw_text_transformed(_cx, _cy + 21, string(st_val[s]), 0.8, 0.8, 0);
        draw_set_font(fnt_small);
        draw_set_color(C_GRIS); draw_set_alpha(0.45);
        draw_text_transformed(_cx, _cy + 42, st_lbl[s], 0.5, 0.5, 0);
        draw_set_alpha(1);
    }

    // ── PROGRESO XP ──
    var xy = sy + sh + 12;
    var xh = 32 + 56;
    ctf_ui_section(x0, xy, colw, xh, "PROGRESO", C_AZUL, C_GRIS);
    draw_set_font(fnt_small);
    draw_set_valign(fa_middle);
    draw_set_halign(fa_left);
    draw_set_color(C_GRIS); draw_set_alpha(0.6);
    draw_text_transformed(x0 + 16, xy + 32 + 18, "NIVEL " + string(global.lvl) + " > " + string(global.lvl + 1), 0.6, 0.6, 0);
    draw_set_alpha(1);
    draw_set_halign(fa_right);
    draw_set_color(C_ORO);
    draw_text_transformed(x0 + colw - 16, xy + 32 + 18, string(global.xp) + " / " + string(scr_xp_necesaria(global.lvl)) + " XP", 0.6, 0.6, 0);

    var tx = x0 + 16;
    var tw = colw - 32;
    var ty = xy + 32 + 34;
    draw_set_color(C_GRIS); draw_set_alpha(0.1);
    draw_rectangle(tx, ty, tx + tw, ty + 6, false);
    draw_set_alpha(1);
    var fw = tw * clamp(global.xp / scr_xp_necesaria(global.lvl), 0, 1);
    if (fw > 1) {
        var segs = 40;
        var shine = ((current_time mod 2000) / 2000) * (fw + 60) - 30;
        for (var g = 0; g < segs; g++) {
            var _t = g / segs;
            var _x = tx + _t * fw;
            var _w = fw / segs + 1;
            draw_set_alpha(1);
            draw_set_color(merge_colour(C_AZUL, C_ORO, _t));
            draw_rectangle(_x, ty, min(_x + _w, tx + fw), ty + 6, false);
            var _d = abs((_x + _w / 2) - (tx + shine));
            var _sa = 0.3 * max(0, 1 - _d / 30);
            if (_sa > 0) {
                draw_set_color(c_white); draw_set_alpha(_sa);
                draw_rectangle(_x, ty, min(_x + _w, tx + fw), ty + 6, false);
            }
        }
        draw_set_alpha(1);
    }

    // ========================================================
    // COLUMNA DERECHA: LOGROS
    // ========================================================
    var ach = [];
    var table = scr_logros_lista_map();   // la misma lista, ahora del juego (DatabaseFunctions, LOGROS)
    if (!is_undefined(table)) {
        var tsz = ds_map_size(table);
        for (var a = 0; a < tsz; a++) {
            var inf = ds_map_find_value(table, string(a + 1));
            if (is_undefined(inf)) continue;
            array_push(ach, {
                nombre: string(ds_map_find_value(inf, "name")),
                desc:   string(ds_map_find_value(inf, "descrip")),
                img:    real(ds_map_find_value(inf, "value")),
                ide:    ds_map_find_value(inf, "ide")
            });
        }
    }
    if (array_length(ach) == 0) {
        var ids = ["EDfBTkqW", "bQlLwO0e", "Mgt4bwuS", "wpMbRYcU", "lJjtqUBp", "K4ynEN93", "54FbyQ8N", "Y8c81dy3", "Zm9IBCfG", "JkLFQ8yq"];
        for (var a2 = 0; a2 < array_length(ids); a2++) {
            array_push(ach, { nombre: "LOGRO " + string(a2 + 1), desc: "", img: a2, ide: ids[a2] });
        }
    }

    var total_ach = array_length(ach);
    var rh = 48;
    var max_rows = floor((H - 32 - 32 - 32) / rh);
    var show_n = min(total_ach, max_rows);
    var obtained = 0;
    for (var a3 = 0; a3 < total_ach; a3++) {
        if (scr_logro_tiene(ach[a3].ide)) obtained++;
    }

    var lyy = top + 32;
    var lh = 32 + show_n * rh + 32;
    ctf_ui_section(x1, lyy, colw, lh, "LOGROS", C_AZUL, C_GRIS);

    var ic_cols = [C_ORO, C_AZUL, C_ROJO];
    for (var a4 = 0; a4 < show_n; a4++) {
        var ry = lyy + 32 + a4 * rh;
        var got = scr_logro_tiene(ach[a4].ide);

        if (a4 > 0) {
            draw_set_color(C_GRIS); draw_set_alpha(0.08);
            draw_line(x1, ry, x1 + colw, ry);
            draw_set_alpha(1);
        }

        // Icono
        var icx = x1 + 16;
        var icy = ry + 6;
        var icc = got ? ic_cols[a4 mod 3] : C_GRIS;
        ctf_ui_para(icx, icy, 46, 36, 6, icc, got ? 0.08 : 0.03, false);
        ctf_ui_para(icx, icy, 46, 36, 6, icc, got ? 0.45 : 0.15, true);
        if (sprite_exists(spr_achievements_images)) {
            draw_sprite_ext(spr_achievements_images, ach[a4].img, icx + 23 - 16, icy + 18 - 16, 1, 1, 0, got ? c_white : c_gray, got ? 1 : 0.3);
        }

        // Nombre y descripcion
        var tx2 = x1 + 76;
        var maxw = colw - 76 - 110;
        draw_set_font(fnt_small);
        draw_set_halign(fa_left);
        draw_set_valign(fa_middle);
        draw_set_color(got ? c_white : C_GRIS);
        draw_set_alpha(got ? 1 : 0.4);
        draw_text_transformed(tx2, ry + 17, ctf_ui_fit(string_upper(ach[a4].nombre), maxw, 0.65), 0.65, 0.65, 0);
        draw_set_color(C_GRIS); draw_set_alpha(0.4);
        draw_text_transformed(tx2, ry + 33, ctf_ui_fit(ach[a4].desc, maxw, 0.5), 0.5, 0.5, 0);
        draw_set_alpha(1);

        // Estado
        draw_set_halign(fa_right);
        if (got) { draw_set_color(C_VERDE); draw_set_alpha(1); }
        else     { draw_set_color(C_GRIS);  draw_set_alpha(0.4); }
        draw_text_transformed(x1 + colw - 16, ry + 24, got ? "LOGRADO" : "BLOQUEADO", 0.55, 0.55, 0);
        draw_set_alpha(1);
    }

    // Pie de logros
    var fy = lyy + 32 + show_n * rh;
    draw_set_color(C_GRIS); draw_set_alpha(0.08);
    draw_line(x1, fy, x1 + colw, fy);
    draw_set_alpha(1);
    var cnt_txt = string(obtained) + " / " + string(total_ach);
    draw_set_halign(fa_right);
    draw_set_valign(fa_middle);
    draw_set_color(C_ORO);
    draw_text_transformed(x1 + colw - 16, fy + 16, cnt_txt, 0.55, 0.55, 0);
    draw_set_color(C_GRIS); draw_set_alpha(0.4);
    draw_text_transformed(x1 + colw - 16 - string_width(cnt_txt) * 0.55 - 6, fy + 16, "LOGROS DESBLOQUEADOS:", 0.55, 0.55, 0);
    draw_set_alpha(1);

    // ========================================================
    // SELECTOR DE AVATAR (POPUP)
    // ========================================================
    // Volver a la escala normal (el selector se dibuja sobre toda la pantalla)
    matrix_set(matrix_world, matrix_build_identity());

    if (oMenu.mostrando_selector) {
        var vx = gw / 2; var vy = gh / 2;
        var vw = 600; var vh = 450;

        draw_set_color(c_black); draw_set_alpha(0.85);
        draw_rectangle(0, 0, gw, gh, false);
        draw_set_alpha(1);
        ctf_ui_cut(vx - vw / 2, vy - vh / 2, vw, vh, 24, C_TINTA, 1, false);
        ctf_ui_cut(vx - vw / 2, vy - vh / 2, vw, vh, 24, C_AZUL, 0.06, false);
        ctf_ui_cut(vx - vw / 2, vy - vh / 2, vw, vh, 24, C_AZUL, 0.6, true);

        draw_set_color(C_ORO);
        draw_set_font(fnt_menu);
        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);
        draw_text_transformed(vx, vy - vh / 2 + 30, "ELIGE TU ICONO", 0.9, 0.9, 0);

        var area_x = vx - 250;
        var area_y = vy - 130;
        var area_w = 500;
        var area_h = 240;

        var surf = surface_create(area_w, area_h);
        if (surface_exists(surf)) {
            surface_set_target(surf);
            draw_clear_alpha(c_black, 0);

            var total_iconos = sprite_get_number(spr_player_icon);
            var columnas = 4;
            var separacion = 120;

            oMenu.scroll_y = lerp(oMenu.scroll_y, oMenu.scroll_y_target, 0.2);

            for (var i = 0; i < total_iconos; i++) {
                var col_i  = i mod columnas;
                var fila   = floor(i / columnas);
                var icon_x = (col_i * separacion) + 70;
                var icon_y = (fila * separacion) + 60 - oMenu.scroll_y;

                if (icon_y > -100 && icon_y < area_h + 100) {
                    var lock = !scr_check_icon_unlocked(i);
                    if (oMenu.avatar_seleccionado == i) {
                        draw_set_color(C_ORO); draw_set_alpha(0.25);
                        draw_rectangle(icon_x - 48, icon_y - 48, icon_x + 48, icon_y + 48, false);
                        draw_set_alpha(1);
                        draw_rectangle(icon_x - 48, icon_y - 48, icon_x + 48, icon_y + 48, true);
                    }
                    draw_sprite_ext(spr_player_icon, i, icon_x, icon_y, 4, 4, 0, lock ? c_black : c_white, lock ? 0.3 : 1);
                    // Toque sobre el icono (recortado al area visible)
                    var _tx1 = area_x + max(0, icon_x - 48); var _ty1 = area_y + max(0, icon_y - 48);
                    var _tx2 = area_x + min(area_w, icon_x + 48); var _ty2 = area_y + min(area_h, icon_y + 48);
                    if (_ty2 > _ty1 && _tx2 > _tx1) ui_tap_add(_tx1, _ty1, _tx2, _ty2, -1, -1, { tipo: "avatar", i: i });
                    if (lock) {
                        draw_set_color(C_ROJO);
                        draw_set_font(fnt_menu);
                        draw_set_halign(fa_center);
                        draw_text_transformed(icon_x, icon_y + 35, "LOCK", 0.6, 0.6, 0);
                    }
                }
            }

            surface_reset_target();
            draw_surface(surf, area_x, area_y);
            surface_free(surf);
        }

        var info_reto = "REQUISITO: ";
        switch (avatar_seleccionado) {
            case 0: case 1: info_reto += "INICIAL"; break;
            case 2: info_reto += "CONSIGUE 100 KILLS"; break;
            case 3: info_reto += "GANA 10 PARTIDAS"; break;
            default: info_reto += "LOGRO SECRETO"; break;
        }
        draw_set_color(C_ORO);
        draw_set_font(fnt_menu);
        draw_set_halign(fa_center);
        draw_text_transformed(vx, vy + 145, info_reto, 0.6, 0.6, 0);

        // Botones CONFIRMAR / CANCELAR (tocables)
        var _sbw = 210; var _sbh = 40; var _sby = vy + 163;
        var _sbx = [vx - _sbw - 10, vx + 10];
        var _sbt = [touch_mode() ? "CONFIRMAR" : "[ENTER] CONFIRMAR", touch_mode() ? "CANCELAR" : "[ESC] CANCELAR"];
        var _sbc = [C_VERDE, C_GRIS];
        var _sbk = [vk_enter, vk_escape];
        draw_set_font(fnt_small);
        for (var _sb = 0; _sb < 2; _sb++) {
            ctf_ui_para(_sbx[_sb], _sby, _sbw, _sbh, 8, _sbc[_sb], 0.1, false);
            ctf_ui_para(_sbx[_sb], _sby, _sbw, _sbh, 8, _sbc[_sb], 0.6, true);
            draw_set_color(_sbc[_sb]);
            draw_text_transformed(_sbx[_sb] + _sbw / 2, _sby + _sbh / 2, _sbt[_sb], 0.65, 0.65, 0);
            ui_tap_add(_sbx[_sb], _sby, _sbx[_sb] + _sbw, _sby + _sbh, -1, _sbk[_sb]);
        }
    }

    // Dejar el estado de dibujo como estaba antes
    draw_set_alpha(1);
    draw_set_color(c_white);
    draw_set_font(fnt_menu);
    draw_set_halign(fa_center);
    draw_set_valign(fa_top);
}

// ── AYUDANTES DE DIBUJO ──────────────────────────────────────

// Fondo oscuro completo: cuadricula, brillo azul y rojo, lineas de scan
function ctf_ui_fondo(_w, _h) {
    if (MN_NUEVO) { __mn_fondo_wh(_w, _h); return; }   // estetica nueva (menu nuevo)
    var _tinta = make_color_rgb(11, 15, 26);
    var _azul  = make_color_rgb(31, 155, 255);
    var _rojo  = make_color_rgb(255, 42, 58);
    draw_set_alpha(1);
    draw_set_color(_tinta);
    draw_rectangle(0, 0, _w, _h, false);

    var _r = max(_w, _h) * 0.45;
    draw_set_alpha(0.13);
    draw_circle_colour(_w * 0.2, _h * 0.15, _r, _azul, _tinta, false);
    draw_set_alpha(0.09);
    draw_circle_colour(_w * 0.85, _h * 0.9, _r, _rojo, _tinta, false);

    var _g = 40 * clamp(min(_w / 1280, _h / 720), 0.6, 1.6);
    draw_set_color(_azul);
    draw_set_alpha(0.045);
    for (var _x = 0; _x < _w; _x += _g) draw_line(_x, 0, _x, _h);
    for (var _y = 0; _y < _h; _y += _g) draw_line(0, _y, _w, _y);

    draw_set_color(c_black);
    draw_set_alpha(0.05);
    for (var _y2 = 0; _y2 < _h; _y2 += 4) draw_line(0, _y2, _w, _y2);
    draw_set_alpha(1);
}

// Rectangulo con la esquina inferior derecha cortada
function ctf_ui_cut(_x, _y, _w, _h, _c, _col, _a, _outline) {
    if (MN_NUEVO) { __mn_redondo(_x, _y, _w, _h, _col, _a, _outline, true); return; }   // estetica nueva
    draw_set_color(_col);
    draw_set_alpha(_a);
    if (_outline) draw_primitive_begin(pr_linestrip);
    else draw_primitive_begin(pr_trianglefan);
    draw_vertex(_x, _y);
    draw_vertex(_x + _w, _y);
    draw_vertex(_x + _w, _y + _h - _c);
    draw_vertex(_x + _w - _c, _y + _h);
    draw_vertex(_x, _y + _h);
    if (_outline) draw_vertex(_x, _y);
    draw_primitive_end();
    draw_set_alpha(1);
}

// Paralelogramo (borde de arriba corrido a la derecha)
function ctf_ui_para(_x, _y, _w, _h, _s, _col, _a, _outline) {
    if (MN_NUEVO) { __mn_redondo(_x, _y, _w, _h, _col, _a, _outline, false); return; }   // estetica nueva
    draw_set_color(_col);
    draw_set_alpha(_a);
    if (_outline) draw_primitive_begin(pr_linestrip);
    else draw_primitive_begin(pr_trianglefan);
    draw_vertex(_x + _s, _y);
    draw_vertex(_x + _w, _y);
    draw_vertex(_x + _w - _s, _y + _h);
    draw_vertex(_x, _y + _h);
    if (_outline) draw_vertex(_x + _s, _y);
    draw_primitive_end();
    draw_set_alpha(1);
}

// Caja de seccion con barra de titulo
function ctf_ui_section(_x, _y, _w, _h, _titulo, _acento, _gris) {
    if (MN_NUEVO) {
        // Panel redondo con su titulo (estetica nueva)
        __mn_redondo(_x, _y, _w, _h, make_color_rgb(11, 15, 26), 1, false, true);
        __mn_redondo(_x, _y, _w, _h, make_color_rgb(11, 15, 26), 1, true, true);
        draw_set_color(_acento);
        draw_roundrect_ext(_x + 14, _y + 9, _x + 19, _y + 23, 2, 2, false);
        draw_set_font(fnt_small);
        draw_set_halign(fa_left);
        draw_set_valign(fa_middle);
        draw_set_color(make_color_rgb(255, 212, 71));
        draw_text_transformed(_x + 28, _y + 16, _titulo, 0.6, 0.6, 0);
        draw_set_color(c_white);
        return;
    }
    draw_set_color(_gris);
    draw_set_alpha(0.04);
    draw_rectangle(_x, _y, _x + _w, _y + 32, false);
    draw_set_alpha(0.1);
    draw_rectangle(_x, _y, _x + _w, _y + _h, true);
    draw_set_alpha(0.08);
    draw_line(_x, _y + 32, _x + _w, _y + 32);
    draw_set_alpha(1);
    draw_set_color(_acento);
    draw_rectangle(_x + 16, _y + 10, _x + 18, _y + 22, false);
    draw_set_font(fnt_small);
    draw_set_halign(fa_left);
    draw_set_valign(fa_middle);
    draw_set_color(_gris);
    draw_set_alpha(0.55);
    draw_text_transformed(_x + 28, _y + 16, _titulo, 0.55, 0.55, 0);
    draw_set_alpha(1);
}

// Recorta un texto para que quepa en un ancho (agrega "..")
function ctf_ui_fit(_txt, _maxw, _sc) {
    if (string_width(_txt) * _sc <= _maxw) return _txt;
    while (string_length(_txt) > 1 && string_width(_txt + "..") * _sc > _maxw) {
        _txt = string_copy(_txt, 1, string_length(_txt) - 1);
    }
    return _txt + "..";
}

// Version vieja: se deja por si algo mas la llama
function draw_stats_box(_x, _y, _label, _val, _col) {
    var _w = 85;
    var _h = 38;
    draw_set_alpha(0.15); draw_set_color(_col);
    draw_rectangle(_x - _w, _y - _h, _x + _w, _y + _h, false);
    draw_set_alpha(1); draw_set_color(_col);
    draw_rectangle(_x - _w, _y - _h, _x + _w, _y + _h, true);
    draw_set_color(c_gray);
    draw_text_transformed(_x, _y - 22, _label, 0.55, 0.55, 0);
    draw_set_color(c_white);
    draw_text_transformed(_x, _y + 8, string(_val), 1.1, 1.1, 0);
}

// Titulo de pantalla: texto grande con brillo azul + subtitulo dorado + linea
// Devuelve la Y donde termina (para poner el contenido debajo)
function ctf_ui_header(_w, _titulo, _sub, _u) {
    if (MN_NUEVO) {
        // Titulo grande con sombra (estetica nueva)
        var _ny = 58 * _u;
        var _ns = 1.35 * _u;
        draw_set_font(fnt_menu);
        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);
        draw_set_color(c_black);
        draw_set_alpha(0.75);
        draw_text_transformed(_w / 2 + 3 * _u, _ny + 4 * _u, _titulo, _ns, _ns, 0);
        draw_set_alpha(1);
        draw_set_color(c_white);
        draw_text_transformed(_w / 2, _ny, _titulo, _ns, _ns, 0);
        _ny += 26 * _u;
        if (_sub != "") {
            draw_set_font(fnt_small);
            draw_set_color(make_color_rgb(255, 212, 71));
            draw_text_transformed(_w / 2, _ny + 6 * _u, _sub, 0.65 * _u, 0.65 * _u, 0);
            _ny += 22 * _u;
        }
        draw_set_color(c_white);
        return _ny + 24 * _u;
    }
    var _azul = make_color_rgb(31, 155, 255);
    var _rojo = make_color_rgb(255, 42, 58);
    var _oro  = make_color_rgb(255, 212, 71);
    var _cx = _w / 2;
    var _y  = 58 * _u;
    var _sc = 1.25 * _u;
    draw_set_font(fnt_menu);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_color(_azul);
    draw_set_alpha(0.22);
    draw_text_transformed(_cx - 2, _y, _titulo, _sc, _sc, 0);
    draw_text_transformed(_cx + 2, _y, _titulo, _sc, _sc, 0);
    draw_text_transformed(_cx, _y - 2, _titulo, _sc, _sc, 0);
    draw_text_transformed(_cx, _y + 2, _titulo, _sc, _sc, 0);
    draw_set_alpha(1);
    draw_set_color(c_white);
    draw_text_transformed(_cx, _y, _titulo, _sc, _sc, 0);
    _y += 26 * _u;
    if (_sub != "") {
        draw_set_font(fnt_small);
        draw_set_color(_oro);
        draw_text_transformed(_cx, _y + 6 * _u, _sub, 0.65 * _u, 0.65 * _u, 0);
        _y += 22 * _u;
    }
    var _dw = 220 * _u;
    for (var _s = 0; _s < 44; _s++) {
        var _t = _s / 43;
        draw_set_color(merge_colour(_azul, _rojo, _t));
        draw_set_alpha(min(1, sin(pi * _t) * 1.6));
        var _sx = _cx - _dw / 2 + _t * _dw;
        draw_rectangle(_sx, _y, _sx + _dw / 44 + 1, _y + 1, false);
    }
    draw_set_alpha(1);
    return _y + 24 * _u;
}

// Lista de botones paralelogramo (como el menu principal). Devuelve la Y final.
function ctf_ui_lista(_cx, _y, _ops, _sel, _u, _valores = []) {
    var _tinta = make_color_rgb(11, 15, 26);
    var _azul  = make_color_rgb(31, 155, 255);
    var _gris  = make_color_rgb(169, 180, 208);
    var _n  = array_length(_ops);
    var _sc = 0.72 * _u;
    draw_set_font(fnt_menu);
    var _w = 320 * _u;
    for (var i = 0; i < _n; i++) _w = max(_w, string_width(string_upper(string(_ops[i]))) * _sc + 100 * _u);
    var _h  = 46 * _u;
    var _g  = 10 * _u;
    var _sk = 10 * _u;
    var _L  = _cx - _w / 2;
    var _R  = _cx + _w / 2;
    for (var j = 0; j < _n; j++) {
        var _T = _y + j * (_h + _g);
        var _on = (j == _sel);
        ctf_ui_para(_L, _T, _w, _h, _sk, _tinta, 0.85, false);
        if (_on) ctf_ui_para(_L, _T, _w, _h, _sk, _azul, 0.12, false);
        ctf_ui_para(_L, _T, _w, _h, _sk, _on ? _azul : _gris, _on ? 1 : 0.22, true);
        if (_on) ctf_ui_para(_L, _T, _sk + 3, _h, _sk, _azul, 1, false);
        var _es_valor = false;
        for (var v = 0; v < array_length(_valores); v++) if (_valores[v] == j) _es_valor = true;

        draw_set_font(fnt_menu);
        draw_set_valign(fa_middle);
        draw_set_color(_on ? _azul : _gris);
        if (_es_valor) {
            // Opcion con valor: < TEXTO >  (tocar la izquierda baja, la derecha sube)
            draw_set_halign(fa_center);
            draw_text_transformed(_cx, _T + _h / 2, string_upper(string(_ops[j])), _sc, _sc, 0);
            draw_set_alpha(_on ? 1 : 0.4);
            draw_set_halign(fa_left);
            draw_text_transformed(_L + _sk + 14 * _u, _T + _h / 2, "<", _sc, _sc, 0);
            draw_set_halign(fa_right);
            draw_text_transformed(_R - _sk - 14 * _u, _T + _h / 2, ">", _sc, _sc, 0);
            draw_set_alpha(1);
            ui_tap_add(_L, _T, _L + _w * 0.35, _T + _h, j, vk_left);
            ui_tap_add(_L + _w * 0.35, _T, _R, _T + _h, j, vk_right);
        } else {
            draw_set_halign(fa_left);
            draw_text_transformed(_L + 28 * _u, _T + _h / 2, string_upper(string(_ops[j])), _sc, _sc, 0);
            draw_set_halign(fa_right);
            draw_set_alpha(_on ? 1 : 0.4);
            draw_text_transformed(_R - _sk - 18 * _u, _T + _h / 2, ">", _sc, _sc, 0);
            draw_set_alpha(1);
            ui_tap_add(_L, _T, _R, _T + _h, j, vk_enter);
        }
    }
    return _y + _n * (_h + _g);
}

// Panel oscuro con esquina cortada y linea de color arriba
function ctf_ui_panel(_x1, _y1, _x2, _y2, _acento) {
    if (MN_NUEVO) {
        // Panel redondo oscuro con borde y una rayita de color arriba (estetica nueva)
        __mn_redondo(_x1, _y1, _x2 - _x1, _y2 - _y1, make_color_rgb(11, 15, 26), 1, false, true);
        __mn_redondo(_x1, _y1, _x2 - _x1, _y2 - _y1, make_color_rgb(11, 15, 26), 1, true, true);
        draw_set_color(_acento);
        draw_roundrect_ext(_x1 + 16, _y1 - 3, _x1 + 96, _y1 + 3, 3, 3, false);
        draw_set_color(c_white);
        return;
    }
    var _tinta = make_color_rgb(11, 15, 26);
    var _gris  = make_color_rgb(169, 180, 208);
    ctf_ui_cut(_x1, _y1, _x2 - _x1, _y2 - _y1, 18, _tinta, 0.92, false);
    ctf_ui_cut(_x1, _y1, _x2 - _x1, _y2 - _y1, 18, _acento, 0.05, false);
    ctf_ui_cut(_x1, _y1, _x2 - _x1, _y2 - _y1, 18, _gris, 0.18, true);
    draw_set_color(_acento);
    draw_rectangle(_x1, _y1, _x1 + 70, _y1 + 2, false);
}

// Texto de ayuda chiquito abajo
function ctf_ui_hint(_x, _y, _txt, _u) {
    if (touch_mode() && string_pos("[", _txt) > 0) _txt = "TOCA UNA OPCION     -     ATRAS PARA VOLVER";
    draw_set_font(fnt_small);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_color(make_color_rgb(169, 180, 208));
    draw_set_alpha(0.5);
    draw_text_transformed(_x, _y, _txt, 0.6 * _u, 0.6 * _u, 0);
    draw_set_alpha(1);
}

// ======================================================
// MENU NUEVO (estilo Brawl Stars)
//   "main"   : menu principal (botones a la izquierda, tu personaje, SALA PRIVADA y JUGAR)
//   "modos"  : pestanas PARTIDA RAPIDA / SALA PRIVADA / SIN INTERNET + tarjetas de modos
//   "tamano" : cuantos jugadores (1 VS 1 ... 4 VS 4)
// Se dibuja en una hoja de 720x405 que se agranda a la pantalla (PC, celular y HTML5).
// Lleva a las pantallas de siempre: "connecting" (partida rapida), "setup_room" (crear sala),
// "join_code" (unirse), "offline_setup" (sin internet), "equipo", "friends_menu", "ranking"...
// Para volver al menu viejo: MN_NUEVO en false.
// ======================================================
#macro MN_NUEVO true

function __mn_init() {
	if (variable_global_exists("mn_ui") && is_struct(global.mn_ui)) return;
	global.mn_ui = { S: 1, ox: 0, oy: 0, sel: 0, tab: 0, sub: 0, carta: 0, tam: 0, modo: 0, msg: "", msg_t: 0, abierto_t: 0 };
}
function __mn_geo() {
	var _q = global.mn_ui;
	var _gw = display_get_gui_width(), _gh = display_get_gui_height();
	_q.S = min(_gw / 720, _gh / 405);
	_q.ox = (_gw - 720 * _q.S) / 2;
	_q.oy = (_gh - 405 * _q.S) / 2;
}
function __mn_x(_x) { return global.mn_ui.ox + _x * global.mn_ui.S; }
function __mn_y(_y) { return global.mn_ui.oy + _y * global.mn_ui.S; }

// Colores
function __mn_col(_n) {
	switch (_n) {
		case "tinta":   return make_color_rgb(11, 15, 26);
		case "oro":     return make_color_rgb(255, 212, 71);
		case "azul":    return make_color_rgb(31, 155, 255);
		case "rojo":    return make_color_rgb(229, 72, 77);
		case "gris":    return make_color_rgb(169, 180, 208);
		case "verde":   return make_color_rgb(78, 220, 140);
		case "morado":  return make_color_rgb(160, 90, 255);
		case "cian":    return make_color_rgb(80, 220, 255);
		case "naranja": return make_color_rgb(255, 130, 40);
		case "rosa":    return make_color_rgb(240, 90, 170);
		case "boton":   return make_color_rgb(44, 54, 110);
		case "panel":   return make_color_rgb(20, 24, 50);
	}
	return c_white;
}
function __mn_osc(_c, _k) { return make_color_rgb(floor(colour_get_red(_c) * _k), floor(colour_get_green(_c) * _k), floor(colour_get_blue(_c) * _k)); }
function __mn_cla(_c) { return merge_colour(_c, c_white, 0.25); }

// --- Dibujo basico (todo en coordenadas de la hoja) ---
function __mn_rect(_x1, _y1, _x2, _y2, _r, _col, _a = 1, _borde = false) {
	draw_set_color(_col);
	draw_set_alpha(_a);
	var _S = global.mn_ui.S;
	draw_roundrect_ext(__mn_x(_x1), __mn_y(_y1), __mn_x(_x2), __mn_y(_y2), _r * _S, _r * _S, _borde);
	draw_set_alpha(1);
}
function __mn_txt(_x, _y, _s, _px, _col, _ha = fa_center, _sombra = true, _font = fnt_menu, _a = 1) {
	draw_set_font(_font);
	draw_set_halign(_ha);
	draw_set_valign(fa_middle);
	var _k = (_px * global.mn_ui.S) / max(1, string_height("A"));
	if (_sombra) {
		draw_set_color(c_black);
		draw_set_alpha(0.75 * _a);
		draw_text_transformed(__mn_x(_x) + 2 * global.mn_ui.S, __mn_y(_y) + 2.5 * global.mn_ui.S, _s, _k, _k, 0);
	}
	draw_set_color(_col);
	draw_set_alpha(_a);
	draw_text_transformed(__mn_x(_x), __mn_y(_y), _s, _k, _k, 0);
	draw_set_alpha(1);
}
/// Boton con relieve (sombra abajo, brillo arriba, borde oscuro)
function __mn_boton(_x1, _y1, _x2, _y2, _col, _txt, _px, _tc = c_white, _resalta = false, _r = 12) {
	__mn_rect(_x1, _y1 + 5, _x2, _y2 + 5, _r, __mn_osc(_col, 0.45), 1);
	__mn_rect(_x1, _y1, _x2, _y2, _r, _col, 1);
	__mn_rect(_x1 + 5, _y1 + 4, _x2 - 5, _y1 + (_y2 - _y1) * 0.42, _r * 0.6, __mn_cla(_col), 1);
	__mn_rect(_x1, _y1, _x2, _y2, _r, _resalta ? c_white : __mn_col("tinta"), 1, true);
	if (_resalta) __mn_rect(_x1 - 1, _y1 - 1, _x2 + 1, _y2 + 1, _r, c_white, 0.6 + 0.4 * sin(current_time / 160), true);
	if (_txt != "") __mn_txt((_x1 + _x2) / 2, (_y1 + _y2) / 2 + 1, _txt, _px, _tc, fa_center, _tc == c_white);
}
function __mn_dentro(_px, _py, _r) { return point_in_rectangle(_px, _py, _r[0], _r[1], _r[2], _r[3]); }

/// Fondo de toda la pantalla: degradado azul con rayas que se mueven
function __mn_fondo() {
	var _gw = display_get_gui_width(), _gh = display_get_gui_height();
	var _c1 = make_color_rgb(18, 22, 52), _c2 = make_color_rgb(38, 36, 62);
	draw_rectangle_colour(0, 0, _gw, _gh, _c1, _c1, _c2, _c2, false);
	var _S = global.mn_ui.S;
	var _paso = 60 * _S;
	var _off = ((current_time / 1000) * 30 * _S) mod _paso;
	draw_set_color(make_color_rgb(34, 40, 82));
	for (var _x = -_gh; _x < _gw + _paso; _x += _paso) draw_line_width(_x + _off, _gh, _x + _off + _gh, 0, 14 * _S);
	draw_set_color(c_white);
}

/// Dibujitos de los botones y tarjetas (_k = tamano)
function __mn_icono(_tipo, _cx, _cy, _k) {
	var _x = __mn_x(_cx), _y = __mn_y(_cy), _s = _k * global.mn_ui.S;
	var _bl = c_white, _ti = __mn_col("tinta");
	draw_set_color(_bl);
	switch (_tipo) {
		case "flag":
			draw_line_width(_x - 10 * _s, _y + 16 * _s, _x - 10 * _s, _y - 16 * _s, 3 * _s);
			draw_triangle(_x - 10 * _s, _y - 16 * _s, _x + 14 * _s, _y - 8 * _s, _x - 10 * _s, _y, false);
		break;
		case "bomb":
			draw_set_color(_ti); draw_circle(_x, _y + 4 * _s, 13 * _s, false);
			draw_set_color(_bl); draw_line_width(_x + 6 * _s, _y - 6 * _s, _x + 12 * _s, _y - 16 * _s, 3 * _s);
			if ((current_time div 125) mod 2 == 0) draw_circle(_x + 13 * _s, _y - 17 * _s, 4 * _s, false);
		break;
		case "grav":
			draw_triangle(_x, _y - 18 * _s, _x - 11 * _s, _y - 4 * _s, _x + 11 * _s, _y - 4 * _s, false);
			draw_set_color(_ti); draw_triangle(_x, _y + 18 * _s, _x - 11 * _s, _y + 4 * _s, _x + 11 * _s, _y + 4 * _s, false);
		break;
		case "aim":
			draw_circle(_x, _y, 15 * _s, true); draw_circle(_x, _y, 14 * _s, true);
			draw_line_width(_x - 20 * _s, _y, _x + 20 * _s, _y, 2 * _s); draw_line_width(_x, _y - 20 * _s, _x, _y + 20 * _s, 2 * _s);
		break;
		case "crown":
			draw_rectangle(_x - 16 * _s, _y, _x + 16 * _s, _y + 10 * _s, false);
			draw_triangle(_x - 16 * _s, _y, _x - 16 * _s, _y - 10 * _s, _x - 6 * _s, _y, false);
			draw_triangle(_x - 8 * _s, _y, _x, _y - 14 * _s, _x + 8 * _s, _y, false);
			draw_triangle(_x + 6 * _s, _y, _x + 16 * _s, _y - 10 * _s, _x + 16 * _s, _y, false);
		break;
		case "lava":
			draw_rectangle(_x - 16 * _s, _y + 2 * _s, _x + 16 * _s, _y + 14 * _s, false);
			for (var i = 0; i < 4; i++) draw_circle(_x - 12 * _s + i * 8 * _s, _y + 2 * _s + 2 * _s * sin(current_time / 200 + i), 4 * _s, false);
		break;
		case "llave":
			draw_circle(_x - 4 * _s, _y - 4 * _s, 7 * _s, true); draw_circle(_x - 4 * _s, _y - 4 * _s, 6 * _s, true);
			draw_line_width(_x + 1 * _s, _y + 1 * _s, _x + 10 * _s, _y + 10 * _s, 3 * _s);
		break;
		case "wifi_no":
			draw_circle(_x, _y + 8 * _s, 3 * _s, false);
			draw_line_width(_x - 14 * _s, _y + 14 * _s, _x + 14 * _s, _y - 14 * _s, 3 * _s);
		break;
		case "moneda":
			draw_set_color(__mn_col("oro")); draw_circle(_x, _y, 9 * _s, false);
			draw_set_color(make_color_rgb(214, 160, 30)); draw_circle(_x, _y, 5 * _s, false);
		break;
		case "copa":
			draw_set_color(__mn_col("oro"));
			draw_triangle(_x - 8 * _s, _y - 9 * _s, _x + 8 * _s, _y - 9 * _s, _x, _y + 3 * _s, false);
			draw_rectangle(_x - 8 * _s, _y - 9 * _s, _x + 8 * _s, _y - 3 * _s, false);
			draw_rectangle(_x - 2 * _s, _y + 1 * _s, _x + 2 * _s, _y + 6 * _s, false);
			draw_rectangle(_x - 6 * _s, _y + 6 * _s, _x + 6 * _s, _y + 9 * _s, false);
		break;
		case "skull":
			draw_circle(_x, _y - 3 * _s, 13 * _s, false);
			draw_rectangle(_x - 8 * _s, _y + 5 * _s, _x + 8 * _s, _y + 14 * _s, false);
			draw_set_color(_ti);
			draw_circle(_x - 5 * _s, _y - 3 * _s, 3.5 * _s, false); draw_circle(_x + 5 * _s, _y - 3 * _s, 3.5 * _s, false);
			draw_line_width(_x - 3 * _s, _y + 8 * _s, _x - 3 * _s, _y + 14 * _s, 2 * _s); draw_line_width(_x + 3 * _s, _y + 8 * _s, _x + 3 * _s, _y + 14 * _s, 2 * _s);
		break;
		case "star":
			for (var j = 0; j < 5; j++) {
				var _a1 = 90 + j * 72;
				draw_triangle(_x + lengthdir_x(16 * _s, _a1), _y + lengthdir_y(16 * _s, _a1),
				              _x + lengthdir_x(7 * _s, _a1 + 36), _y + lengthdir_y(7 * _s, _a1 + 36),
				              _x + lengthdir_x(7 * _s, _a1 - 36), _y + lengthdir_y(7 * _s, _a1 - 36), false);
			}
			draw_circle(_x, _y, 7 * _s, false);
		break;
		case "correo":
			draw_rectangle(_x - 11 * _s, _y - 8 * _s, _x + 11 * _s, _y + 8 * _s, false);
			draw_set_color(_ti); draw_line_width(_x - 11 * _s, _y - 8 * _s, _x, _y + 1 * _s, 2 * _s); draw_line_width(_x + 11 * _s, _y - 8 * _s, _x, _y + 1 * _s, 2 * _s);
		break;
	}
	draw_set_color(c_white);
}

// ------------------------------------------------------
// MENU PRINCIPAL
// ------------------------------------------------------
/// Botones del menu principal: [{r:[x1,y1,x2,y2], acc, txt, col, ico}]
function __mn_main_botones() {
	var _l = [];
	var _izq = [["EQUIPO", "equipo", "oro"], ["AMIGOS", "amigos", "verde"], ["RANKING", "ranking", "oro"],
	            ["LOGROS", "logros", "morado"], ["PERFIL", "perfil", "azul"], ["AJUSTES", "ajustes", "gris"]];
	for (var i = 0; i < array_length(_izq); i++) {
		var _y = 64 + i * 48;
		array_push(_l, { r: [12, _y, 150, _y + 38], acc: _izq[i][1], txt: _izq[i][0], col: _izq[i][2] });
	}
	// SALIR solo en PC (en el celular y en el navegador no hace falta)
	if (!touch_mode() && os_browser == browser_not_a_browser) array_push(_l, { r: [12, 356, 150, 386], acc: "salir", txt: "SALIR", col: "rojo" });
	array_push(_l, { r: [470, 210, 700, 252], acc: "privada", txt: "SALA PRIVADA", col: "morado" });
	array_push(_l, { r: [470, 262, 700, 296], acc: "jugar_modo", txt: "", col: "" });
	array_push(_l, { r: [470, 304, 700, 384], acc: "jugar", txt: "JUGAR", col: "oro" });
	array_push(_l, { r: [412, 10, 446, 40], acc: "correo", txt: "", col: "" });
	return _l;
}

/// Orden para moverse con el teclado
function __mn_main_orden() { return ["jugar", "privada", "equipo", "amigos", "ranking", "logros", "perfil", "ajustes"]; }

function __mn_hacer(_acc) {
	var _q = global.mn_ui;
	switch (_acc) {
		case "jugar":      menu_state = "modos"; _q.tab = 0; _q.carta = 0; break;
		case "jugar_modo": menu_state = "modos"; _q.tab = 0; _q.carta = 0; break;
		case "privada":    menu_state = "modos"; _q.tab = 1; _q.sub = 0; _q.carta = 0; break;
		case "equipo":     menu_state = "equipo"; scr_eq_abrir(); break;
		case "amigos":     menu_state = "friends_menu"; friends_index = 0; friends_state = "main"; break;
		case "ranking":    menu_state = "ranking"; scr_ranking_abrir(); break;
		case "logros":     menu_state = "achievements"; break;
		case "perfil":     menu_state = "profile"; break;
		case "ajustes":    menu_state = "options"; opt_sel = 0; break;
		case "correo":     menu_state = "mailbox"; break;
		case "salir":      game_end(); break;
	}
	_q.abierto_t = 0;
	menu_delay = 8;   // que el mismo toque o ENTER no haga nada en la pantalla nueva
	if (global.sfx) audio_play_sound(snd_scroll, 5, false, 0.5);
}

function __mn_msg(_t) {
	global.mn_ui.msg = _t;
	global.mn_ui.msg_t = 90;
	if (global.sfx) audio_play_sound(snd_empy, 5, false, 0.6);
}

/// Sprite del personaje elegido (para el menu)
function __mn_pj_sprite() {
	var _p = variable_global_exists("pj_selected") ? global.pj_selected : 0;
	switch (_p) {
		case 1: return spr_miguel_idle;
		case 2: return spr_marina_idle;
		case 3: return spr_sargento_idle;
	}
	return spr_player_idle;
}

function scr_mn_draw_main() {
	__mn_init(); __mn_geo();
	var _q = global.mn_ui;
	var _ti = __mn_col("tinta");
	__mn_fondo();
	var _px = (device_mouse_x_to_gui(0) - _q.ox) / _q.S, _py = (device_mouse_y_to_gui(0) - _q.oy) / _q.S;
	var _orden = __mn_main_orden();
	var _kb = !touch_mode() ? _orden[clamp(_q.sel, 0, array_length(_orden) - 1)] : "";

	// --- Barra de arriba: tu cuenta, correo, monedas y copas ---
	scr_cuenta_init();
	var _c = global.cuenta;
	__mn_rect(10, 8, 210, 44, 10, c_black, 0.75);
	__mn_rect(10, 8, 210, 44, 10, _c.entrado ? __mn_col("verde") : make_color_rgb(60, 70, 110), 1, true);
	__mn_rect(14, 12, 40, 40, 6, __mn_col("azul"));
	__mn_txt(27, 26, string_upper(string_char_at(string(global.myName), 1)), 14, c_white);
	__mn_txt(48, 19, string_upper(string_copy(string(global.myName), 1, 14)), 11, c_white, fa_left);
	__mn_txt(48, 34, _c.entrado ? ("NV " + string(global.lvl) + "  -  CUENTA") : ("NV " + string(global.lvl) + "  -  INVITADO >"), 8, _c.entrado ? __mn_col("verde") : __mn_col("gris"), fa_left, false);
	_c.chip = [__mn_x(10), __mn_y(8), __mn_x(210), __mn_y(44)];   // tocarlo abre ENTRAR / tu perfil (DatabaseFunctions)
	// Correo
	__mn_rect(412, 10, 446, 40, 8, c_black, 0.75);
	__mn_rect(412, 10, 446, 40, 8, make_color_rgb(60, 70, 110), 1, true);
	__mn_icono("correo", 429, 25, 0.8);
	if (hay_solicitud_pendiente) { draw_set_color(__mn_col("rojo")); draw_circle(__mn_x(444), __mn_y(12), (5 + 2 * abs(sin(current_time / 200))) * _q.S, false); }
	mail_x = __mn_x(429); mail_y = __mn_y(25);
	// Monedas y copas
	scr_eq_init();
	var _vals = [["moneda", string(global.equipo.monedas)], ["copa", string(variable_global_exists("copas") ? global.copas : 0)]];
	for (var i = 0; i < 2; i++) {
		var _x = 490 + i * 112;
		__mn_rect(_x, 10, _x + 104, 40, 10, c_black, 0.75);
		__mn_rect(_x, 10, _x + 104, 40, 10, make_color_rgb(60, 70, 110), 1, true);
		__mn_icono(_vals[i][0], _x + 16, 25, 1);
		__mn_txt(_x + 96, 25, _vals[i][1], 13, c_white, fa_right);
	}

	// --- Titulo y emblema (antes iba tu personaje) ---
	__mn_txt(318, 58, "CAPTURE THE FLAG", 18, c_white);
	__mn_emblema(318, 180);
	__mn_txt(318, 302, "ARENA EDITION", 14, __mn_col("oro"));
	__mn_txt(318, 322, "Temporada 1", 9, __mn_col("gris"), fa_center, false, fnt_small);

	// --- Botones ---
	var _bs = __mn_main_botones();
	for (var b = 0; b < array_length(_bs); b++) {
		var _bt = _bs[b];
		var _r = _bt.r;
		var _hov = (!touch_mode() && __mn_dentro(_px, _py, _r)) || (_kb == _bt.acc);
		switch (_bt.acc) {
			case "jugar":
				__mn_boton(_r[0], _r[1], _r[2], _r[3], __mn_col("oro"), "JUGAR", 30, _ti, _hov, 14);
			break;
			case "privada":
				__mn_boton(_r[0], _r[1], _r[2], _r[3], __mn_col("morado"), "", 15, c_white, true);
				__mn_rect(_r[0] + 10, _r[1] + 9, _r[0] + 36, _r[1] + 35, 5, make_color_rgb(90, 40, 170));
				__mn_icono("llave", _r[0] + 23, _r[1] + 22, 0.7);
				__mn_txt((_r[0] + _r[2]) / 2 + 14, (_r[1] + _r[3]) / 2 + 1, "SALA PRIVADA", 15, c_white);
			break;
			case "jugar_modo":
				__mn_rect(_r[0], _r[1], _r[2], _r[3], 10, c_black, 0.75);
				__mn_rect(_r[0], _r[1], _r[2], _r[3], 10, _hov ? c_white : make_color_rgb(60, 70, 110), 1, true);
				__mn_txt((_r[0] + _r[2]) / 2, (_r[1] + _r[3]) / 2, "MODO: CAPTURA LA BANDERA", 10, __mn_col("azul"), fa_center, false);
			break;
			case "correo": break;
			default:
				var _cb = (_bt.acc == "salir") ? __mn_osc(__mn_col("rojo"), 0.7) : __mn_col("boton");
				__mn_boton(_r[0], _r[1], _r[2], _r[3], _cb, "", 12, c_white, _hov, 10);
				if (_bt.acc != "salir") __mn_rect(_r[0] + 6, _r[1] + 6, _r[0] + 30, _r[3] - 6, 5, __mn_col(_bt.col));
				__mn_txt((_bt.acc == "salir") ? (_r[0] + _r[2]) / 2 : _r[0] + 40, (_r[1] + _r[3]) / 2 + 1, _bt.txt, 12, c_white, (_bt.acc == "salir") ? fa_center : fa_left);
			break;
		}
	}
	__mn_evento_draw(_px, _py);   // tarjeta del EVENTO (si hay uno)
	__mn_msg_draw();
	__mn_reset_draw();
}

// ------------------------------------------------------
// PANTALLA DE MODOS (pestanas + tarjetas)
// ------------------------------------------------------
/// Los modos: el 0 (clasico) ya funciona; los demas salen como PRONTO hasta que los metamos
function __mn_modos() {
	return [
		{ n: "CLASICO",           d: "Captura la bandera",          col: "azul",    ico: "flag",  listo: true },
		{ n: "BANDERA BOMBA",     d: "Anota antes de que explote",  col: "rojo",    ico: "bomb",  listo: true },
		{ n: "GRAVEDAD LOCA",     d: "El techo es el piso",         col: "morado",  ico: "grav",  listo: true },
		{ n: "UN TIRO",           d: "Francotirador y 1 de vida",   col: "cian",    ico: "aim",   listo: true },
		{ n: "REY DE LA BANDERA", d: "Domina la zona",              col: "oro",     ico: "crown", listo: true },
		{ n: "PISO DE LAVA",      d: "La lava sube",                col: "naranja", ico: "lava",  listo: true },
		{ n: "DUELO POR PUNTOS",  d: "Cada baja suma 1",            col: "verde",   ico: "skull", listo: true },
		{ n: "TODOS CONTRA TODOS", d: "Cada quien por su cuenta",   col: "rosa",    ico: "star",  listo: true },
		// 8: JEFE GIGANTE. No sale en la cuadricula (se jugara como EVENTO); para probarlo: tecla J en esta pantalla
		{ n: "JEFE GIGANTE",      d: "Todos contra el jefe",        col: "rojo",    ico: "skull", listo: true }
	];
}
/// Cuantas tarjetas salen en la cuadricula (4 x 2). El JEFE (8) no: va aparte.
function __mn_modos_cuadricula() { return 8; }

/// Rectangulo de la tarjeta i (en la pestana privada van un poco mas chicas y abajo)
function __mn_carta_r(_i, _tab) {
	// 4 columnas x 2 filas (8 modos)
	if (_tab == 1) {
		var _k = 0.8;
		var _x = 89 + (_i mod 4) * 138, _y = 138 + (_i div 4) * 118;
		return [_x, _y, _x + 160 * _k, _y + 132 * _k];
	}
	var _x2 = 22 + (_i mod 4) * 172, _y2 = 102 + (_i div 4) * 146;
	return [_x2, _y2, _x2 + 160, _y2 + 132];
}
function __mn_tab_r(_i) { var _x = 110 + _i * 200; return [_x, 56, _x + 190, 90]; }
function __mn_sub_r(_i) { var _x = 150 + _i * 215; return [_x, 98, _x + 200, 128]; }
function __mn_atras_r() { return [14, 58, 94, 88]; }

function __mn_carta(_i, _tab, _hov) {
	var _ms = __mn_modos();
	var _m = _ms[_i];
	var _r = __mn_carta_r(_i, _tab);
	var _k = (_r[2] - _r[0]) / 160;
	var _col = __mn_col(_m.col);
	var _claro = (_m.col == "cian" || _m.col == "oro" || _m.col == "verde");
	var _ti = __mn_col("tinta");
	var _a = _m.listo ? 1 : 0.55;
	__mn_rect(_r[0], _r[1] + 6, _r[2], _r[3] + 6, 14 * _k, __mn_osc(_col, 0.4), 1);
	__mn_rect(_r[0], _r[1], _r[2], _r[3], 14 * _k, _m.listo ? _col : merge_colour(_col, make_color_rgb(70, 70, 90), 0.45), 1);
	__mn_rect(_r[0], _r[1], _r[2], _r[3], 14 * _k, _hov ? c_white : _ti, 1, true);
	__mn_rect(_r[0] + 8 * _k, _r[1] + 8 * _k, _r[0] + 56 * _k, _r[1] + 56 * _k, 10 * _k, __mn_osc(_col, 0.7), 1);
	__mn_icono(_m.ico, _r[0] + 32 * _k, _r[1] + 32 * _k, 0.85 * _k);
	__mn_rect(_r[2] - 54 * _k, _r[1] + 10 * _k, _r[2] - 8 * _k, _r[1] + 28 * _k, 6 * _k, _ti, 1);
	__mn_txt(_r[2] - 31 * _k, _r[1] + 19 * _k, _m.listo ? "JUGAR" : "PRONTO", 8 * _k, _m.listo ? __mn_col("verde") : __mn_col("oro"), fa_center, false);
	var _tc = _claro ? _ti : c_white;
	__mn_txt(_r[0] + 12 * _k, _r[3] - 36 * _k, _m.n, ((string_length(_m.n) < 14) ? 13 : 10) * _k, _tc, fa_left, !_claro, fnt_menu, _a > 0.9 ? 1 : 0.85);
	__mn_txt(_r[0] + 12 * _k, _r[3] - 16 * _k, _m.d, 9 * _k, _tc, fa_left, false, fnt_small);
}

function __mn_tabs_draw(_px, _py) {
	var _q = global.mn_ui;
	draw_set_color(make_color_rgb(22, 28, 60));
	draw_rectangle(__mn_x(100), __mn_y(52), display_get_gui_width(), __mn_y(94), false);
	var _nom = ["PARTIDA RAPIDA", "SALA PRIVADA", "SIN INTERNET"];
	for (var i = 0; i < 3; i++) {
		var _r = __mn_tab_r(i);
		var _on = (_q.tab == i);
		var _c = _on ? ((i == 1) ? __mn_col("morado") : __mn_col("azul")) : __mn_col("boton");
		__mn_rect(_r[0], _r[1], _r[2], _r[3], 10, _c, 1);
		__mn_rect(_r[0], _r[1], _r[2], _r[3], 10, _on ? c_white : __mn_col("tinta"), 1, true);
		__mn_txt((_r[0] + _r[2]) / 2, 73, _nom[i], 11, _on ? c_white : __mn_col("gris"), fa_center, _on);
	}
	var _a = __mn_atras_r();
	__mn_boton(_a[0], _a[1], _a[2], _a[3], make_color_rgb(70, 80, 120), "<", 16, c_white, !touch_mode() && __mn_dentro(_px, _py, _a), 10);
}

function scr_mn_draw_modos() {
	__mn_init(); __mn_geo();
	var _q = global.mn_ui;
	__mn_fondo();
	var _px = (device_mouse_x_to_gui(0) - _q.ox) / _q.S, _py = (device_mouse_y_to_gui(0) - _q.oy) / _q.S;
	__mn_txt(360, 30, (_q.tab == 1) ? "SALA PRIVADA" : ((_q.tab == 2) ? "SIN INTERNET" : "ELIGE UN MODO"), 18, c_white);
	__mn_tabs_draw(_px, _py);
	if (_q.tab == 0 || _q.tab == 1) {
		if (_q.tab == 1) {
			var _sn = ["CREAR SALA", "UNIRME CON CODIGO"];
			for (var s = 0; s < 2; s++) {
				var _r = __mn_sub_r(s);
				var _on = (s == 0);
				__mn_boton(_r[0], _r[1], _r[2], _r[3], _on ? __mn_col("morado") : __mn_col("boton"), _sn[s], 11, c_white, !touch_mode() && __mn_dentro(_px, _py, _r), 10);
			}
		}
		for (var i = 0; i < __mn_modos_cuadricula(); i++) {
			var _hov = (!touch_mode() && __mn_dentro(_px, _py, __mn_carta_r(i, _q.tab))) || (!touch_mode() && _q.carta == i);
			__mn_carta(i, _q.tab, _hov);
		}
		__mn_txt(360, 396, (_q.tab == 1) ? "Elige el modo de tu sala" : "Toca un modo para jugar", 9, __mn_col("gris"), fa_center, false, fnt_small);
	} else {
		// SIN INTERNET: una tarjeta grande
		var _r2 = [190, 120, 530, 330];
		var _hov2 = (!touch_mode() && __mn_dentro(_px, _py, _r2)) || !touch_mode();
		__mn_rect(_r2[0], _r2[1] + 6, _r2[2], _r2[3] + 6, 16, __mn_osc(__mn_col("boton"), 0.5));
		__mn_rect(_r2[0], _r2[1], _r2[2], _r2[3], 16, make_color_rgb(70, 90, 170));
		__mn_rect(_r2[0], _r2[1], _r2[2], _r2[3], 16, _hov2 ? c_white : __mn_col("tinta"), 1, true);
		__mn_rect(330, 140, 390, 200, 12, make_color_rgb(40, 52, 110));
		__mn_icono("wifi_no", 360, 170, 1.2);
		__mn_txt(360, 228, "JUGAR SIN INTERNET", 18, c_white);
		__mn_txt(360, 254, "Contra bots o practica solo", 10, __mn_col("gris"), fa_center, false, fnt_small);
		__mn_boton(270, 276, 450, 316, __mn_col("verde"), "ENTRAR", 15, __mn_col("tinta"), _hov2, 10);
	}
	__mn_msg_draw();
	__mn_reset_draw();
}

// ------------------------------------------------------
// CUANTOS JUGADORES
// ------------------------------------------------------
function __mn_tam_r(_i) { var _x = 60 + _i * 155; return [_x, 170, _x + 140, 320]; }
/// Por ahora la partida rapida es 1 VS 1 (se llena con bot si no hay rival). 2 VS 2 en adelante: PRONTO.
/// Tamanos que van con cada modo (balance): [1vs1, 2vs2, 3vs3, 4vs4]
function __mn_modo_tams(_m) {
	switch (_m) {
		case 1: case 4: case 5: return [false, true, true, true];   // bandera bomba, rey de la bandera, piso de lava
		case 3: return [true, true, true, false];                     // un tiro (4 vs 4 es demasiado caos)
		case 7: return [false, true, true, true];                     // todos contra todos: de 4 a 8 jugadores
		case 8: return [true, true, false, false];                    // jefe gigante: 2 o 4 jugadores (con mas es muy facil)
	}
	return [true, true, true, true];                                   // clasico y gravedad loca
}
function __mn_tam_listo(_i) { var _t = __mn_modo_tams(global.mn_ui.modo); return _t[clamp(_i, 0, 3)]; }
/// El primer tamano que va con el modo
function __mn_tam_primero() { for (var i = 0; i < 4; i++) if (__mn_tam_listo(i)) return i; return 0; }

function scr_mn_draw_tamano() {
	__mn_init(); __mn_geo();
	var _q = global.mn_ui;
	__mn_fondo();
	var _px = (device_mouse_x_to_gui(0) - _q.ox) / _q.S, _py = (device_mouse_y_to_gui(0) - _q.oy) / _q.S;
	var _ms = __mn_modos();
	var _m = _ms[_q.modo];
	var _col = __mn_col(_m.col);
	__mn_rect(120, 50, 600, 110, 14, _col);
	__mn_rect(120, 50, 600, 110, 14, __mn_col("tinta"), 1, true);
	__mn_rect(128, 56, 176, 104, 10, __mn_osc(_col, 0.7));
	__mn_icono(_m.ico, 152, 80, 0.9);
	__mn_txt(190, 72, _m.n, 18, c_white, fa_left);
	__mn_txt(190, 94, _m.d, 10, c_white, fa_left, false, fnt_small);
	__mn_txt(360, 144, "CUANTOS JUGADORES?", 16, c_white);
	var _lab = ["1 VS 1", "2 VS 2", "3 VS 3", "4 VS 4"];
	if (_q.modo == 7 || _q.modo == 8) _lab = ["2 JUGADORES", "4 JUGADORES", "6 JUGADORES", "8 JUGADORES"];   // TODOS CONTRA TODOS y JEFE
	for (var i = 0; i < 4; i++) {
		var _r = __mn_tam_r(i);
		var _ok = __mn_tam_listo(i);
		var _hov = (!touch_mode() && __mn_dentro(_px, _py, _r)) || (!touch_mode() && _q.tam == i);
		__mn_rect(_r[0], _r[1] + 6, _r[2], _r[3] + 6, 14, make_color_rgb(10, 12, 30));
		__mn_rect(_r[0], _r[1], _r[2], _r[3], 14, _ok ? __mn_col("boton") : make_color_rgb(34, 38, 62));
		__mn_rect(_r[0], _r[1], _r[2], _r[3], 14, _hov ? c_white : __mn_col("tinta"), 1, true);
		__mn_txt((_r[0] + _r[2]) / 2, _r[1] + 30, _lab[i], (_q.modo == 7 || _q.modo == 8) ? 12 : 20, _ok ? (_hov ? __mn_col("oro") : c_white) : __mn_col("gris"));
		var _n = i + 1;
		for (var j = 0; j < _n; j++) {
			var _cx = (_r[0] + _r[2]) / 2 - _n * 13 + j * 26 + 13;
			__mn_rect(_cx - 9, _r[1] + 62, _cx + 9, _r[1] + 86, 4, _ok ? __mn_col("azul") : __mn_osc(__mn_col("azul"), 0.5));
			__mn_rect(_cx - 9, _r[1] + 100, _cx + 9, _r[1] + 124, 4, _ok ? __mn_col("rojo") : __mn_osc(__mn_col("rojo"), 0.5));
		}
		__mn_txt((_r[0] + _r[2]) / 2, _r[1] + 140, _ok ? "JUGAR" : "NO EN ESTE MODO", 9, _ok ? __mn_col("verde") : __mn_col("gris"), fa_center, false);
	}
	var _a = __mn_atras_r();
	__mn_boton(_a[0], _a[1], _a[2], _a[3], make_color_rgb(70, 80, 120), "<", 16, c_white, !touch_mode() && __mn_dentro(_px, _py, _a), 10);
	__mn_msg_draw();
	__mn_reset_draw();
}

function __mn_msg_draw() {
	var _q = global.mn_ui;
	if (_q.msg_t <= 0) return;
	var _a = min(1, _q.msg_t / 20);
	__mn_rect(220, 352, 500, 382, 10, __mn_col("tinta"), 0.92 * _a);
	__mn_rect(220, 352, 500, 382, 10, __mn_col("oro"), _a, true);
	__mn_txt(360, 367, _q.msg, 12, __mn_col("oro"), fa_center, false, fnt_menu, _a);
}
function __mn_reset_draw() {
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	draw_set_color(c_white);
	draw_set_alpha(1);
}

// ------------------------------------------------------
// STEP (oMenu, arriba): toques, clics y teclado del menu nuevo
// ------------------------------------------------------
/// Las pantallas viejas que quedan reemplazadas por las nuevas
function scr_mn_redirigir() {
	if (!MN_NUEVO) return;
	__mn_init();
	if (menu_state == "private")        { menu_state = "modos"; global.mn_ui.tab = 1; global.mn_ui.abierto_t = 0; }
	if (menu_state == "play_selection") { menu_state = "modos"; global.mn_ui.tab = 0; global.mn_ui.abierto_t = 0; }
}

/// Partida rapida (lo mismo que hacia PLAY -> PARTIDA RAPIDA)
function __mn_partida_rapida() {
	// Sin conexion no se puede buscar (antes se quedaba buscando para siempre o te mandaba al bot viejo)
	if (!scr_cuenta_conectado()) { __mn_msg("SIN CONEXION, ESPERA UN MOMENTO"); return; }
	if (global.myName == "") global.myName = "Player_" + string(irandom(999));
	global.match_modo = global.mn_ui.modo;
	global.qp_tam = clamp(global.mn_ui.tam + 1, 1, 4);         // jugadores por equipo
	global.max_players_allowed = global.qp_tam * 2;
	menu_state = "connecting";
	// Cada modo y tamano tiene su propia fila (el servidor lee el numero del principio: 2, 4, 6 u 8)
	ChangeRoom("auto_matchmake_" + string(global.qp_tam * 2) + ((global.match_modo > 0) ? "_m" + string(global.match_modo) : ""));
}
/// Crear sala privada (lo mismo que hacia CREATE ROOM): va a la pantalla de ajustes de la sala
function __mn_crear_sala() {
	if (global.myName == "") global.myName = "Player_" + string(irandom(999));
	texto_input = global.myName;   // (antes lo ponia la pantalla vieja; sin esto la sala te cambiaba el nombre a "Name")
	global.match_modo = global.mn_ui.modo;   // el modo de la sala (lo manda el lider a todos)
	menu_state = "setup_room";
	s_index = 0;
	global.setup_modo = 0;
	scr_ajustes_default();
}
/// Unirse con codigo (lo mismo que hacia JOIN WITH CODE)
function __mn_unirse() {
	menu_state = "join_code";
	join_input = "";
	input_activo = true;
	keyboard_string = "";
	if (touch_mode()) keyboard_virtual_show(kbv_type_default, kbv_returnkey_go, kbv_autocapitalize_characters, false);
}
/// Sin internet (lo mismo que hacia OFFLINE)
function __mn_sin_internet() {
	global.ONLINE = false;
	menu_state = "offline_setup";
	off_index = 0;
	global.off_mapa = 0;
	global.off_flags = 3;
	global.off_bots = 0;
	offline_options = ["MAPA: BOSQUE", "OBJETIVO: 3 BANDERAS", "ENEMIGOS: SOLO (PRACTICA)", "INICIAR BATALLA", "BACK"];
}

/// Elegir una tarjeta de modo
function __mn_elegir_modo(_i) {
	var _q = global.mn_ui;
	var _ms = __mn_modos();
	var _m = _ms[_i];
	if (!_m.listo) { __mn_msg(_m.n + " - PRONTO!"); return; }
	_q.modo = _i;
	if (_q.tab == 1) __mn_crear_sala();
	else { menu_state = "tamano"; _q.tam = __mn_tam_primero(); }
	_q.abierto_t = 0;
	menu_delay = 8;
	if (global.sfx) audio_play_sound(snd_scroll, 5, false, 0.5);
}

// ------------------------------------------------------
// TARJETA DEL EVENTO (menu principal, arriba a la derecha). Los eventos: DatabaseFunctions
// ------------------------------------------------------
function __mn_evento_r() { return [470, 46, 700, 198]; }

function __mn_evento_draw(_px, _py) {
	var _ev = scr_evento_actual();
	if (is_undefined(_ev)) return;
	var _x1 = 470, _y1 = 56, _x2 = 700, _y2 = 198;
	var _act = _ev.activo;
	var _ti = __mn_col("tinta");
	var _hov = !touch_mode() && __mn_dentro(_px, _py, __mn_evento_r());
	// Brillo que late cuando ya empezo
	if (_act) {
		var _g = 0.5 + 0.5 * sin(current_time / 200);
		__mn_rect(_x1 - 5, _y1 - 5, _x2 + 5, _y2 + 5, 17, make_color_rgb(255, 90, 70), 0.35 + 0.45 * _g, true);
		__mn_rect(_x1 - 4, _y1 - 4, _x2 + 4, _y2 + 4, 16, make_color_rgb(255, 90, 70), 0.25 + 0.35 * _g, true);
	}
	__mn_rect(_x1, _y1 + 6, _x2, _y2 + 6, 14, make_color_rgb(60, 15, 20));
	__mn_rect(_x1, _y1, _x2, _y2, 14, _act ? make_color_rgb(120, 28, 40) : make_color_rgb(55, 40, 60));
	__mn_rect(_x1, _y1, _x2, _y2, 14, _hov ? c_white : (_act ? __mn_col("oro") : __mn_col("gris")), 1, true);
	// Cinta EVENTO / PRONTO
	__mn_rect(_x1 + 10, _y1 - 10, _x1 + 92, _y1 + 10, 8, _act ? __mn_col("oro") : __mn_col("gris"));
	__mn_txt(_x1 + 51, _y1, _act ? "EVENTO" : "PRONTO", 10, _ti, fa_center, false);
	// Icono del modo, nombre y texto
	__mn_rect(_x1 + 12, _y1 + 20, _x1 + 64, _y1 + 72, 10, _act ? make_color_rgb(70, 15, 25) : make_color_rgb(40, 30, 50));
	var _ms = __mn_modos();
	__mn_icono(_ms[_ev.m].ico, _x1 + 38, _y1 + 46, 1);
	__mn_txt(_x1 + 74, _y1 + 32, _ev.n, 15, c_white, fa_left);
	__mn_txt(_x1 + 74, _y1 + 52, _ev.x, 9, _act ? make_color_rgb(255, 220, 220) : __mn_col("gris"), fa_left, false, fnt_small);
	// Cuenta regresiva
	__mn_rect(_x1 + 12, _y1 + 82, _x2 - 12, _y1 + 106, 8, c_black);
	__mn_txt((_x1 + _x2) / 2, _y1 + 94, (_act ? "TERMINA EN " : "EMPIEZA EN ") + scr_evento_tiempo(_act ? _ev.falta_fin : _ev.falta_ini), 11, _act ? __mn_col("oro") : __mn_col("gris"), fa_center, false);
	if (_act) {
		var _p = 1 + 0.05 * sin(current_time / 125);
		var _bw = 60 * _p, _cx = (_x1 + _x2) / 2;
		__mn_rect(_cx - _bw, _y1 + 112, _cx + _bw, _y1 + 134, 8, __mn_col("verde"));
		__mn_txt(_cx, _y1 + 123, "JUGAR EVENTO", 11, _ti, fa_center, false);
	} else {
		__mn_txt((_x1 + _x2) / 2, _y1 + 123, "Empieza " + _ev.f, 8, __mn_col("gris"), fa_center, false, fnt_small);
	}
}

/// Tocar la tarjeta (o la tecla E): si ya empezo, a elegir cuantos jugadores
function __mn_evento_entrar(_ev) {
	if (!_ev.activo) { __mn_msg(string_upper("Empieza " + _ev.f)); return; }
	global.mn_ui.tab = 0;
	__mn_elegir_modo(_ev.m);
}

/// Devuelve true si se encargo de este frame (el resto del Step de oMenu sigue igual)
function scr_mn_step() {
	if (!MN_NUEVO || !global.registrado) return false;
	if (menu_state != "main" && menu_state != "modos" && menu_state != "tamano") return false;
	__mn_init(); __mn_geo();
	var _q = global.mn_ui;
	_q.abierto_t++;
	if (_q.msg_t > 0) _q.msg_t--;
	if (menu_delay > 0 || input_activo) return true;
	if (_q.abierto_t <= 5) return true;

	var _toque = device_mouse_check_button_pressed(0, mb_left);
	var _px = (device_mouse_x_to_gui(0) - _q.ox) / _q.S, _py = (device_mouse_y_to_gui(0) - _q.oy) / _q.S;

	if (menu_state == "main") {
		// EVENTO: pedir la lista al servidor y entrar tocando su tarjeta (o con la E)
		scr_eventos_step();
		var _ev = scr_evento_actual();
		if (!is_undefined(_ev) && ((_toque && __mn_dentro(_px, _py, __mn_evento_r())) || vkey_pressed(ord("E")))) { __mn_evento_entrar(_ev); return true; }
		var _orden = __mn_main_orden();
		var _mv = vkey_pressed(ord("S")) - vkey_pressed(ord("W"));
		if (_mv != 0) _q.sel = clamp(_q.sel + _mv, 0, array_length(_orden) - 1);
		if (vkey_pressed(vk_enter)) { __mn_hacer(_orden[_q.sel]); return true; }
		if (vkey_pressed(ord("M"))) { __mn_hacer("correo"); return true; }
		if (_toque) {
			var _bs = __mn_main_botones();
			for (var b = 0; b < array_length(_bs); b++) {
				if (__mn_dentro(_px, _py, _bs[b].r)) { __mn_hacer(_bs[b].acc); return true; }
			}
		}
		return true;
	}

	if (menu_state == "modos") {
		var _atras = vkey_pressed(vk_escape);
		if (_toque && __mn_dentro(_px, _py, __mn_atras_r())) _atras = true;
		if (_atras) { menu_state = "main"; menu_delay = 5; _q.abierto_t = 0; return true; }
		// Pestanas (toque o TAB / Q-E)
		var _tc = vkey_pressed(vk_tab) ? 1 : 0;
		if (_tc != 0) { _q.tab = (_q.tab + 1) mod 3; _q.carta = 0; }
		if (_toque) {
			for (var t = 0; t < 3; t++) if (__mn_dentro(_px, _py, __mn_tab_r(t))) { _q.tab = t; _q.carta = 0; if (global.sfx) audio_play_sound(snd_scroll, 5, false, 0.4); return true; }
		}
		if (_q.tab == 2) {
			if (vkey_pressed(vk_enter) || (_toque && point_in_rectangle(_px, _py, 190, 120, 530, 330))) { __mn_sin_internet(); menu_delay = 8; _q.abierto_t = 0; }
			return true;
		}
		if (_q.tab == 1 && _toque && __mn_dentro(_px, _py, __mn_sub_r(1))) { __mn_unirse(); menu_delay = 8; _q.abierto_t = 0; return true; }
		// Tarjetas: flechas para moverse, ENTER para elegir
		var _lr = vkey_pressed(vk_right) - vkey_pressed(vk_left) + vkey_pressed(ord("D")) - vkey_pressed(ord("A"));
		var _ud = vkey_pressed(vk_down) - vkey_pressed(vk_up) + vkey_pressed(ord("S")) - vkey_pressed(ord("W"));
		if (_lr != 0 || _ud != 0) _q.carta = clamp(_q.carta + sign(_lr) + sign(_ud) * 4, 0, __mn_modos_cuadricula() - 1);
		if (vkey_pressed(vk_enter)) { __mn_elegir_modo(_q.carta); return true; }
		// PRUEBA del JEFE GIGANTE (mientras hacemos lo de los eventos): tecla J
		if (vkey_pressed(ord("J"))) { __mn_elegir_modo(8); return true; }
		if (_toque) {
			for (var i = 0; i < __mn_modos_cuadricula(); i++) if (__mn_dentro(_px, _py, __mn_carta_r(i, _q.tab))) { _q.carta = i; __mn_elegir_modo(i); return true; }
		}
		return true;
	}

	if (menu_state == "tamano") {
		var _atras2 = vkey_pressed(vk_escape);
		if (_toque && __mn_dentro(_px, _py, __mn_atras_r())) _atras2 = true;
		if (_atras2) { menu_state = "modos"; menu_delay = 5; _q.abierto_t = 0; return true; }
		var _lr2 = vkey_pressed(vk_right) - vkey_pressed(vk_left) + vkey_pressed(ord("D")) - vkey_pressed(ord("A"));
		if (_lr2 != 0) _q.tam = clamp(_q.tam + sign(_lr2), 0, 3);
		var _elegido = -1;
		if (vkey_pressed(vk_enter)) _elegido = _q.tam;
		if (_toque) for (var k = 0; k < 4; k++) if (__mn_dentro(_px, _py, __mn_tam_r(k))) _elegido = k;
		if (_elegido >= 0) {
			_q.tam = _elegido;
			if (!__mn_tam_listo(_elegido)) { __mn_msg("ESE TAMANO NO VA EN ESTE MODO"); return true; }
			__mn_partida_rapida();
			_q.abierto_t = 0;
		}
		return true;
	}
	return false;
}

// ------------------------------------------------------
// PANTALLA BUSCANDO PARTIDA / CREANDO SALA (oMenu: menu_state == "connecting")
// ------------------------------------------------------
function __mn_cancelar_r() { return [280, 340, 440, 382]; }

function scr_mn_draw_buscando() {
	__mn_init(); __mn_geo();
	var _q = global.mn_ui;
	__mn_fondo();
	var _ti = __mn_col("tinta");
	var _rnd = string_count("auto_matchmake", string(global.roomId)) > 0;
	var _px = (device_mouse_x_to_gui(0) - _q.ox) / _q.S, _py = (device_mouse_y_to_gui(0) - _q.oy) / _q.S;
	// Cabecera con el modo
	var _hc = _rnd ? __mn_col("azul") : __mn_col("morado");
	__mn_rect(210, 34, 510, 66, 10, __mn_osc(_hc, 0.45));
	__mn_rect(210, 30, 510, 62, 10, _hc);
	__mn_rect(210, 30, 510, 62, 10, _ti, 1, true);
	var _tn = variable_global_exists("qp_tam") ? global.qp_tam : 1;
	__mn_txt(360, 47, _rnd ? (scr_modo_nombre() + "  -  " + ((scr_modo() == 7 || scr_modo() == 8) ? string(_tn * 2) + " JUGADORES" : string(_tn) + " VS " + string(_tn))) : ("SALA PRIVADA  -  " + scr_modo_nombre()), 13, c_white);
	var _dots = string_repeat(".", (current_time div 300) mod 4);
	__mn_txt(360, 92, (_rnd ? ((_tn > 1) ? "BUSCANDO JUGADORES" : "BUSCANDO RIVAL") : "CREANDO SALA") + _dots, 20, c_white);
	var _seg = floor((variable_struct_exists(_q, "busca_t") ? _q.busca_t : 0) / max(1, game_get_speed(gamespeed_fps)));
	var _sub = string(_seg div 60) + ":" + string_replace(string_format(_seg mod 60, 2, 0), " ", "0");
	if (_rnd && variable_instance_exists(id, "waiting_message") && string(waiting_message) != "") _sub += "   -   " + string_upper(string(waiting_message));
	if (_rnd) _sub += "   -   " + string(clamp(__mn_en_cola(), 1, _tn * 2)) + " / " + string(_tn * 2) + " JUGADORES";
	if (!_rnd && global.myRoomCode != "") _sub = "CODIGO: " + string(global.myRoomCode);
	__mn_txt(360, 116, _sub, 10, _rnd ? __mn_col("gris") : __mn_col("oro"), fa_center, false);

	// Partida rapida: todos los espacios del modo (mitad tu equipo, mitad rivales)
	if (_rnd) {
		__mn_buscando_casillas(_tn);
		var _r0 = __mn_cancelar_r();
		__mn_boton(_r0[0], _r0[1], _r0[2], _r0[3], __mn_col("rojo"), "CANCELAR", 14, c_white, !touch_mode() && __mn_dentro(_px, _py, _r0), 12);
		__mn_reset_draw();
		return;
	}

	// Tu casilla
	__mn_rect(150, 146, 270, 316, 14, __mn_col("panel"), 1);
	__mn_rect(150, 146, 270, 316, 14, __mn_col("azul"), 1, true);
	var _spr = __mn_pj_sprite();
	var _sk = min(80 / max(1, sprite_get_height(_spr)), 80 / max(1, sprite_get_width(_spr))) * _q.S;
	var _sw = sprite_get_width(_spr) * _sk, _sh = sprite_get_height(_spr) * _sk;
	draw_sprite_ext(_spr, (current_time div 120) mod max(1, sprite_get_number(_spr)),
		__mn_x(210) - _sw / 2 + sprite_get_xoffset(_spr) * _sk, __mn_y(262) - _sh + sprite_get_yoffset(_spr) * _sk, _sk, _sk, 0, c_white, 1);
	__mn_txt(210, 284, string_upper(string_copy(string(global.myName), 1, 12)), 11, c_white);
	var _pj = scr_pj_datos(variable_global_exists("pj_selected") ? global.pj_selected : 0);
	__mn_txt(210, 302, _pj.nombre, 8, __mn_col("gris"), fa_center, false);

	__mn_txt(360, 230, "VS", 30, __mn_col("oro"));

	// Casilla del rival: buscando (puntitos que giran)
	__mn_rect(450, 146, 570, 316, 14, __mn_col("panel"), 1);
	__mn_rect(450, 146, 570, 316, 14, __mn_col("rojo"), 1, true);
	var _a = current_time / 160;
	for (var j = 0; j < 8; j++) {
		var _ang = _a + j * 0.785;
		var _c = 80 + floor(170 * (j / 8));
		draw_set_color(make_color_rgb(_c, _c, _c));
		draw_circle(__mn_x(510 + 20 * cos(_ang)), __mn_y(226 + 20 * sin(_ang)), 4 * _q.S, false);
	}
	draw_set_color(c_white);
	__mn_txt(510, 284, "BUSCANDO", 11, __mn_col("gris"), fa_center, false);

	// Cancelar
	var _r = __mn_cancelar_r();
	__mn_boton(_r[0], _r[1], _r[2], _r[3], __mn_col("rojo"), "CANCELAR", 14, c_white, !touch_mode() && __mn_dentro(_px, _py, _r), 12);
	__mn_reset_draw();
}

// ------------------------------------------------------
// ESTETICA NUEVA PARA TODAS LAS PANTALLAS (ctf_ui_*): fondo con rayas, botones redondos con relieve
// ------------------------------------------------------
function __mn_fondo_wh(_w, _h) {
	var _c1 = make_color_rgb(18, 22, 52), _c2 = make_color_rgb(38, 36, 62);
	draw_set_alpha(1);
	draw_rectangle_colour(0, 0, _w, _h, _c1, _c1, _c2, _c2, false);
	var _S = min(_w / 720, _h / 405);
	var _paso = 60 * _S;
	var _off = ((current_time / 1000) * 30 * _S) mod _paso;
	draw_set_color(make_color_rgb(34, 40, 82));
	for (var _x = -_h; _x < _w + _paso; _x += _paso) draw_line_width(_x + _off, _h, _x + _off + _h, 0, 14 * _S);
	draw_set_color(c_white);
}

function __mn_redondo(_x, _y, _w, _h, _col, _a, _outline, _panel) {
	var _r = max(1, min(abs(_h) * 0.3, 14, abs(_w) * 0.5));
	var _tinta = make_color_rgb(11, 15, 26);
	if (_outline) {
		// Bordes tenues de antes -> borde oscuro (estilo nuevo); los de color fuerte se quedan
		var _oc = (_a < 0.5) ? _tinta : _col;
		draw_set_color(_oc);
		draw_set_alpha((_a < 0.5) ? 1 : _a);
		draw_roundrect_ext(_x, _y, _x + _w, _y + _h, _r, _r, true);
		draw_roundrect_ext(_x + 1, _y + 1, _x + _w - 1, _y + _h - 1, _r, _r, true);
	} else if (_col != _tinta && _a < 0.3 && abs(_h) > 12) {
		// Relleno de color muy tenue de antes -> boton con relieve pintado de ese color
		draw_set_color(c_black);
		draw_set_alpha(0.5);
		draw_roundrect_ext(_x, _y + 4, _x + _w, _y + _h + 4, _r, _r, false);
		draw_set_alpha(1);
		draw_set_color(make_color_rgb(44, 54, 110));
		draw_roundrect_ext(_x, _y, _x + _w, _y + _h, _r, _r, false);
		draw_set_color(_col);
		draw_set_alpha(min(1, _a * 2.5));
		draw_roundrect_ext(_x, _y, _x + _w, _y + _h, _r, _r, false);
	} else if (_col == _tinta && _a >= 0.6) {
		// Fondo oscuro de siempre -> boton azul con sombra y brillo (o panel oscuro)
		draw_set_color(c_black);
		draw_set_alpha(0.5);
		draw_roundrect_ext(_x, _y + 4, _x + _w, _y + _h + 4, _r, _r, false);
		draw_set_alpha(1);
		draw_set_color(_panel ? make_color_rgb(20, 24, 50) : make_color_rgb(44, 54, 110));
		draw_roundrect_ext(_x, _y, _x + _w, _y + _h, _r, _r, false);
		if (!_panel && abs(_h) > 12) {
			draw_set_color(make_color_rgb(70, 82, 150));
			draw_set_alpha(0.55);
			draw_roundrect_ext(_x + 4, _y + 3, _x + _w - 4, _y + _h * 0.4, _r * 0.6, _r * 0.6, false);
		}
	} else {
		draw_set_color(_col);
		draw_set_alpha(_a);
		draw_roundrect_ext(_x, _y, _x + _w, _y + _h, _r, _r, false);
	}
	draw_set_alpha(1);
}

/// Step de la pantalla de buscando: reloj y boton CANCELAR (ESC sigue igual)
function scr_mn_buscando_step() {
	if (!MN_NUEVO) return;
	__mn_init();
	var _q = global.mn_ui;
	if (!variable_struct_exists(_q, "busca_t")) _q.busca_t = 0;
	if (menu_state != "connecting") { _q.busca_t = 0; return; }
	if (_q.busca_t == 0) { global.qp_en_cola = 1; global.qp_llegada = []; }
	_q.busca_t++;
	// Partida rapida: cada segundo pregunto cuantos hay en la cola (callback_ShowAllClientsInRoom)
	if (string_pos("auto_matchmake", string(global.roomId)) == 1 && (_q.busca_t mod 60) == 1) ShowAllClientsInRoom(string(global.roomId));
	if (!device_mouse_check_button_pressed(0, mb_left)) return;
	__mn_geo();
	var _px = (device_mouse_x_to_gui(0) - _q.ox) / _q.S, _py = (device_mouse_y_to_gui(0) - _q.oy) / _q.S;
	if (__mn_dentro(_px, _py, __mn_cancelar_r())) {
		LeaveRoom();
		menu_state = "main";
		menu_delay = 5;
		_q.abierto_t = 0;
	}
}

// ======================================================
// SELECCION DE PERSONAJE NUEVA (oBrain Draw GUI y Step). Sirve en 1 VS 1 ... 4 VS 4:
// las cartas de cada equipo se achican solas para que siempre quepan todos.
// ======================================================
/// ¿Esta abierta la seleccion? (la misma condicion de siempre)
function scr_mn_sel_activa() {
	if (!instance_exists(oBrain) || room == rm_menu) return false;
	if (!(global.ONLINE || (variable_global_exists("bot_partida") && global.bot_partida))) return false;
	return (!oBrain.intro_disparada || scr_sel_tarde());
}

function __mn_sel_pas(_i) {
	switch (_i) {
		case 1: return "Golpe cuerpo a cuerpo +4 de dano";
		case 2: return "No sale en el mini mapa del rival";
		case 3: return "Dispara llevando la bandera";
	}
	return "Automaticas +2 a 3 de dano por bala";
}
function __mn_sel_carta_r(_i) { var _x = 26 + _i * 86; return [_x, 228, _x + 78, 378]; }
function __mn_sel_listo_r() { return [380, 342, 690, 388]; }

/// Retrato del personaje (tu arte grande) recortado dentro de un cuadro
function __mn_retrato(_pj, _x1, _y1, _x2, _y2, _a = 1, _col = c_white) {
	if (!variable_global_exists("pj_portraits") || _pj < 0 || _pj >= array_length(global.pj_portraits)) return;
	var _spr = global.pj_portraits[_pj];
	var _S = global.mn_ui.S;
	var _w = (_x2 - _x1) * _S, _h = (_y2 - _y1) * _S;
	var _sw = sprite_get_width(_spr), _sh = sprite_get_height(_spr);
	var _k = _w / _sw;                       // ancho completo
	var _top = _sh * 0.03;
	var _alto = min(_sh - _top, _h / _k);   // solo lo que cabe (cabeza y cuerpo)
	draw_sprite_part_ext(_spr, 0, 0, _top, _sw, _alto, __mn_x(_x1), __mn_y(_y1), _k, _k, _col, _a);
}

/// Toque en la seleccion: -1 nada, 0..3 personaje, 4 LISTO
function scr_mn_sel_toque() {
	if (!MN_NUEVO || !device_mouse_check_button_pressed(0, mb_left)) return -1;
	__mn_init(); __mn_geo();
	var _q = global.mn_ui;
	var _px = (device_mouse_x_to_gui(0) - _q.ox) / _q.S, _py = (device_mouse_y_to_gui(0) - _q.oy) / _q.S;
	for (var i = 0; i < 4; i++) if (__mn_dentro(_px, _py, __mn_sel_carta_r(i))) return i;
	if (__mn_dentro(_px, _py, __mn_sel_listo_r())) return 4;
	return -1;
}

function scr_mn_draw_seleccion() {
	__mn_init(); __mn_geo();
	var _q = global.mn_ui;
	var _ti = __mn_col("tinta");
	__mn_fondo();
	var _px = (device_mouse_x_to_gui(0) - _q.ox) / _q.S, _py = (device_mouse_y_to_gui(0) - _q.oy) / _q.S;
	var _yo = scr_my_team();

	// Titulo y reloj
	__mn_txt(360, 20, "ELIGE TU PERSONAJE", 18, c_white);
	if (scr_sel_tarde()) {
		__mn_txt(360, 46, "LA PARTIDA YA EMPEZO: ELIGE Y ENTRAS", 10, __mn_col("oro"), fa_center, false);
	} else {
		var _segs = ceil(oBrain.timer_intro / 60);
		__mn_rect(336, 35, 384, 57, 8, _ti);
		__mn_rect(336, 35, 384, 57, 8, __mn_col("oro"), 1, true);
		__mn_txt(360, 46, string(_segs), 13, __mn_col("oro"), fa_center, false);
	}

	// Quien va en cada equipo (lo mismo de siempre)
	var _az = [], _ro = [];
	var _mine = [global.pj_selected, global.myName, global.mi_listo, true];
	if (_yo == "AZUL") array_push(_az, _mine); else array_push(_ro, _mine);
	with (oOtherPlayer) {
		var _pj  = variable_instance_exists(id, "mySelectedPJ") ? mySelectedPJ : 0;
		var _rdy = variable_instance_exists(id, "isReady") ? isReady : false;
		var _it  = [_pj, Name, _rdy, false];
		var _tm  = (variable_instance_exists(id, "lobby_team") && lobby_team != "") ? lobby_team : team;
		if (_tm == "AZUL") array_push(_az, _it); else array_push(_ro, _it);
	}
	if (global.bot_partida) {
		var _bt = [global.bot_pj_vista, global.bot_nombre, global.bot_listo, false];
		if (_yo == "AZUL") array_push(_ro, _bt); else array_push(_az, _bt);
	}

	// TODOS CONTRA TODOS: no hay equipos, todos repartidos en las dos filas (scr_reloj)
	if (scr_modo_todos()) {
		var _todos = [];
		for (var _j = 0; _j < array_length(_az); _j++) array_push(_todos, _az[_j]);
		for (var _j = 0; _j < array_length(_ro); _j++) array_push(_todos, _ro[_j]);
		_az = []; _ro = [];
		for (var _j = 0; _j < array_length(_todos); _j++) { if (_j mod 2 == 0) array_push(_az, _todos[_j]); else array_push(_ro, _todos[_j]); }
	}
	// JEFE GIGANTE: todos juntos en TU EQUIPO y del otro lado solo el jefe (scr_reloj)
	var _jefe = scr_modo_jefe();
	if (_jefe) {
		for (var _j = 0; _j < array_length(_ro); _j++) array_push(_az, _ro[_j]);
		_ro = [];
	}

	// Las dos filas de cartas (se achican para que siempre quepan)
	for (var t = 0; t < 2; t++) {
		var _lst = (t == 0) ? _az : _ro;
		var _col = (t == 0) ? __mn_col("azul") : __mn_col("rojo");
		var _x0 = (t == 0) ? 14 : 384;
		var _ancho = 322;
		__mn_rect(_x0, 62, _x0 + _ancho, 80, 8, _col);
		__mn_rect(_x0, 62, _x0 + _ancho, 80, 8, _ti, 1, true);
		var _tit = scr_modo_todos() ? "JUGADORES" : ((t == 0) ? "EQUIPO AZUL" : "EQUIPO ROJO");
		if (_jefe) _tit = (t == 0) ? "TU EQUIPO" : "EL JEFE";
		__mn_txt(_x0 + _ancho / 2, 71, _tit, 10, c_white);
		if (_jefe && t == 1) { __mn_jefe_carta(_x0 + _ancho / 2 - 50, 86, _x0 + _ancho / 2 + 50, 204); continue; }
		var _n = max(1, array_length(_lst));
		var _g = 6;
		var _cw = min(90, (_ancho - (_n - 1) * _g) / _n);
		var _ch = 118;
		var _gx = _x0 + (_ancho - (_n * _cw + (_n - 1) * _g)) / 2;
		for (var i = 0; i < array_length(_lst); i++) {
			var _e = _lst[i];
			var _x = _gx + i * (_cw + _g), _y = 86;
			var _pjn = clamp(_e[0], 0, 3);
			__mn_rect(_x, _y + 4, _x + _cw, _y + _ch + 4, 10, c_black, 0.6);
			__mn_rect(_x, _y, _x + _cw, _y + _ch, 10, __mn_osc(_col, 0.35));
			__mn_retrato(_pjn, _x + 3, _y + 3, _x + _cw - 3, _y + _ch - 24, _e[2] ? 1 : 0.55, _e[2] ? c_white : c_silver);
			__mn_rect(_x + 3, _y + _ch - 24, _x + _cw - 3, _y + _ch - 3, 4, _ti);
			__mn_rect(_x, _y, _x + _cw, _y + _ch, 10, _e[3] ? c_white : _ti, 1, true);
			__mn_txt(_x + _cw / 2, _y + _ch - 17, string_copy(string(_e[1]), 1, 10), 8, _e[3] ? __mn_col("oro") : c_white, fa_center, false);
			var _dpj = scr_pj_datos(_pjn);
			__mn_txt(_x + _cw / 2, _y + _ch - 8, _dpj.nombre, 6, __mn_col("gris"), fa_center, false, fnt_small);
			if (_e[2]) {
				__mn_rect(_x + 4, _y + 4, _x + 40, _y + 18, 5, __mn_col("verde"));
				__mn_rect(_x + 4, _y + 4, _x + 40, _y + 18, 5, _ti, 1, true);
				__mn_txt(_x + 22, _y + 11, "LISTO", 6, _ti, fa_center, false);
			}
		}
	}
	__mn_txt(360, 145, "VS", 24, __mn_col("oro"));
	var _rival = (_yo == "AZUL") ? "ROJO" : "AZUL";
	__mn_txt(360, 207, _jefe ? "TODOS JUNTOS  >  DERROTEN AL JEFE" : ("ROBA LA BANDERA " + _rival + "  >  LLEVALA A TU BASE"), 8, __mn_col("oro"), fa_center, false);

	// Tu selector
	__mn_rect(14, 216, 706, 398, 14, __mn_col("panel"));
	__mn_rect(14, 216, 706, 398, 14, _ti, 1, true);
	var _sel = clamp(global.pj_selected, 0, 3);
	for (var c = 0; c < 4; c++) {
		var _r = __mn_sel_carta_r(c);
		var _d = scr_pj_datos(c);
		var _on = (c == _sel);
		var _hov = !touch_mode() && __mn_dentro(_px, _py, _r);
		__mn_rect(_r[0], _r[1] + 5, _r[2], _r[3] + 5, 10, c_black, 0.6);
		__mn_rect(_r[0], _r[1], _r[2], _r[3], 10, _on ? __mn_osc(_d.col, 0.55) : __mn_col("boton"));
		__mn_retrato(c, _r[0] + 3, _r[1] + 3, _r[2] - 3, _r[3] - 28, 1, c_white);
		__mn_rect(_r[0], _r[1], _r[2], _r[3], 10, (_on || _hov) ? c_white : _ti, 1, true);
		__mn_txt((_r[0] + _r[2]) / 2, _r[3] - 14, (string_length(_d.nombre) > 8) ? "EXPLORA." : _d.nombre, 9, _on ? _d.col : c_white, fa_center, true);
	}
	var _ds = scr_pj_datos(_sel);
	__mn_txt(380, 236, _ds.nombre, 20, _ds.col, fa_left);
	__mn_rect(380, 252, 540, 270, 6, _ti);
	__mn_txt(388, 261, "Q: " + _ds.hab, 10, c_white, fa_left, false);
	__mn_txt(380, 284, "PASIVA: " + __mn_sel_pas(_sel), 9, make_color_rgb(230, 230, 250), fa_left, false, fnt_small);
	var _barras = [["VIDA", _ds.vida / 220], ["VELOCIDAD", _ds.vel / 3.4]];
	for (var b = 0; b < 2; b++) {
		var _yy = 304 + b * 18;
		__mn_txt(380, _yy, _barras[b][0], 8, __mn_col("gris"), fa_left, false);
		__mn_rect(460, _yy - 5, 690, _yy + 5, 4, make_color_rgb(40, 46, 66));
		__mn_rect(460, _yy - 5, 460 + 230 * clamp(_barras[b][1], 0.05, 1), _yy + 5, 4, _ds.col);
	}
	var _lr = __mn_sel_listo_r();
	if (global.mi_listo) __mn_boton(_lr[0], _lr[1], _lr[2], _lr[3], make_color_rgb(70, 80, 110), "LISTO!  ESPERANDO...", 14, c_white, false, 12);
	else __mn_boton(_lr[0], _lr[1], _lr[2], _lr[3], __mn_col("verde"), "LISTO", 20, _ti, !touch_mode() && __mn_dentro(_px, _py, _lr), 12);
	__mn_reset_draw();
}

// ------------------------------------------------------
// EMBLEMA DEL MENU (en vez del personaje): banderas cruzadas y sello CTF
// ------------------------------------------------------
function __mn_emblema(_cx, _cy) {
	var _S = global.mn_ui.S;
	var _b = 3 * sin(current_time / 400);
	var _x = __mn_x(_cx), _y = __mn_y(_cy) + _b * _S;
	var _ti = __mn_col("tinta");
	draw_set_color(c_black); draw_set_alpha(0.35);
	draw_ellipse(_x - 70 * _S, _y + 84 * _S, _x + 70 * _S, _y + 98 * _S, false);
	draw_set_alpha(1);
	draw_set_color(_ti);                         draw_circle(_x, _y, 84 * _S, false);
	draw_set_color(make_color_rgb(30, 38, 90)); draw_circle(_x, _y, 80 * _S, false);
	draw_set_color(make_color_rgb(70, 90, 170)); draw_circle(_x, _y, 66 * _S, true); draw_circle(_x, _y, 65 * _S, true);
	for (var s = -1; s <= 1; s += 2) {
		var _col = (s < 0) ? __mn_col("azul") : __mn_col("rojo");
		var _x0 = _x + s * 40 * _S, _y0 = _y + 50 * _S;
		var _x1 = _x - s * 30 * _S, _y1 = _y - 55 * _S;
		draw_set_color(make_color_rgb(230, 230, 240));
		draw_line_width(_x0, _y0, _x1, _y1, 5 * _S);
		var _ww = 4 * sin(current_time / 160 + s) * _S;
		draw_set_color(_col);
		draw_triangle(_x1, _y1, _x1 - s * 44 * _S, _y1 + 12 * _S + _ww, _x1 - s * 6 * _S, _y1 + 30 * _S, false);
		draw_set_color(_ti);
		draw_triangle(_x1, _y1, _x1 - s * 44 * _S, _y1 + 12 * _S + _ww, _x1 - s * 6 * _S, _y1 + 30 * _S, true);
	}
	__mn_rect(_cx - 62, _cy + 42 + _b, _cx + 62, _cy + 72 + _b, 8, __mn_col("oro"));
	__mn_rect(_cx - 62, _cy + 42 + _b, _cx + 62, _cy + 72 + _b, 8, _ti, 1, true);
	__mn_txt(_cx, _cy + 57 + _b, "C T F", 18, _ti, fa_center, false);
}

// ======================================================
// HUD NUEVO EN PARTIDA (estetica del menu nuevo). Lo llaman oPlayer y oPlayer_offline (Draw GUI).
//   Arriba a la izquierda: tu carta (retrato, nombre, vida, escudo y poderes) con la Q adentro.
//   Arriba a la derecha: tu arma, la segunda arma (E) y las granadas.
// ======================================================
function __hud_caja(_x1, _y1, _x2, _y2, _r, _col, _a = 1) {
	draw_set_alpha(0.5 * _a); draw_set_color(c_black);
	draw_roundrect_ext(_x1, _y1 + 4, _x2, _y2 + 4, _r, _r, false);
	draw_set_alpha(0.92 * _a); draw_set_color(_col);
	draw_roundrect_ext(_x1, _y1, _x2, _y2, _r, _r, false);
	draw_set_alpha(_a); draw_set_color(make_color_rgb(11, 15, 26));
	draw_roundrect_ext(_x1, _y1, _x2, _y2, _r, _r, true);
	draw_roundrect_ext(_x1 + 1, _y1 + 1, _x2 - 1, _y2 - 1, _r, _r, true);
	draw_set_alpha(1);
}
function __hud_barra(_x1, _y1, _x2, _y2, _p, _col) {
	var _r = (_y2 - _y1) * 0.45;
	draw_set_color(make_color_rgb(11, 15, 26));
	draw_roundrect_ext(_x1, _y1, _x2, _y2, _r, _r, false);
	var _w = (_x2 - _x1 - 4) * clamp(_p, 0, 1);
	if (_w > 1) {
		draw_set_color(_col);
		draw_roundrect_ext(_x1 + 2, _y1 + 2, _x1 + 2 + _w, _y2 - 2, _r, _r, false);
		draw_set_color(merge_colour(_col, c_white, 0.35));
		draw_set_alpha(0.6);
		draw_rectangle(_x1 + 2 + _r * 0.5, _y1 + 3, _x1 + 2 + max(_r, _w - _r * 0.5), _y1 + 2 + (_y2 - _y1) * 0.25, false);
		draw_set_alpha(1);
	}
}
function __hud_txt(_x, _y, _s, _sc, _col, _ha = fa_left, _font = fnt_menu) {
	draw_set_font(_font); draw_set_halign(_ha); draw_set_valign(fa_middle);
	draw_set_color(c_black); draw_set_alpha(0.7);
	draw_text_transformed(_x + 1.5, _y + 2, _s, _sc, _sc, 0);
	draw_set_alpha(1); draw_set_color(_col);
	draw_text_transformed(_x, _y, _s, _sc, _sc, 0);
}

function scr_hud_nuevo() {
	var _gw = display_get_gui_width(), _gh = display_get_gui_height();
	var _u = clamp(min(_gw / 1280, _gh / 720), 0.6, 1.6);
	var _ti = make_color_rgb(11, 15, 26), _panel = make_color_rgb(20, 24, 50);
	var _oro = make_color_rgb(255, 212, 71);
	var _colt = (scr_my_team() == "AZUL") ? make_color_rgb(31, 155, 255) : make_color_rgb(229, 72, 77);
	var _clase = (variable_instance_exists(id, "mi_clase") && mi_clase >= 0) ? mi_clase : (variable_global_exists("pj_selected") ? global.pj_selected : 0);
	var _con_q = variable_instance_exists(id, "hab_cd") && variable_instance_exists(id, "pj");

	// ---------- TU CARTA ----------
	var _extras = [];
	if (variable_instance_exists(id, "has_shield") && has_shield) array_push(_extras, [clamp(shield_timer / 600, 0, 1), make_color_rgb(80, 170, 255)]);
	if (variable_instance_exists(id, "damage_boost") && damage_boost > 1) array_push(_extras, [clamp(damage_timer / 600, 0, 1), make_color_rgb(255, 150, 40)]);
	if (variable_instance_exists(id, "speed_timer") && speed_timer > 0) array_push(_extras, [clamp(speed_timer / 600, 0, 1), make_color_rgb(150, 255, 90)]);
	if (variable_instance_exists(id, "infinite_ammo") && infinite_ammo && variable_instance_exists(id, "ammo_timer")) array_push(_extras, [clamp(ammo_timer / 600, 0, 1), make_color_rgb(80, 230, 255)]);
	var _x1 = 14 * _u, _y1 = 12 * _u, _cw = 300 * _u;
	var _ch = 76 * _u + array_length(_extras) * 11 * _u;
	__hud_caja(_x1, _y1, _x1 + _cw, _y1 + _ch, 14 * _u, _panel);
	// Retrato
	var _pr = 60 * _u, _px1 = _x1 + 8 * _u, _py1 = _y1 + 8 * _u;
	draw_set_color(merge_colour(_colt, c_black, 0.55));
	draw_roundrect_ext(_px1, _py1, _px1 + _pr, _py1 + _pr, 10 * _u, 10 * _u, false);
	if (variable_global_exists("pj_portraits") && _clase >= 0 && _clase < array_length(global.pj_portraits)) {
		var _spr = global.pj_portraits[_clase];
		var _sw = sprite_get_width(_spr), _sh = sprite_get_height(_spr);
		var _k = (_pr - 4) / _sw;
		draw_sprite_part_ext(_spr, 0, 0, _sh * 0.02, _sw, min(_sh, (_pr - 4) / _k), _px1 + 2, _py1 + 2, _k, _k, c_white, 1);
	}
	draw_set_color(_colt);
	draw_roundrect_ext(_px1, _py1, _px1 + _pr, _py1 + _pr, 10 * _u, 10 * _u, true);
	draw_roundrect_ext(_px1 + 1, _py1 + 1, _px1 + _pr - 1, _py1 + _pr - 1, 10 * _u, 10 * _u, true);
	// Nombre y personaje
	var _tx = _px1 + _pr + 10 * _u;
	var _bx2 = _con_q ? (_x1 + _cw - 62 * _u) : (_x1 + _cw - 10 * _u);
	__hud_txt(_tx, _y1 + 20 * _u, string_upper(string_copy(string(global.myName), 1, 12)), 0.62 * _u, c_white);
	if (variable_instance_exists(id, "pj")) __hud_txt(_bx2, _y1 + 20 * _u, pj.nombre, 0.42 * _u, _oro, fa_right, fnt_small);
	// Vida
	vida_visual = lerp(vida_visual, health, 0.2);
	var _mh = max(1, variable_instance_exists(id, "max_health") ? max_health : 100);
	var _pv = clamp(vida_visual / _mh, 0, 1);
	var _cv = (_pv < 0.3) ? make_color_rgb(240, 70, 70) : make_color_rgb(78, 220, 120);
	__hud_barra(_tx, _y1 + 32 * _u, _bx2, _y1 + 52 * _u, _pv, _cv);
	draw_set_font(fnt_small); draw_set_halign(fa_center); draw_set_valign(fa_middle);
	draw_set_color(_ti);
	draw_text_transformed((_tx + _bx2) / 2, _y1 + 42 * _u, string(max(0, ceil(health))) + " / " + string(_mh), 0.5 * _u, 0.5 * _u, 0);
	// Escudo y poderes: barritas finas debajo
	for (var e = 0; e < array_length(_extras); e++) {
		var _ey = _y1 + 58 * _u + e * 11 * _u;
		__hud_barra(_tx, _ey, _bx2, _ey + 8 * _u, _extras[e][0], _extras[e][1]);
	}
	// La Q adentro de la carta
	if (_con_q) scr_hab_hud(_x1 + _cw - 32 * _u, _y1 + 36 * _u);
	// Micro y bocina del chat de voz (en linea): debajo de la carta
	voz_hud_y = _y1 + _ch + 12 * _u;
	if (object_index == oPlayer) scr_voz_hud();

	// ---------- TU ARMA ----------
	var _wr = _gw - (touch_mode() ? 215 : 15) * _u;
	var _ww = 236 * _u, _wh = 92 * _u;
	var _wx1 = _wr - _ww, _wy1 = 12 * _u;
	__hud_caja(_wx1, _wy1, _wr, _wy1 + _wh, 14 * _u, _panel);
	var _mb = [_wx1 + 8 * _u, _wy1 + 8 * _u, _wx1 + 144 * _u, _wy1 + 62 * _u];
	draw_set_color(make_color_rgb(150, 160, 185));
	draw_roundrect_ext(_mb[0], _mb[1], _mb[2], _mb[3], 8 * _u, 8 * _u, false);
	draw_set_color(_ti);
	draw_roundrect_ext(_mb[0], _mb[1], _mb[2], _mb[3], 8 * _u, 8 * _u, true);
	var _w = guns[weapon.index];
	var _mcx = (_mb[0] + _mb[2]) / 2, _mcy = (_mb[1] + _mb[3]) / 2;
	if (_w != noone && is_struct(_w)) {
		var _s1 = _w.sprite;
		var _k1 = min((_mb[2] - _mb[0] - 16 * _u) / max(1, sprite_get_width(_s1)), (_mb[3] - _mb[1] - 10 * _u) / max(1, sprite_get_height(_s1)));
		draw_sprite_ext(_s1, 0, _mcx - (sprite_get_width(_s1) / 2 - sprite_get_xoffset(_s1)) * _k1, _mcy - (sprite_get_height(_s1) / 2 - sprite_get_yoffset(_s1)) * _k1, _k1, _k1, 0, scr_arma_tinte(_w), 1);
		var _res = variable_struct_exists(reserve, _w.ammoType) ? reserve[$ _w.ammoType] : 0;
		var _at = string(_w.ammo) + " / " + string(_res);
		if (_w.ammoType == "") _at = "x" + string(_w.ammo);
		__hud_txt(_mcx, _wy1 + 76 * _u, _at, 0.6 * _u, (_w.ammo == 0) ? make_color_rgb(240, 70, 70) : c_white, fa_center);
	} else {
		var _kh = 2.2 * _u;
		draw_sprite_ext(spr_Hand, 0, _mcx - 10 * _u, _mcy, _kh, _kh, 0, c_white, 1);
		__hud_txt(_mcx, _wy1 + 76 * _u, "MELEE", 0.6 * _u, make_color_rgb(80, 230, 255), fa_center);
	}
	// Segunda arma (cuadro chico; se toca o E para cambiar)
	var _gx = _wx1 + 190 * _u, _gy = _wy1 + 68 * _u;
	if (scr_slots_dos()) {
		scr_slot_init();
		var _sb = [_wx1 + 152 * _u, _wy1 + 12 * _u, _wr - 8 * _u, _wy1 + 50 * _u];
		slot2_x1 = _sb[0] - 4; slot2_y1 = _sb[1] - 4; slot2_x2 = _sb[2] + 4; slot2_y2 = _sb[3] + 8;
		var _o2 = guns[1 - weapon.index];
		draw_set_color(make_color_rgb(44, 54, 110));
		draw_roundrect_ext(_sb[0], _sb[1], _sb[2], _sb[3], 7 * _u, 7 * _u, false);
		draw_set_color(_ti);
		draw_roundrect_ext(_sb[0], _sb[1], _sb[2], _sb[3], 7 * _u, 7 * _u, true);
		if (_o2 != noone && is_struct(_o2)) {
			var _s2 = _o2.sprite;
			var _k2 = min((_sb[2] - _sb[0] - 10 * _u) / max(1, sprite_get_width(_s2)), (_sb[3] - _sb[1] - 8 * _u) / max(1, sprite_get_height(_s2)));
			var _c2x = (_sb[0] + _sb[2]) / 2, _c2y = (_sb[1] + _sb[3]) / 2;
			draw_sprite_ext(_s2, 0, _c2x - (sprite_get_width(_s2) / 2 - sprite_get_xoffset(_s2)) * _k2, _c2y - (sprite_get_height(_s2) / 2 - sprite_get_yoffset(_s2)) * _k2, _k2, _k2, 0, scr_arma_tinte(_o2), 0.85);
			if (!touch_mode()) {
				draw_set_color(_ti);
				draw_roundrect_ext(_sb[2] - 18 * _u, _sb[1] - 6 * _u, _sb[2] + 2 * _u, _sb[1] + 10 * _u, 4 * _u, 4 * _u, false);
				__hud_txt(_sb[2] - 8 * _u, _sb[1] + 2 * _u, "E", 0.45 * _u, c_white, fa_center);
			}
		}
	}
	// Granadas
	if (variable_instance_exists(id, "granadas") && granadas > 0) {
		var _gt = variable_instance_exists(id, "granada_tipo") ? granada_tipo : "";
		draw_sprite_ext(spr_granada, 0, _gx - 14 * _u, _gy + 8 * _u, 1.6 * _u, 1.6 * _u, 0, scr_granada_col(_gt), 1);
		__hud_txt(_gx + 2 * _u, _gy + 8 * _u, "x" + string(granadas), 0.55 * _u, _oro);
	}

	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	draw_set_color(c_white);
	draw_set_alpha(1);
}

// ======================================================
// MENU DE PAUSA NUEVO (oBrain Draw GUI y Step)
// ======================================================
function __mn_pausa_ops() {
	if (global.ONLINE) return ["CONTINUAR", "ABANDONAR PARTIDA"];
	if (global.bot_partida) return ["CONTINUAR", "SALIR AL MENU"];
	return ["CONTINUAR", "REINICIAR", "SALIR AL MENU"];
}
function __mn_pausa_r(_i, _n) { var _y = 200 - (_n * 52) / 2 + 30 + _i * 52; return [240, _y, 480, _y + 40]; }

/// Toque en una opcion de la pausa: -1 nada, o el numero de la opcion
function scr_mn_pausa_toque() {
	if (!MN_NUEVO || !device_mouse_check_button_pressed(0, mb_left)) return -1;
	__mn_init(); __mn_geo();
	var _q = global.mn_ui;
	var _px = (device_mouse_x_to_gui(0) - _q.ox) / _q.S, _py = (device_mouse_y_to_gui(0) - _q.oy) / _q.S;
	var _ops = __mn_pausa_ops();
	for (var i = 0; i < array_length(_ops); i++) if (__mn_dentro(_px, _py, __mn_pausa_r(i, array_length(_ops)))) return i;
	return -1;
}

function scr_mn_draw_pausa(_sel) {
	__mn_init(); __mn_geo();
	var _q = global.mn_ui;
	var _gw = display_get_gui_width(), _gh = display_get_gui_height();
	draw_set_alpha(0.6); draw_set_color(c_black);
	draw_rectangle(0, 0, _gw, _gh, false);
	draw_set_alpha(1);
	var _ops = __mn_pausa_ops();
	var _n = array_length(_ops);
	var _top = 200 - (_n * 52) / 2 - 40, _bot = 200 + (_n * 52) / 2 + 30;
	__mn_rect(210, _top + 6, 510, _bot + 6, 16, c_black, 0.5);
	__mn_rect(210, _top, 510, _bot, 16, __mn_col("panel"));
	__mn_rect(210, _top, 510, _bot, 16, __mn_col("tinta"), 1, true);
	__mn_rect(226, _top - 3, 306, _top + 3, 3, __mn_col("oro"));
	__mn_txt(360, _top + 32, "PAUSA", 22, c_white);
	var _px = (device_mouse_x_to_gui(0) - _q.ox) / _q.S, _py = (device_mouse_y_to_gui(0) - _q.oy) / _q.S;
	for (var i = 0; i < _n; i++) {
		var _r = __mn_pausa_r(i, _n);
		var _c = (i == 0) ? __mn_col("verde") : ((_ops[i] == "REINICIAR") ? __mn_col("azul") : __mn_col("rojo"));
		var _on = (i == _sel) || (!touch_mode() && __mn_dentro(_px, _py, _r));
		__mn_boton(_r[0], _r[1], _r[2], _r[3], _c, _ops[i], 14, (i == 0) ? __mn_col("tinta") : c_white, _on, 12);
	}
	__mn_reset_draw();
}


// ======================================================
// BUSCANDO JUGADORES (partida rapida): una casilla por cada jugador del modo.
// Se llenan en orden (tu equipo y luego los rivales) conforme el servidor dice que llega gente.
// Mientras buscas el servidor no manda nombres, solo cuantos hay: por eso dice "JUGADOR".
// ======================================================
function __mn_en_cola() {
	return variable_global_exists("qp_en_cola") ? global.qp_en_cola : 1;
}

/// Muñeco simple con el color del equipo (los que van llegando)
function __mn_monito(_cx, _cy, _col, _s) {
	__mn_rect(_cx - 22 * _s, _cy + 30 * _s, _cx + 22 * _s, _cy + 38 * _s, 4 * _s, make_color_rgb(10, 12, 30));
	__mn_rect(_cx - 17 * _s, _cy - 26 * _s, _cx + 17 * _s, _cy + 32 * _s, 8 * _s, _col);
	__mn_rect(_cx - 17 * _s, _cy - 26 * _s, _cx + 17 * _s, _cy + 32 * _s, 8 * _s, __mn_col("tinta"), 1, true);
	__mn_rect(_cx + 2 * _s, _cy - 14 * _s, _cx + 11 * _s, _cy - 5 * _s, 0, c_white);
	__mn_rect(_cx + 6 * _s, _cy - 12 * _s, _cx + 10 * _s, _cy - 7 * _s, 0, __mn_col("tinta"));
}

/// JEFE GIGANTE: la carta del jefe (el Sargento en rojo, con un borde que brilla)
function __mn_jefe_carta(_x1, _y1, _x2, _y2) {
	var _ti = __mn_col("tinta");
	var _p = 0.5 + 0.5 * sin(current_time / 250);
	__mn_rect(_x1 - 4, _y1 - 4, _x2 + 4, _y2 + 4, 12, make_color_rgb(255, 90 + floor(80 * _p), 70), 1, true);
	__mn_rect(_x1, _y1 + 4, _x2, _y2 + 4, 10, c_black, 0.6);
	__mn_rect(_x1, _y1, _x2, _y2, 10, __mn_osc(__mn_col("rojo"), 0.35));
	__mn_retrato(3, _x1 + 3, _y1 + 3, _x2 - 3, _y2 - 24, 1, make_color_rgb(255, 120, 130));
	__mn_rect(_x1 + 3, _y2 - 24, _x2 - 3, _y2 - 3, 4, _ti);
	__mn_rect(_x1, _y1, _x2, _y2, 10, _ti, 1, true);
	__mn_txt((_x1 + _x2) / 2, _y2 - 17, "EL SARGENTO", 8, c_white, fa_center, false);
	__mn_txt((_x1 + _x2) / 2, _y2 - 8, "GIGANTE", 6, __mn_col("gris"), fa_center, false, fnt_small);
}

function __mn_buscando_casillas(_tam) {
	var _q = global.mn_ui;
	_tam = clamp(_tam, 1, 4);
	var _n = clamp(__mn_en_cola(), 1, _tam * 2);
	// Cuando llega alguien nuevo, su casilla aparece con un saltito
	if (!variable_global_exists("qp_llegada") || !is_array(global.qp_llegada)) global.qp_llegada = [];
	while (array_length(global.qp_llegada) < _n) array_push(global.qp_llegada, current_time);
	if (array_length(global.qp_llegada) > _n) array_resize(global.qp_llegada, _n);   // alguien cancelo

	// JEFE GIGANTE: todas las casillas van en TU EQUIPO y del otro lado sale el jefe
	var _jefe = (scr_modo() == 8);
	var _tt = _jefe ? _tam * 2 : _tam;   // casillas de tu lado
	var _lado = 290, _gap = 8;
	var _sw = min(120, (_lado - (_tt - 1) * _gap) / _tt);
	var _sh = (_tt <= 2) ? 170 : 150;
	var _y1 = 150, _y2 = _y1 + _sh;
	var _a = current_time / 160;
	for (var _e = 0; _e < 2; _e++) {
		var _col = (_e == 0) ? __mn_col("azul") : __mn_col("rojo");
		var _x0 = (_e == 0) ? 40 : 390;
		if (_jefe && _e == 1) {
			__mn_txt(_x0 + _lado / 2, 140, "EL JEFE", 9, _col, fa_center, false);
			__mn_jefe_carta(_x0 + _lado / 2 - 61, _y1, _x0 + _lado / 2 + 61, _y2);
			continue;
		}
		var _cnt = (_e == 0) ? _tt : _tam;
		var _ancho = _cnt * _sw + (_cnt - 1) * _gap;
		var _xs = _x0 + (_lado - _ancho) / 2;
		__mn_txt(_x0 + _lado / 2, 140, (scr_modo() == 7) ? "JUGADORES" : ((_e == 0) ? "TU EQUIPO" : "RIVALES"), 9, _col, fa_center, false);
		for (var _k = 0; _k < _cnt; _k++) {
			var _idx = _e * _tam + _k;
			var _x1 = _xs + _k * (_sw + _gap), _x2 = _x1 + _sw;
			var _cx = (_x1 + _x2) / 2, _cy = (_y1 + _y2) / 2;
			if (_idx < _n) {
				// Casilla llena (con saltito al aparecer)
				var _p = clamp((current_time - global.qp_llegada[_idx]) / 350, 0, 1);
				var _c = 1.7, _b = 1 + (_c + 1) * power(_p - 1, 3) + _c * power(_p - 1, 2);
				var _g = (1 - _b) * 0.5;
				var _X1 = _cx - (_cx - _x1) * (1 - _g), _X2 = _cx + (_x2 - _cx) * (1 - _g);
				var _Y1 = _cy - (_cy - _y1) * (1 - _g), _Y2 = _cy + (_y2 - _cy) * (1 - _g);
				__mn_rect(_X1, _Y1 + 4, _X2, _Y2 + 4, 12, make_color_rgb(8, 10, 24));
				__mn_rect(_X1, _Y1, _X2, _Y2, 12, make_color_rgb(30, 38, 80));
				__mn_rect(_X1, _Y1, _X2, _Y2, 12, _col, 1, true);
				if (_p < 0.6) continue;
				if (_idx == 0) {
					// Tu: tu personaje de verdad
					var _spr = __mn_pj_sprite();
					var _alto = (_tt <= 2) ? 80 : 60;
					var _sk = min(_alto / max(1, sprite_get_height(_spr)), (_sw - 16) / max(1, sprite_get_width(_spr))) * _q.S;
					var _sw2 = sprite_get_width(_spr) * _sk, _sh2 = sprite_get_height(_spr) * _sk;
					draw_sprite_ext(_spr, (current_time div 120) mod max(1, sprite_get_number(_spr)),
						__mn_x(_cx) - _sw2 / 2 + sprite_get_xoffset(_spr) * _sk, __mn_y(_y2 - 40) - _sh2 + sprite_get_yoffset(_spr) * _sk, _sk, _sk, 0, c_white, 1);
					__mn_txt(_cx, _y2 - 30, string_upper(string_copy(string(global.myName), 1, (_tt <= 2) ? 12 : 9)), (_tt <= 2) ? 10 : 8, c_white);
					__mn_txt(_cx, _y2 - 15, "TU", 8, __mn_col("oro"));
				} else {
					__mn_monito(_cx, _cy - 14, _col, (_tt <= 2) ? 1.15 : 0.9);
					__mn_txt(_cx, _y2 - 30, "JUGADOR", (_tt <= 2) ? 10 : 8, c_white);
					// check verde
					draw_set_color(__mn_col("verde"));
					draw_circle(__mn_x(_cx), __mn_y(_y2 - 15), 7 * _q.S, false);
					draw_set_color(__mn_col("tinta"));
					draw_line_width(__mn_x(_cx - 4), __mn_y(_y2 - 15), __mn_x(_cx - 1), __mn_y(_y2 - 12), 2 * _q.S);
					draw_line_width(__mn_x(_cx - 1), __mn_y(_y2 - 12), __mn_x(_cx + 4), __mn_y(_y2 - 18), 2 * _q.S);
				}
			} else {
				// Casilla vacia: buscando (puntitos que giran)
				__mn_rect(_x1, _y1, _x2, _y2, 12, make_color_rgb(22, 26, 56));
				__mn_rect(_x1, _y1, _x2, _y2, 12, make_color_rgb(60, 70, 110), 1, true);
				var _r = (_tt <= 2) ? 14 : 11;
				for (var j = 0; j < 8; j++) {
					var _ang = _a + _idx * 0.6 + j * 0.785;
					var _cc = 80 + floor(170 * (j / 8));
					draw_set_color(make_color_rgb(_cc, _cc, _cc));
					draw_circle(__mn_x(_cx + _r * cos(_ang)), __mn_y(_cy - 10 + _r * sin(_ang)), 3.5 * _q.S, false);
				}
				__mn_txt(_cx, _y2 - 22, "BUSCANDO", (_tt <= 2) ? 9 : 7, __mn_col("gris"), fa_center, false);
			}
		}
	}
	draw_set_color(c_white);
	__mn_txt(360, 235, "VS", 28, __mn_col("oro"));
}

// ======================================================
// PANTALLA DE FIN NUEVA: VICTORIA / DERROTA / EMPATE (todos los modos)
//   Cada uno ve SU resultado: el que gano (y su equipo) VICTORIA, los demas DERROTA.
//   Tu personaje celebrando o triste, con su emote (pulgar arriba o llorando), lo que ganaste
//   y los botones de siempre (scr_fin_opciones). Va en el Draw GUI de oBrain (con oBrain).
// ======================================================
/// 1 gane, 0 perdi, 2 empate
function scr_fin_resultado() {
	if (global.winner_team == 3) return 2;
	if (scr_modo_todos()) return (global.winner_team == 2) ? 1 : 0;
	var _gana = (global.winner_team == 1) ? "ROJO" : "AZUL";
	return (scr_my_team() == _gana) ? 1 : 0;
}

/// Rectangulo del boton i de n (en la pantalla). Lo usan el dibujo y el toque.
function scr_fin_btn_r(_i, _n) {
	var _gw = display_get_gui_width(), _gh = display_get_gui_height();
	var _u = clamp(min(_gw / 1280, _gh / 720), 0.6, 2);
	var _bw = 300 * _u, _bh = 66 * _u, _sep = 40 * _u;
	var _tot = _n * _bw + (_n - 1) * _sep;
	var _x = _gw / 2 - _tot / 2 + _i * (_bw + _sep);
	var _y = _gh - _bh - 30 * _u;
	return [_x, _y, _x + _bw, _y + _bh];
}

/// ¿Tocaron un boton? (oBrain Step) Si si, lo deja elegido y devuelve true.
function scr_fin_toque() {
	if (!MN_NUEVO || !device_mouse_check_button_pressed(0, mb_left)) return false;
	var _ops = scr_fin_opciones();
	var _mx = device_mouse_x_to_gui(0), _my = device_mouse_y_to_gui(0);
	for (var _i = 0; _i < array_length(_ops); _i++) {
		var _r = scr_fin_btn_r(_i, array_length(_ops));
		if (point_in_rectangle(_mx, _my, _r[0], _r[1], _r[2], _r[3])) { victory_index = _i; return true; }
	}
	return false;
}

function scr_fin_nuevo_draw() {
	var _gw = display_get_gui_width(), _gh = display_get_gui_height();
	var _u = clamp(min(_gw / 1280, _gh / 720), 0.6, 2);
	var _cx = _gw / 2;
	if (!variable_instance_exists(id, "fin_t") || victory_alpha < 0.1) fin_t = 0;
	fin_t++;
	var _t = fin_t / 60;                  // segundos
	var _res = scr_fin_resultado();      // 1 gane, 0 perdi, 2 empate
	var _oro = make_color_rgb(255, 212, 71), _tinta = make_color_rgb(11, 15, 26);
	var _a = victory_alpha;
	draw_set_alpha(_a);

	// --- Fondo ---
	if (_res == 1) {
		draw_set_color(make_color_rgb(40, 30, 10));
		draw_rectangle(0, 0, _gw, _gh, false);
		draw_set_color(make_color_rgb(70, 52, 14));
		var _ry = _gh * 0.45, _L = max(_gw, _gh) * 1.5;
		for (var _k = 0; _k < 16; _k++) {
			var _an = _t * 0.4 + _k * pi / 8;
			draw_triangle(_cx, _ry, _cx + _L * cos(_an), _ry + _L * sin(_an), _cx + _L * cos(_an + 0.18), _ry + _L * sin(_an + 0.18), false);
		}
	} else if (_res == 0) {
		draw_rectangle_colour(0, 0, _gw, _gh, make_color_rgb(30, 22, 36), make_color_rgb(30, 22, 36), make_color_rgb(40, 28, 44), make_color_rgb(40, 28, 44), false);
		draw_set_color(make_color_rgb(80, 80, 110));
		for (var _k = 0; _k < 60; _k++) {
			var _lx = ((_k * 53 + _t * 40 * _u) mod (_gw + 20)) - 10;
			var _ly = (_k * 97 + _t * 300 * _u) mod (_gh + 20) - 10;
			draw_line_width(_lx, _ly, _lx - 3 * _u, _ly + 14 * _u, max(1, _u));
		}
	} else {
		__mn_fondo_wh(_gw, _gh);
	}
	draw_set_alpha(_a);

	// --- Titulo ---
	draw_set_font(fnt_menu); draw_set_halign(fa_center); draw_set_valign(fa_middle);
	var _tit = (_res == 1) ? "VICTORIA!" : ((_res == 0) ? "DERROTA" : "EMPATE");
	var _tc = (_res == 1) ? _oro : ((_res == 0) ? make_color_rgb(200, 80, 90) : _oro);
	var _p = clamp(_t / 0.5, 0, 1);
	var _ty = _gh * 0.13;
	var _ts = 2.6 * _u;
	if (_res == 1) { var _c = 1.7; _ts *= max(0.05, 1 + (_c + 1) * power(_p - 1, 3) + _c * power(_p - 1, 2)); }   // entra rebotando
	else _ty = _gh * 0.13 - (1 - (1 - power(1 - _p, 3))) * 40 * _u;                                          // cae despacio
	draw_text_transformed_color(_cx + 4 * _u, _ty + 4 * _u, _tit, _ts, _ts, 0, c_black, c_black, c_black, c_black, _a * 0.8);
	draw_text_transformed_color(_cx, _ty, _tit, _ts, _ts, 0, _tc, _tc, _tc, _tc, _a);

	// --- Tu equipo con los dibujos HD de cada personaje (tu al centro, con brillo) ---
	var _eq = [];   // [pj, nombre, soy_yo]
	var _yo_eq = scr_my_team();
	var _solo = scr_modo_todos();
	with (oOtherPlayer) {
		if (_solo || team == "" || team != _yo_eq) continue;
		array_push(_eq, [variable_instance_exists(id, "mySelectedPJ") ? clamp(mySelectedPJ, 0, 3) : 0, string(Name), false]);
	}
	// yo en medio
	var _mitad = floor(array_length(_eq) / 2);
	array_insert(_eq, _mitad, [variable_global_exists("pj_selected") ? clamp(global.pj_selected, 0, 3) : 0, string(global.myName), true]);
	var _nq = array_length(_eq);
	var _pie = _gh * 0.70;
	var _hyo = _gh * 0.44;                       // alto del personaje (el tuyo; los demas un poco menos)
	var _anchos = 0;
	for (var _k = 0; _k < _nq; _k++) {
		var _sp0 = global.pj_portraits[_eq[_k][0]];
		var _h0 = _eq[_k][2] ? _hyo : _hyo * 0.86;
		_anchos += sprite_get_width(_sp0) * (_h0 / sprite_get_height(_sp0)) + 24 * _u;
	}
	var _red = min(1, (_gw * 0.92) / max(1, _anchos));   // si no caben, todos un poco mas chicos
	var _xx = _cx - _anchos * _red / 2;
	var _yo_x = _cx, _yo_top = _pie - _hyo;
	for (var _k = 0; _k < _nq; _k++) {
		var _e = _eq[_k];
		var _spr = global.pj_portraits[_e[0]];
		var _sw = sprite_get_width(_spr), _sh = sprite_get_height(_spr);
		var _h = (_e[2] ? _hyo : _hyo * 0.86) * _red;
		var _kk = _h / _sh;
		var _w = _sw * _kk;
		var _sx = _xx + _w / 2 + 12 * _u * _red;
		_xx += _w + 24 * _u * _red;
		// entra desde abajo, uno por uno; si ganaron, dan saltitos
		var _ent = clamp((_t - 0.15 * _k) / 0.4, 0, 1);
		_ent = 1 - power(1 - _ent, 3);
		if (_ent <= 0) continue;
		var _salto = (_res == 1) ? abs(sin(_t * 4 + _k)) * 10 * _u : 0;
		var _sg = (_sx < _cx - 2) ? -1 : 1;     // los de la izquierda miran al centro
		var _dx = _sx + _sg * (sprite_get_xoffset(_spr) * _kk - _w / 2);
		var _dy = _pie - _h + sprite_get_yoffset(_spr) * _kk - _salto + (1 - _ent) * 80 * _u;
		var _al = _a * _ent;
		if (_e[2]) {
			// brillo alrededor (dorado si ganaste, gris si perdiste)
			gpu_set_fog(true, (_res == 1) ? _oro : make_color_rgb(120, 120, 150), 0, 0);
			for (var _o = 0; _o < 8; _o++) draw_sprite_ext(_spr, 0, _dx + lengthdir_x(5 * _u, _o * 45), _dy + lengthdir_y(5 * _u, _o * 45), _sg * _kk, _kk, 0, c_white, _al * 0.9);
			gpu_set_fog(false, c_white, 0, 0);
			_yo_x = _sx; _yo_top = _pie - _h - _salto;
		}
		draw_sprite_ext(_spr, 0, _dx, _dy, _sg * _kk, _kk, 0, (_res == 0) ? make_color_rgb(130, 130, 150) : c_white, _al);
		// plaquita con el nombre
		var _pw = min(_w + 20 * _u, 230 * _u), _ph = 28 * _u, _py = _pie + 8 * _u;
		draw_set_alpha(_al);
		draw_set_color(_tinta); draw_roundrect_ext(_sx - _pw / 2, _py, _sx + _pw / 2, _py + _ph, 10 * _u, 10 * _u, false);
		draw_set_color(_e[2] ? _oro : make_color_rgb(60, 70, 110)); draw_roundrect_ext(_sx - _pw / 2, _py, _sx + _pw / 2, _py + _ph, 10 * _u, 10 * _u, true);
		draw_set_color(_e[2] ? _oro : c_white);
		draw_text_transformed(_sx, _py + _ph / 2, string_upper(string_copy(_e[1], 1, 12)), 0.42 * _u, 0.42 * _u, 0);
		draw_set_alpha(_a);
	}
	// Tu emote arriba de ti: pulgar arriba si ganaste, llorando si perdiste
	if (_res != 2) {
		var _ep = clamp((_t - 0.6) / 0.3, 0, 1);
		var _es = (110 * _u / max(1, sprite_get_width(spr_emotes))) * (0.5 + 0.5 * (1 - power(1 - _ep, 3)));
		var _ex = _yo_x + 70 * _u, _ey = _yo_top + 30 * _u + sin(_t * 3) * 6 * _u;
		if (_ep > 0) draw_sprite_ext(spr_emotes, (_res == 1) ? 0 : 1, _ex, _ey, _es, _es, 0, c_white, _a * _ep);
	}

	// --- Lo que ganaste (no en sala privada) ---
	var _con_premio = global.bot_partida || (global.ONLINE && !scr_fin_es_privada());
	var _con_bots = global.bot_partida || (variable_global_exists("botnet_partida") && global.botnet_partida);
	if (_con_premio && _t > 0.6) {
		var _mon, _cop, _xp;
		if (_res == 2)      { _mon = "+25"; _cop = "0"; _xp = "+15"; }
		else if (_res == 1) { _mon = _con_bots ? "+30" : "+50"; _cop = _con_bots ? "+10" : "+25"; _xp = _con_bots ? "+15" : "+30"; }
		else                { _mon = _con_bots ? "+10" : "+20"; _cop = _con_bots ? "-5" : "-15"; _xp = _con_bots ? "+5" : "+10"; }
		var _vals = [_mon, _cop, _xp];
		var _cw = 170 * _u, _ch = 48 * _u, _gap = 20 * _u;
		var _x0 = _cx - (3 * _cw + 2 * _gap) / 2, _yy = _pie + 48 * _u;
		for (var _k = 0; _k < 3; _k++) {
			var _bx = _x0 + _k * (_cw + _gap);
			draw_set_color(_tinta); draw_roundrect_ext(_bx, _yy, _bx + _cw, _yy + _ch, 12 * _u, 12 * _u, false);
			draw_set_color(make_color_rgb(60, 70, 110)); draw_roundrect_ext(_bx, _yy, _bx + _cw, _yy + _ch, 12 * _u, 12 * _u, true);
			var _ix = _bx + 26 * _u, _iy = _yy + _ch / 2;
			if (_k == 0) {
				draw_set_color(_oro); draw_circle(_ix, _iy, 13 * _u, false);
				draw_set_color(make_color_rgb(214, 160, 30)); draw_circle(_ix, _iy, 7 * _u, false);
			} else if (_k == 1) {
				draw_set_color(_oro);
				draw_triangle(_ix - 12 * _u, _iy - 12 * _u, _ix + 12 * _u, _iy - 12 * _u, _ix, _iy + 4 * _u, false);
				draw_rectangle(_ix - 12 * _u, _iy - 12 * _u, _ix + 12 * _u, _iy - 6 * _u, false);
				draw_rectangle(_ix - 3 * _u, _iy + 2 * _u, _ix + 3 * _u, _iy + 9 * _u, false);
				draw_rectangle(_ix - 8 * _u, _iy + 9 * _u, _ix + 8 * _u, _iy + 13 * _u, false);
			} else {
				draw_set_color(make_color_rgb(80, 220, 255));
				draw_text_transformed(_ix, _iy, "XP", 0.45 * _u, 0.45 * _u, 0);
			}
			var _vc = (_k == 2) ? make_color_rgb(80, 220, 255) : ((string_char_at(_vals[_k], 1) == "-") ? make_color_rgb(229, 72, 77) : _oro);
			draw_set_halign(fa_right); draw_set_color(_vc);
			draw_text_transformed(_bx + _cw - 14 * _u, _iy, _vals[_k], 0.7 * _u, 0.7 * _u, 0);
			draw_set_halign(fa_center);
		}
	}

	// --- Confeti (solo al ganar) ---
	if (_res == 1) {
		for (var _k = 0; _k < 70; _k++) {
			var _fx = ((_k * 97) mod 1000) / 1000 * _gw + sin(_k + _t * 5) * 8 * _u;
			var _fy = ((((_k * 61) mod 1000) / 1000 * -0.6) + (0.006 + ((_k * 37) mod 100) / 12000) * _t * 60) mod 1.2;
			if (_fy < 0) continue;
			var _cc = [_oro, make_color_rgb(31, 155, 255), make_color_rgb(78, 220, 140), c_white, make_color_rgb(229, 72, 77)];
			draw_set_color(_cc[_k mod 5]);
			draw_rectangle(_fx - 4 * _u, _fy * _gh - 2 * _u, _fx + 4 * _u, _fy * _gh + 2 * _u, false);
		}
	}

	// --- Botones (los de siempre: scr_fin_opciones) ---
	if (victory_alpha >= 0.9) {
		var _ops = scr_fin_opciones();
		var _n = array_length(_ops);
		var _mx = device_mouse_x_to_gui(0), _my = device_mouse_y_to_gui(0);
		for (var _i = 0; _i < _n; _i++) {
			var _r = scr_fin_btn_r(_i, _n);
			var _sel = (victory_index == _i) || (!touch_mode() && point_in_rectangle(_mx, _my, _r[0], _r[1], _r[2], _r[3]));
			var _salir = (_ops[_i] == "SALIR");
			var _bc = _salir ? make_color_rgb(70, 80, 120) : ((_res == 1) ? make_color_rgb(78, 220, 140) : make_color_rgb(31, 155, 255));
			var _rr = 14 * _u;
			draw_set_color(__mn_osc(_bc, 0.45)); draw_roundrect_ext(_r[0], _r[1] + 6 * _u, _r[2], _r[3] + 6 * _u, _rr, _rr, false);
			draw_set_color(_bc); draw_roundrect_ext(_r[0], _r[1], _r[2], _r[3], _rr, _rr, false);
			draw_set_color(merge_colour(_bc, c_white, 0.25)); draw_roundrect_ext(_r[0] + 6 * _u, _r[1] + 5 * _u, _r[2] - 6 * _u, _r[1] + (_r[3] - _r[1]) * 0.42, 8 * _u, 8 * _u, false);
			draw_set_color(_sel ? c_white : _tinta);
			draw_roundrect_ext(_r[0], _r[1], _r[2], _r[3], _rr, _rr, true);
			draw_roundrect_ext(_r[0] + 1, _r[1] + 1, _r[2] - 1, _r[3] - 1, _rr, _rr, true);
			var _tcol = (!_salir && _res == 1) ? _tinta : c_white;
			draw_text_transformed_color((_r[0] + _r[2]) / 2 + 2, (_r[1] + _r[3]) / 2 + 3, _ops[_i], 0.6 * _u, 0.6 * _u, 0, c_black, c_black, c_black, c_black, 0.5);
			draw_text_transformed_color((_r[0] + _r[2]) / 2, (_r[1] + _r[3]) / 2 + 1, _ops[_i], 0.6 * _u, 0.6 * _u, 0, _tcol, _tcol, _tcol, _tcol, 1);
		}
	}
	draw_set_alpha(1); draw_set_halign(fa_left); draw_set_valign(fa_top); draw_set_color(c_white);
}

// ======================================================
// PANTALLA DE SUBISTE DE NIVEL (en el menu, nunca a media partida)
//   scr_xp_dar (scr_reloj) junta los niveles que subiste en global.lvl_pendiente.
//   Al estar en el menu principal se muestran uno por uno. Boton GENIAL! (o ENTER / ESC).
// ======================================================
function scr_lvl_activa() {
	return room == rm_menu && variable_global_exists("lvl_pendiente") && global.lvl_pendiente > 0
		&& instance_exists(oMenu) && oMenu.menu_state == "main";
}

function __lvl_btn_r() {
	var _gw = display_get_gui_width(), _gh = display_get_gui_height();
	var _u = clamp(min(_gw / 1280, _gh / 720), 0.6, 2);
	return [_gw - 300 * _u, _gh - 100 * _u, _gw - 30 * _u, _gh - 30 * _u];
}

/// oMenu Step (arriba). Devuelve true si la pantalla esta abierta (el menu no se mueve).
function scr_lvl_step() {
	if (!scr_lvl_activa()) { global.lvl_t = 0; return false; }
	if (!variable_global_exists("lvl_t")) global.lvl_t = 0;
	if (global.lvl_t == 0 && global.sfx) audio_play_sound(snd_levelup, 5, false);
	global.lvl_t++;
	if (global.lvl_t < 40) return true;   // que se vea un poco antes de poder cerrarla
	var _r = __lvl_btn_r();
	var _toque = device_mouse_check_button_pressed(0, mb_left) && point_in_rectangle(device_mouse_x_to_gui(0), device_mouse_y_to_gui(0), _r[0], _r[1], _r[2], _r[3]);
	if (_toque || vkey_pressed(vk_enter) || vkey_pressed(vk_escape) || keyboard_check_pressed(vk_space)) {
		global.lvl_pendiente = max(0, global.lvl_pendiente - 1);
		global.lvl_t = 0;
		menu_delay = 10;
	}
	return true;
}

/// oMenu Draw GUI (al final, encima de todo)
function scr_lvl_draw() {
	if (!scr_lvl_activa()) return;
	var _gw = display_get_gui_width(), _gh = display_get_gui_height();
	var _u = clamp(min(_gw / 1280, _gh / 720), 0.6, 2);
	var _t = (variable_global_exists("lvl_t") ? global.lvl_t : 0) / 60;
	var _oro = make_color_rgb(255, 212, 71), _tinta = make_color_rgb(11, 15, 26);
	var _nuevo = global.lvl - global.lvl_pendiente + 1;     // el nivel que se muestra ahora
	var _ultimo = (global.lvl_pendiente == 1);
	var _cx = _gw / 2, _by = _gh * 0.42;
	// Fondo con rayos dorados
	__mn_fondo_wh(_gw, _gh);
	gpu_set_blendmode(bm_add);
	draw_set_alpha(0.12);
	draw_set_color(_oro);
	var _L = max(_gw, _gh) * 1.5;
	for (var _k = 0; _k < 14; _k++) {
		var _a = _t * 0.5 + _k * pi / 7;
		draw_triangle(_cx, _by, _cx + _L * cos(_a), _by + _L * sin(_a), _cx + _L * cos(_a + 0.2), _by + _L * sin(_a + 0.2), false);
	}
	draw_set_alpha(1);
	gpu_set_blendmode(bm_normal);
	// Tu personaje HD entrando por la izquierda
	var _pj = variable_global_exists("pj_selected") ? clamp(global.pj_selected, 0, 3) : 0;
	if (variable_global_exists("pj_portraits")) {
		var _spr = global.pj_portraits[_pj];
		var _h = _gh * 0.72, _kk = _h / sprite_get_height(_spr);
		var _pe = 1 - power(1 - clamp(_t / 0.6, 0, 1), 3);
		var _px = 60 * _u + sprite_get_width(_spr) * _kk / 2 - (1 - _pe) * 300 * _u;
		draw_sprite_ext(_spr, 0, _px - sprite_get_width(_spr) * _kk / 2 + sprite_get_xoffset(_spr) * _kk, _gh - 10 * _u - _h + sprite_get_yoffset(_spr) * _kk, _kk, _kk, 0, c_white, 1);
	}
	draw_set_font(fnt_menu); draw_set_halign(fa_center); draw_set_valign(fa_middle);
	// Titulo que entra rebotando
	var _p = clamp(_t / 0.5, 0, 1), _c = 1.7;
	var _ts = 1.8 * _u * max(0.05, 1 + (_c + 1) * power(_p - 1, 3) + _c * power(_p - 1, 2));
	draw_text_transformed_color(_cx + 4 * _u, _gh * 0.11 + 4 * _u, "SUBISTE DE NIVEL!", _ts, _ts, 0, c_black, c_black, c_black, c_black, 0.8);
	draw_text_transformed_color(_cx, _gh * 0.11, "SUBISTE DE NIVEL!", _ts, _ts, 0, _oro, _oro, _oro, _oro, 1);
	// Medalla con el numero (cambia del nivel viejo al nuevo)
	var _q = clamp((_t - 0.2) / 0.5, 0, 1);
	var _r = 95 * _u * max(0, 1 + (_c + 1) * power(_q - 1, 3) + _c * power(_q - 1, 2));
	if (_r > 2) {
		var _rot = _t * 35;
		draw_set_color(make_color_rgb(170, 120, 20));
		for (var _k = 0; _k < 5; _k++) {
			var _a1 = 90 + _rot + _k * 72;
			draw_triangle(_cx + lengthdir_x(_r * 1.35, _a1), _by + lengthdir_y(_r * 1.35, _a1),
				_cx + lengthdir_x(_r * 0.7, _a1 + 36), _by + lengthdir_y(_r * 0.7, _a1 + 36),
				_cx + lengthdir_x(_r * 0.7, _a1 - 36), _by + lengthdir_y(_r * 0.7, _a1 - 36), false);
		}
		draw_set_color(_tinta); draw_circle(_cx, _by, _r + 4 * _u, false);
		draw_set_color(_oro); draw_circle(_cx, _by, _r, false);
		draw_set_color(make_color_rgb(240, 180, 40)); draw_circle(_cx, _by, _r * 0.8, false);
		var _num = (_t < 1) ? (_nuevo - 1) : _nuevo;
		var _ns = 1.6 * _u;
		if (_t > 0.85 && _t < 1) _ns *= max(0.1, 1 - (_t - 0.85) / 0.15);
		else if (_t >= 1) _ns *= 1 + 0.4 * max(0, 1 - (_t - 1) / 0.25);
		draw_text_transformed_color(_cx + 3 * _u, _by - 4 * _u + 3 * _u, string(_num), _ns, _ns, 0, c_black, c_black, c_black, c_black, 0.6);
		draw_text_transformed_color(_cx, _by - 4 * _u, string(_num), _ns, _ns, 0, c_white, c_white, c_white, c_white, 1);
		draw_set_color(_tinta);
		draw_text_transformed(_cx, _by + _r * 0.62, "NIVEL", 0.4 * _u, 0.4 * _u, 0);
	}
	// Barra de XP: se llena del nivel viejo y sigue con lo que sobro
	var _bw = 420 * _u, _bh = 18 * _u, _bx = _cx - _bw / 2, _byb = _by + 130 * _u;
	var _llen, _txt;
	if (_t < 1) { var _need0 = scr_xp_necesaria(_nuevo - 1); _llen = clamp(_t / 0.9, 0, 1); _txt = string(floor(_need0 * _llen)) + " / " + string(_need0) + " XP"; }
	else { var _need1 = scr_xp_necesaria(_nuevo); var _xp1 = _ultimo ? global.xp : 0; _llen = clamp(_xp1 / _need1, 0, 1) * clamp((_t - 1) / 0.5, 0, 1); _txt = string(_xp1) + " / " + string(_need1) + " XP"; }
	draw_set_color(_tinta); draw_roundrect_ext(_bx, _byb, _bx + _bw, _byb + _bh, 9 * _u, 9 * _u, false);
	draw_set_color(make_color_rgb(60, 70, 110)); draw_roundrect_ext(_bx, _byb, _bx + _bw, _byb + _bh, 9 * _u, 9 * _u, true);
	if (_llen > 0.02) { draw_set_color(make_color_rgb(80, 220, 255)); draw_roundrect_ext(_bx + 3 * _u, _byb + 3 * _u, _bx + 3 * _u + (_bw - 6 * _u) * _llen, _byb + _bh - 3 * _u, 6 * _u, 6 * _u, false); }
	draw_set_color(make_color_rgb(169, 180, 208));
	draw_text_transformed(_cx, _byb + _bh + 18 * _u, _txt, 0.4 * _u, 0.4 * _u, 0);
	// Armas que se abren en este nivel
	if (_t > 1.3) {
		var _cat = scr_eq_catalogo();
		var _arma = undefined;
		for (var _k = 0; _k < array_length(_cat); _k++) if (_cat[_k].lv == _nuevo) { _arma = _cat[_k]; break; }
		if (!is_undefined(_arma)) {
			var _e = 1 - power(1 - clamp((_t - 1.3) / 0.4, 0, 1), 3);
			var _cw = 440 * _u, _ch = 76 * _u, _x1 = _cx - _cw / 2, _y1 = _byb + 60 * _u + (1 - _e) * 30 * _u;
			draw_set_alpha(_e);
			draw_set_color(make_color_rgb(20, 24, 50)); draw_roundrect_ext(_x1, _y1, _x1 + _cw, _y1 + _ch, 14 * _u, 14 * _u, false);
			draw_set_color(_oro); draw_roundrect_ext(_x1, _y1, _x1 + _cw, _y1 + _ch, 14 * _u, 14 * _u, true);
			var _sw = sprite_get_width(_arma.spr), _sh = sprite_get_height(_arma.spr);
			var _sk = min(140 * _u / max(1, _sw), 56 * _u / max(1, _sh));
			draw_sprite_ext(_arma.spr, 0, _x1 + 90 * _u - _sw * _sk / 2 + sprite_get_xoffset(_arma.spr) * _sk, _y1 + _ch / 2 - _sh * _sk / 2 + sprite_get_yoffset(_arma.spr) * _sk, _sk, _sk, 0, c_white, _e);
			draw_set_halign(fa_left);
			draw_set_color(_oro); draw_text_transformed(_x1 + 180 * _u, _y1 + 24 * _u, "NUEVA ARMA DISPONIBLE", 0.35 * _u, 0.35 * _u, 0);
			draw_set_color(c_white); draw_text_transformed(_x1 + 180 * _u, _y1 + 52 * _u, _arma.nombre, 0.6 * _u, 0.6 * _u, 0);
			draw_set_halign(fa_center);
			draw_set_alpha(1);
		}
	}
	// Boton GENIAL!
	if (variable_global_exists("lvl_t") && global.lvl_t >= 40) {
		var _b = __lvl_btn_r(), _rr = 14 * _u, _bc = make_color_rgb(78, 220, 140);
		draw_set_color(__mn_osc(_bc, 0.45)); draw_roundrect_ext(_b[0], _b[1] + 6 * _u, _b[2], _b[3] + 6 * _u, _rr, _rr, false);
		draw_set_color(_bc); draw_roundrect_ext(_b[0], _b[1], _b[2], _b[3], _rr, _rr, false);
		draw_set_color(merge_colour(_bc, c_white, 0.25)); draw_roundrect_ext(_b[0] + 6 * _u, _b[1] + 5 * _u, _b[2] - 6 * _u, _b[1] + (_b[3] - _b[1]) * 0.42, 8 * _u, 8 * _u, false);
		draw_set_color(_tinta); draw_roundrect_ext(_b[0], _b[1], _b[2], _b[3], _rr, _rr, true);
		draw_text_transformed((_b[0] + _b[2]) / 2, (_b[1] + _b[3]) / 2 + 2, global.lvl_pendiente > 1 ? "SIGUIENTE" : "GENIAL!", 0.6 * _u, 0.6 * _u, 0);
	}
	// Confeti
	var _cc = [_oro, make_color_rgb(31, 155, 255), make_color_rgb(78, 220, 140), c_white, make_color_rgb(160, 90, 255)];
	for (var _k = 0; _k < 60; _k++) {
		var _fy = ((((_k * 61) mod 1000) / 1000 * -0.7) + (0.006 + ((_k * 37) mod 100) / 14000) * _t * 60);
		if (_fy < 0 || _fy > 1.1) continue;
		var _fx = ((_k * 97) mod 1000) / 1000 * _gw + sin(_k + _t * 5) * 8 * _u;
		draw_set_color(_cc[_k mod 5]);
		draw_rectangle(_fx - 4 * _u, _fy * _gh - 2 * _u, _fx + 4 * _u, _fy * _gh + 2 * _u, false);
	}
	draw_set_halign(fa_left); draw_set_valign(fa_top); draw_set_color(c_white); draw_set_alpha(1);
}
