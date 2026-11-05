function gmda_draw_achievements(xc, yc) {
    var rowspace = 90;
    var horsize = 550;
    var visible_height = rowspace * 5;

    var _tinta = make_color_rgb(11, 15, 26);
    var _azul  = make_color_rgb(31, 155, 255);
    var _rojo  = make_color_rgb(255, 42, 58);
    var _oro   = make_color_rgb(255, 212, 71);
    var _gris  = make_color_rgb(169, 180, 208);
    var _verde = make_color_rgb(78, 255, 145);
    var _cols  = [_oro, _azul, _rojo];

    var table = gmda_get_achievement_list();
    if (is_undefined(table)) exit;
    var size = ds_map_size(table);

    if (!surface_exists(oMenu.ach_surf)) {
        oMenu.ach_surf = surface_create(horsize, visible_height);
    }

    surface_set_target(oMenu.ach_surf);
    draw_clear_alpha(c_black, 0);

    for (var i = 0; i < size; i++) {
        var infoachievement = ds_map_find_value(table, string(i + 1));
        var name = ds_map_find_value(infoachievement, "name");
        var descrip = ds_map_find_value(infoachievement, "descrip");
        var img_num = real(ds_map_find_value(infoachievement, "value"));
        var id_ach = ds_map_find_value(infoachievement, "ide");
        var achieved = gmda_check_achievement(id_ach);

        var ry = (rowspace * i) - oMenu.scroll_y;

        if (ry > -rowspace && ry < visible_height) {
            var _c = achieved ? _cols[i mod 3] : _gris;

            // Fondo de la fila
            ctf_ui_para(5, ry + 6, horsize - 10, rowspace - 12, 12, _tinta, 0.9, false);
            ctf_ui_para(5, ry + 6, horsize - 10, rowspace - 12, 12, _c, achieved ? 0.07 : 0.02, false);
            ctf_ui_para(5, ry + 6, horsize - 10, rowspace - 12, 12, _c, achieved ? 0.5 : 0.15, true);
            if (achieved) ctf_ui_para(5, ry + 6, 16, rowspace - 12, 12, _c, 1, false);

            // Icono
            draw_sprite_ext(spr_achievements_images, img_num, 30, ry + (rowspace / 2) - 24, 1.5, 1.5, 0, achieved ? c_white : c_gray, achieved ? 1 : 0.3);

            // Textos
            draw_set_halign(fa_left);
            draw_set_valign(fa_middle);
            draw_set_font(fnt_menu);
            draw_set_color(achieved ? c_white : _gris);
            draw_set_alpha(achieved ? 1 : 0.45);
            draw_text_transformed(100, ry + 30, string(i + 1) + ". " + string_upper(name), 0.8, 0.8, 0);
            draw_set_alpha(1);

            draw_set_font(fnt_small);
            draw_set_color(_gris);
            draw_set_alpha(0.55);
            draw_text_ext_transformed(100, ry + 58, descrip, 22, (horsize - 230) / 0.65, 0.65, 0.65, 0);
            draw_set_alpha(1);

            // Estado
            draw_set_halign(fa_right);
            draw_set_color(achieved ? _verde : _gris);
            draw_set_alpha(achieved ? 1 : 0.4);
            draw_text_transformed(horsize - 24, ry + 30, achieved ? "LOGRADO" : "BLOQUEADO", 0.6, 0.6, 0);
            draw_set_alpha(1);
        }
    }
    surface_reset_target();

    // Marco general
    draw_set_color(_tinta);
    draw_set_alpha(0.6);
    draw_rectangle(xc - 10, yc - 10, xc + horsize + 18, yc + visible_height + 10, false);
    draw_set_alpha(0.15);
    draw_set_color(_gris);
    draw_rectangle(xc - 10, yc - 10, xc + horsize + 18, yc + visible_height + 10, true);
    draw_set_alpha(1);

    draw_surface(oMenu.ach_surf, xc, yc);

    // Barra de scroll
    draw_set_color(_gris);
    draw_set_alpha(0.15);
    draw_rectangle(xc + horsize + 6, yc, xc + horsize + 10, yc + visible_height, false);
    draw_set_alpha(1);
    var bar_pos = (oMenu.scroll_y / max(1, scroll_max)) * (visible_height - 30);
    draw_set_color(_azul);
    draw_rectangle(xc + horsize + 6, yc + bar_pos, xc + horsize + 10, yc + bar_pos + 30, false);
}
