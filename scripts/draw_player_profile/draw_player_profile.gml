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

    // Panel
    draw_set_color(C_TINTA); draw_set_alpha(0.7);
    draw_rectangle(0, 0, LW, LH, false);
    draw_set_color(C_GRIS); draw_set_alpha(0.12);
    draw_rectangle(0, 0, LW, LH, true);
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
    draw_text_transformed(x0 + colw - 16, xy + 32 + 18, string(global.xp) + " / 100 XP", 0.6, 0.6, 0);

    var tx = x0 + 16;
    var tw = colw - 32;
    var ty = xy + 32 + 34;
    draw_set_color(C_GRIS); draw_set_alpha(0.1);
    draw_rectangle(tx, ty, tx + tw, ty + 6, false);
    draw_set_alpha(1);
    var fw = tw * clamp(global.xp / 100, 0, 1);
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
    var table = gmda_get_achievement_list();
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
        if (gmda_check_achievement(ach[a3].ide)) obtained++;
    }

    var lyy = top + 32;
    var lh = 32 + show_n * rh + 32;
    ctf_ui_section(x1, lyy, colw, lh, "LOGROS", C_AZUL, C_GRIS);

    var ic_cols = [C_ORO, C_AZUL, C_ROJO];
    for (var a4 = 0; a4 < show_n; a4++) {
        var ry = lyy + 32 + a4 * rh;
        var got = gmda_check_achievement(ach[a4].ide);

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
