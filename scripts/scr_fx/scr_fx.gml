#macro FX_HEADSHOT_MULT 1.5   // daño extra por headshot (pon 1 si solo quieres el color amarillo)
#macro FX_LOW_HEALTH    0.30  // "vida baja" = 30% o menos de la vida máxima
#macro FX_BEAT_FRAMES   52    // frames entre latidos (≈ 70 latidos por minuto a 60fps)

function fx_init() {
    global.fx_nums   = [];
    global.fx_lights = [];
    global.fx_room   = room;
    global.fx_beat   = 0;

    global.fx_ps = part_system_create();
    part_system_depth(global.fx_ps, -10000);

    // Chispas
    var _t = part_type_create();
    part_type_shape(_t, pt_shape_line);
    part_type_size(_t, 0.12, 0.22, -0.006, 0);
    part_type_orientation(_t, 0, 0, 0, 0, true);
    part_type_speed(_t, 3, 7, -0.25, 0);
    part_type_gravity(_t, 0.25, 270);
    part_type_colour3(_t, c_white, c_yellow, c_orange);
    part_type_alpha2(_t, 1, 0);
    part_type_blend(_t, true);
    part_type_life(_t, 12, 22);
    global.fx_spark = _t;

    // Pedacitos
    _t = part_type_create();
    part_type_shape(_t, pt_shape_square);
    part_type_size(_t, 0.04, 0.08, 0, 0);
    part_type_speed(_t, 2, 5, -0.05, 0);
    part_type_gravity(_t, 0.35, 270);
    part_type_colour2(_t, c_ltgray, c_dkgray);
    part_type_alpha2(_t, 1, 0);
    part_type_orientation(_t, 0, 360, 8, 0, false);
    part_type_life(_t, 25, 40);
    global.fx_bit = _t;

    // Polvo
    _t = part_type_create();
    part_type_shape(_t, pt_shape_cloud);
    part_type_size(_t, 0.12, 0.22, 0.008, 0);
    part_type_speed(_t, 0.4, 1.6, -0.03, 0);
    part_type_colour1(_t, make_color_rgb(205, 205, 210));
    part_type_alpha2(_t, 0.45, 0);
    part_type_life(_t, 20, 32);
    global.fx_dust = _t;
}

function fx_sparks(_x, _y, _dir, _n, _hot = false) {
    if (!variable_global_exists("fx_ps")) return;
    part_type_direction(global.fx_spark, _dir - 45, _dir + 45, 0, 0);
    if (_hot) part_type_colour3(global.fx_spark, c_white, c_orange, c_red);
    else      part_type_colour3(global.fx_spark, c_white, c_yellow, c_orange);
    part_particles_create(global.fx_ps, _x, _y, global.fx_spark, _n);
    part_type_direction(global.fx_bit, _dir - 60, _dir + 60, 0, 0);
    part_particles_create(global.fx_ps, _x, _y, global.fx_bit, ceil(_n / 2));
}

function fx_dust(_x, _y, _n, _side = 0) {
    if (!variable_global_exists("fx_ps")) return;
    if (_side == 0)     part_type_direction(global.fx_dust, 20, 160, 0, 0);
    else if (_side > 0) part_type_direction(global.fx_dust, 0, 40, 0, 0);
    else                part_type_direction(global.fx_dust, 140, 180, 0, 0);
    repeat (_n) part_particles_create(global.fx_ps, _x + random_range(-9, 9), _y, global.fx_dust, 1);
}

/// _kind: 0 normal, 1 headshot, 2 pesado (bazooka/granada), 3 daño que recibo yo
function fx_damage_number(_x, _y, _dmg, _kind = 0) {
    if (!variable_global_exists("fx_nums")) return;
    var _col = c_white, _sc = 1;
    switch (_kind) {
        case 1: _col = make_color_rgb(255, 210, 63); _sc = 1.3;  break;
        case 2: _col = make_color_rgb(255, 154, 60); _sc = 1.8;  break;
        case 3: _col = make_color_rgb(255, 74, 74);  _sc = 0.85; break;
    }
    array_push(global.fx_nums, {
        x: _x + random_range(-10, 10), y: _y,
        vx: random_range(-0.6, 0.6), vy: -3.2,
        t: 0, life: 50,
        txt: "-" + string(round(_dmg)), col: _col, sc: _sc
    });
}

function fx_light(_x, _y, _r, _col, _life) {
    if (!variable_global_exists("fx_lights")) return;
    array_push(global.fx_lights, { x: _x, y: _y, r: _r, col: _col, t: 0, life: _life });
}

function fx_low_health() {
    if (!instance_exists(oPlayer) || global.game_over || room == rm_menu) return false;
    var _max = variable_instance_exists(oPlayer, "max_health") ? oPlayer.max_health : 100;
    return (!oPlayer.isDead && health > 0 && health <= _max * FX_LOW_HEALTH);
}

function fx_step() {
    if (!variable_global_exists("fx_nums")) return;
    if (global.fx_room != room) {
        global.fx_room = room;
        part_particles_clear(global.fx_ps);
        global.fx_nums = [];
        global.fx_lights = [];
    }
    for (var i = array_length(global.fx_nums) - 1; i >= 0; i--) {
        var _n = global.fx_nums[i];
        _n.t++; _n.x += _n.vx; _n.y += _n.vy; _n.vy *= 0.9;
        if (_n.t >= _n.life) array_delete(global.fx_nums, i, 1);
    }
    for (var i = array_length(global.fx_lights) - 1; i >= 0; i--) {
        var _l = global.fx_lights[i];
        _l.t++;
        if (_l.t >= _l.life) array_delete(global.fx_lights, i, 1);
    }
    if (fx_low_health()) {
        if (global.fx_beat mod FX_BEAT_FRAMES == 0 && global.sfx) {
            var _snd = asset_get_index("snd_heartbeat");
            if (_snd != -1) audio_play_sound(_snd, 5, false);
        }
        global.fx_beat++;
    } else {
        global.fx_beat = 0;
    }
}

function fx_vig_edge(_x1, _y1, _x2, _y2, _x3, _y3, _x4, _y4, _c, _a) {
    draw_vertex_colour(_x1, _y1, _c, _a); draw_vertex_colour(_x2, _y2, _c, _a); draw_vertex_colour(_x3, _y3, _c, 0);
    draw_vertex_colour(_x1, _y1, _c, _a); draw_vertex_colour(_x3, _y3, _c, 0); draw_vertex_colour(_x4, _y4, _c, 0);
}

function fx_draw_gui() {
    if (!variable_global_exists("fx_nums") || room == rm_menu) return;

    var _cam = view_camera[0];
    var _vx = camera_get_view_x(_cam), _vy = camera_get_view_y(_cam);
    var _vw = camera_get_view_width(_cam), _vh = camera_get_view_height(_cam);
    var _gw = display_get_gui_width(), _gh = display_get_gui_height();
    var _sx = _gw / _vw, _sy = _gh / _vh;

    // 1) BRILLO
    gpu_set_blendmode(bm_add);
    draw_set_circle_precision(32);
    for (var i = 0; i < array_length(global.fx_lights); i++) {
        var _l = global.fx_lights[i];
        draw_set_alpha((1 - _l.t / _l.life) * 0.85);
        draw_circle_colour((_l.x - _vx) * _sx, (_l.y - _vy) * _sy, _l.r * _sx, _l.col, c_black, false);
    }
    draw_set_alpha(0.45 + sin(current_time * 0.005) * 0.2);
    with (oPowerupPickup) {
        draw_circle_colour((x - _vx) * _sx, (y - _vy) * _sy, 40 * _sx, make_color_rgb(255, 210, 63), c_black, false);
    }
    draw_set_alpha(0.7);
    var _org = make_color_rgb(255, 138, 42);
    with (oMyEntity)           { if (is_rocket && !exploded) draw_circle_colour((x - _vx) * _sx, (y - _vy) * _sy, 26 * _sx, _org, c_black, false); }
    with (oOtherPlayersEntity) { if (is_rocket)              draw_circle_colour((x - _vx) * _sx, (y - _vy) * _sy, 26 * _sx, _org, c_black, false); }
    gpu_set_blendmode(bm_normal);
    draw_set_alpha(1);

    // 2) NÚMEROS DE DAÑO
    draw_set_font(fnt_menu);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    for (var i = 0; i < array_length(global.fx_nums); i++) {
        var _n = global.fx_nums[i];
        var _pop = (_n.t < 6) ? 1.6 - _n.t * 0.1 : 1;
        var _a = (_n.t > _n.life * 0.65) ? 1 - (_n.t - _n.life * 0.65) / (_n.life * 0.35) : 1;
        var _gx = (_n.x - _vx) * _sx, _gy = (_n.y - _vy) * _sy, _s = _n.sc * _pop;
        draw_set_alpha(_a);
        draw_set_colour(c_black);
        draw_text_transformed(_gx - 2, _gy, _n.txt, _s, _s, 0);
        draw_text_transformed(_gx + 2, _gy, _n.txt, _s, _s, 0);
        draw_text_transformed(_gx, _gy - 2, _n.txt, _s, _s, 0);
        draw_text_transformed(_gx, _gy + 2, _n.txt, _s, _s, 0);
        draw_set_colour(_n.col);
        draw_text_transformed(_gx, _gy, _n.txt, _s, _s, 0);
    }
    draw_set_alpha(1);

    // 3) VIÑETA ROJA DE VIDA BAJA
    if (fx_low_health()) {
        var _ph = (global.fx_beat mod FX_BEAT_FRAMES) / FX_BEAT_FRAMES;
        var _beat = max(exp(-_ph * 14), 0.6 * exp(-abs(_ph - 0.18) * 14));
        var _a = 0.35 + _beat * 0.45;
        var _t = min(_gw, _gh) * 0.28;
        var _c = make_color_rgb(200, 0, 20);
        draw_primitive_begin(pr_trianglelist);
        fx_vig_edge(0, 0,     _gw, 0,   _gw - _t, _t,       _t, _t,              _c, _a);
        fx_vig_edge(_gw, 0,   _gw, _gh, _gw - _t, _gh - _t, _gw - _t, _t,        _c, _a);
        fx_vig_edge(_gw, _gh, 0, _gh,   _t, _gh - _t,       _gw - _t, _gh - _t,  _c, _a);
        fx_vig_edge(0, _gh,   0, 0,     _t, _t,             _t, _gh - _t,        _c, _a);
        draw_primitive_end();
    }

    draw_set_alpha(1);
    draw_set_colour(c_white);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}
/// Chispas en MI pantalla + aviso para que los DEMÁS también las vean
function fx_impact_net(_x, _y, _dir, _n, _hot = false) {
    fx_sparks(_x, _y, _dir, _n, _hot);
    if (global.ONLINE) {
        var _m = { x: round(_x), y: round(_y), d: round(_dir), n: _n, h: _hot };
        with (oOtherPlayer) SendEventToClient(clientId, "fx_impact", _m);
    }
}
