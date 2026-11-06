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
    if (variable_global_exists("opt") && global.opt.danio == 0) return; // apagado en AJUSTES
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
    var _muerto = variable_instance_exists(oPlayer, "isDead") ? oPlayer.isDead : false;
    return (!_muerto && health > 0 && health <= _max * FX_LOW_HEALTH);
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


// ======================================================
// BANDERA: efectos visuales (solo dibujo, no cambia nada del juego ni de la red)
// - Sin agarrar: FARO de luz centrado en la bandera + anillo en el piso + flota un poquito
// - Agarrada: va en la ESPALDA del portador, ondea mas rapido al correr y deja ESTELA
// Se llama desde el Draw de oFlag (roja) y oFlag2 (azul).
// ======================================================
function flag_draw_fx(_col) {
    if (!variable_instance_exists(id, "fx_trail")) {
        fx_trail  = [];
        fx_prev_x = x;
        fx_frame  = 0;
    }
    var _t = current_time / 1000;

    if (!has_flag) {
        // ---------- A1: FARO ----------
        var _cx  = (bbox_left + bbox_right) / 2;   // centro real de la bandera
        var _bot = bbox_bottom;
        var _top = _bot - 170;
        var _hw  = max(6, (bbox_right - bbox_left) * 0.45);

        gpu_set_blendmode(bm_add);
        // Haz ancho (se desvanece hacia arriba)
        draw_primitive_begin(pr_trianglestrip);
        draw_vertex_colour(_cx - _hw, _top, _col, 0);
        draw_vertex_colour(_cx + _hw, _top, _col, 0);
        draw_vertex_colour(_cx - _hw, _bot, _col, 0.30);
        draw_vertex_colour(_cx + _hw, _bot, _col, 0.30);
        draw_primitive_end();
        // Nucleo brillante
        draw_primitive_begin(pr_trianglestrip);
        draw_vertex_colour(_cx - 1.5, _top, _col, 0);
        draw_vertex_colour(_cx + 1.5, _top, _col, 0);
        draw_vertex_colour(_cx - 1.5, _bot, _col, 0.65);
        draw_vertex_colour(_cx + 1.5, _bot, _col, 0.65);
        draw_primitive_end();
        // Anillo en el piso que late
        var _r = _hw * 2.2 + 3 * sin(_t * 3);
        draw_set_colour(_col);
        draw_set_alpha(0.6);
        draw_ellipse(_cx - _r, _bot - _r * 0.25, _cx + _r, _bot + _r * 0.25, true);
        draw_set_alpha(1);
        gpu_set_blendmode(bm_normal);

        // La bandera flota un poquito
        var _bob = -2 - 2 * sin(_t * 2.5);
        draw_sprite_ext(sprite_index, image_index, x, y + _bob, image_xscale, image_yscale, image_angle, image_blend, image_alpha);

        fx_trail = [];
        fx_prev_x = x;
    }
    else {
        // ---------- B1: EN LA ESPALDA + ESTELA ----------
        var _dir = sign(image_xscale);
        if (_dir == 0) _dir = 1;
        var _mov = abs(x - fx_prev_x);
        fx_prev_x = x;

        // Estela de chispas del color del equipo (solo cuando se mueve)
        if (_mov > 0.5) {
            array_push(fx_trail, { px: x - _dir * 10 + random_range(-2, 2), py: y + 4 + random_range(-5, 5), a: 1 });
        }
        gpu_set_blendmode(bm_add);
        draw_set_colour(_col);
        for (var i = array_length(fx_trail) - 1; i >= 0; i--) {
            var _p = fx_trail[i];
            _p.a -= 0.04;
            if (_p.a <= 0) { array_delete(fx_trail, i, 1); continue; }
            draw_set_alpha(_p.a * 0.85);
            draw_rectangle(_p.px, _p.py, _p.px + 1, _p.py + 1, false);
        }
        draw_set_alpha(1);
        gpu_set_blendmode(bm_normal);

        // Ondea mas rapido si corre
        fx_frame += (_mov > 0.5) ? 0.35 : 0.12;
        var _nf = max(1, sprite_get_number(sprite_index));

        // La tela queda hacia atras y el mastil pegado a la espalda
        var _fx = x - 13 * _dir;
        draw_sprite_ext(sprite_index, floor(fx_frame) mod _nf, _fx, y + 2, -_dir, image_yscale, 0, image_blend, image_alpha);
    }
}

// ======================================================
// AJUSTES DEL JUGADOR (pantalla OPTIONS del menu)
// Se guardan en "ajustes.ini" en cada aparato (PC, Android y HTML5).
// ======================================================
function opt_init() {
    if (variable_global_exists("opt")) return;
    global.opt = {
        vol: 80,        // volumen general 0..100
        sfx: 1,         // efectos de sonido (1 si / 0 no). Ya no sale en ajustes: lo pone vol_sfx
        musica: 1,      // musica (1 si / 0 no). Ya no sale en ajustes: lo pone vol_musica
        vol_musica: 70, // volumen de la musica 0..100 (0 = apagada)
        vol_sfx: 100,   // volumen de los efectos 0..100 (0 = apagados)
        pantalla: 0,    // pantalla completa (PC / HTML5)
        minimapa: 0,    // 0 esquina, 1 tira, 2 barra, 3 apagado
        ping: 1,        // mostrar ping
        danio: 1,       // numeros de dano
        temblor: 0,     // 0 normal, 1 suave, 2 apagado
        btn_tam: 0,     // botones del celular: 0 normal, 1 grande, 2 chico
        btn_alpha: 70,  // que tanto se ven los botones del celular (70 = como antes)
        mira: 0         // distancia de la mira en el celular: 0 normal, 1 lejos, 2 cerca
    };
    ini_open("ajustes.ini");
    var _viejo = !ini_key_exists("ajustes", "vol_sfx");   // ajustes de antes de las barras de musica/efectos
    var _k = variable_struct_get_names(global.opt);
    for (var i = 0; i < array_length(_k); i++) {
        global.opt[$ _k[i]] = ini_read_real("ajustes", _k[i], global.opt[$ _k[i]]);
    }
    ini_close();
    // Si antes los tenia en NO, que sigan apagados
    if (_viejo) {
        if (global.opt.sfx == 0) global.opt.vol_sfx = 0;
        if (global.opt.musica == 0) global.opt.vol_musica = 0;
    }
}

function opt_guardar() {
    opt_init();
    ini_open("ajustes.ini");
    var _k = variable_struct_get_names(global.opt);
    for (var i = 0; i < array_length(_k); i++) ini_write_real("ajustes", _k[i], global.opt[$ _k[i]]);
    ini_close();
}

/// Aplica los ajustes al juego. _inicio = true al arrancar (en el navegador la pantalla
/// completa solo se puede pedir cuando el jugador toca algo, por eso ahi no se aplica).
function opt_apply(_inicio = false) {
    opt_init();
    audio_master_gain(global.opt.vol / 100);
    global.sfx    = (global.opt.vol_sfx > 0);
    global.musica = (global.opt.vol_musica > 0);
    global.music  = global.musica;
    global.opt.sfx    = global.sfx ? 1 : 0;
    global.opt.musica = global.musica ? 1 : 0;
    scr_audio_volumenes();
    if (!touch_mode()) {
        if (!_inicio || os_browser == browser_not_a_browser) {
            if (window_get_fullscreen() != (global.opt.pantalla == 1)) window_set_fullscreen(global.opt.pantalla == 1);
        }
    }
}

/// Filas de la pantalla de ajustes (col 0 = izquierda, col 1 = derecha)
function opt_filas() {
    return [
        { k: "vol",       n: "VOLUMEN GENERAL",      slider: true, sec: "SONIDO", col: 0 },
        { k: "vol_musica", n: "MUSICA",              slider: true, col: 0 },
        { k: "vol_sfx",   n: "EFECTOS DE SONIDO",    slider: true, col: 0 },
        { k: "pantalla",  n: "PANTALLA COMPLETA",    o: ["NO", "SI"], sec: "PANTALLA", col: 0 },
        { k: "minimapa",  n: "MINI MAPA",            o: ["ESQUINA", "TIRA", "BARRA", "APAGADO"], col: 0 },
        { k: "ping",      n: "MOSTRAR PING",         o: ["NO", "SI"], col: 0 },
        { k: "danio",     n: "NUMEROS DE DANO",      o: ["NO", "SI"], col: 0 },
        { k: "temblor",   n: "TEMBLOR DE PANTALLA",  o: ["NORMAL", "SUAVE", "APAGADO"], col: 0 },
        { k: "btn_tam",   n: "TAMANO DE BOTONES",    o: ["NORMAL", "GRANDE", "CHICO"], sec: "CONTROLES DEL CELULAR", col: 1 },
        { k: "btn_alpha", n: "VISIBILIDAD BOTONES",  slider: true, col: 1 },
        { k: "mira",      n: "DISTANCIA DE LA MIRA", o: ["NORMAL", "LEJOS", "CERCA"], col: 1 }
    ];
}

/// Cambia una fila (_dir = -1 o 1), lo aplica y lo guarda.
function opt_cambiar(_i, _dir) {
    opt_init();
    var _f = opt_filas();
    if (_i < 0 || _i >= array_length(_f)) return;
    var _r = _f[_i];
    if (_r.k == "pantalla" && touch_mode()) return; // en el celular siempre es pantalla completa
    var _v = global.opt[$ _r.k];
    if (variable_struct_exists(_r, "slider")) {
        var _min = (_r.k == "btn_alpha") ? 20 : 0;
        _v = clamp(_v + _dir * 10, _min, 100);
    } else {
        var _n = array_length(_r.o);
        _v = (_v + _dir + _n) mod _n;
    }
    global.opt[$ _r.k] = _v;
    opt_apply(false);
    opt_guardar();
}

/// Texto del valor de una fila
function opt_valor_txt(_r) {
    if (_r.k == "pantalla" && touch_mode()) return "SIEMPRE";
    var _v = global.opt[$ _r.k];
    if (variable_struct_exists(_r, "slider")) return string(_v) + "%";
    return _r.o[clamp(_v, 0, array_length(_r.o) - 1)];
}

/// Multiplicadores que usan otras partes del juego
function opt_temblor_mult() { opt_init(); return [1, 0.5, 0][clamp(global.opt.temblor, 0, 2)]; }
function opt_btn_escala()   { opt_init(); return [1, 1.25, 0.8][clamp(global.opt.btn_tam, 0, 2)]; }
function opt_btn_alpha()    { opt_init(); return global.opt.btn_alpha / 70; }
function opt_mira_mult()    { opt_init(); return [1, 1.4, 0.7][clamp(global.opt.mira, 0, 2)]; }


// ======================================================
// MINI MAPA (se dibuja desde el Draw GUI de oBrain, en linea y en local)
// - ESQUINA: el mapa en su forma real. PC: abajo a la izquierda. Celular: arriba, junto al marcador.
// - TIRA: franja ancha abajo al centro.   - BARRA: solo una linea de base a base.
// Se ven todos los jugadores (aliados y enemigos), las bases y las banderas.
// ======================================================
function minimapa_draw() {
    opt_init();
    var _modo = global.opt.minimapa;
    if (_modo == 3 || room == rm_menu) exit;

    var _gw = display_get_gui_width(), _gh = display_get_gui_height();
    var _u  = clamp(_gh / 720, 0.7, 1.5);
    var _RW = max(1, room_width), _RH = max(1, room_height);
    var _tinta = make_color_rgb(11, 15, 26);
    var _azul  = make_color_rgb(31, 155, 255);
    var _rojo  = make_color_rgb(255, 42, 58);
    var _gris  = make_color_rgb(169, 180, 208);
    var _blink = ((current_time div 250) mod 2) == 0;

    // Mi equipo (en linea y en local)
    var _mi_team = variable_global_exists("myTeam") ? global.myTeam : "AZUL";
    var _rival   = (_mi_team == "AZUL") ? "ROJO" : "AZUL";

    // Camara
    var _cam = view_camera[0];
    var _cvx = camera_get_view_x(_cam), _cvy = camera_get_view_y(_cam);
    var _cvw = camera_get_view_width(_cam), _cvh = camera_get_view_height(_cam);

    // ---------- Tamano y lugar ----------
    var _mw, _mh, _mx, _my;
    if (_modo == 0) {
        _mw = 230 * _u; _mh = _mw * _RH / _RW;
        if (_mh > 110 * _u) { _mh = 110 * _u; _mw = _mh * _RW / _RH; }
        if (!touch_mode()) {
            _mx = 20 * _u; _my = _gh - _mh - 20 * _u;          // PC: abajo a la izquierda (esta libre)
        } else {
            _mx = _gw / 2 + 250 * _u; _my = 16 * _u;           // celular: a la derecha del marcador
            if (_mx + _mw > _gw - 350 * _u) { _mx = _gw / 2 - _mw / 2; _my = 185 * _u; } // pantalla angosta: debajo del reloj
        }
    } else if (_modo == 1) {
        _mw = 460 * _u; _mh = 60 * _u;
        _mx = _gw / 2 - _mw / 2; _my = _gh - _mh - (global.ONLINE ? 64 : 22) * _u;
    } else {
        _mw = 500 * _u; _mh = 6 * _u;
        _mx = _gw / 2 - _mw / 2; _my = _gh - (global.ONLINE ? 76 : 40) * _u;
    }
    var _kx = _mw / _RW, _ky = _mh / _RH;

    // ---------- Fondo ----------
    var _pad = (_modo == 2) ? 18 * _u : 6 * _u;
    var _padv = (_modo == 2) ? 16 * _u : 6 * _u;
    draw_set_alpha(0.72);
    draw_set_colour(_tinta);
    draw_rectangle(_mx - _pad, _my - _padv, _mx + _mw + _pad, _my + _mh + _padv, false);
    draw_set_alpha(0.25);
    draw_set_colour(_gris);
    draw_rectangle(_mx - _pad, _my - _padv, _mx + _mw + _pad, _my + _mh + _padv, true);
    draw_set_alpha(1);
    draw_set_colour(_azul);
    draw_rectangle(_mx - _pad, _my - _padv, _mx - _pad + 40 * _u, _my - _padv + 1, false);

    // ---------- El nivel (se guarda en una superficie para no redibujarlo cada frame) ----------
    if (_modo != 2) {
        var _sw = max(1, ceil(_mw)), _sh = max(1, ceil(_mh));
        if (!variable_global_exists("mm_surf")) { global.mm_surf = -1; global.mm_key = ""; }
        var _key = string(room) + "_" + string(_sw) + "_" + string(_sh);
        if (!surface_exists(global.mm_surf) || global.mm_key != _key) {
            if (surface_exists(global.mm_surf)) surface_free(global.mm_surf);
            global.mm_surf = surface_create(_sw, _sh);
            global.mm_key = _key;
            surface_set_target(global.mm_surf);
            draw_clear_alpha(c_black, 0);
            draw_set_colour(_gris);
            draw_set_alpha(0.35);
            with (obj_wall) {
                var _x1 = max(0, bbox_left) * _kx, _x2 = min(_RW, bbox_right) * _kx;
                var _y1 = max(0, bbox_top) * _ky,  _y2 = min(_RH, bbox_bottom) * _ky;
                if (_x2 > _x1 && _y2 > _y1) draw_rectangle(_x1, _y1, max(_x1 + 1, _x2), max(_y1 + 1, _y2), false);
            }
            draw_set_alpha(0.65);
            with (oPlataformaPasable) {
                draw_rectangle(bbox_left * _kx, bbox_top * _ky, max(bbox_left * _kx + 2, bbox_right * _kx), bbox_top * _ky + 1, false);
            }
            draw_set_alpha(1);
            surface_reset_target();
        }
        draw_surface(global.mm_surf, _mx, _my);
    } else {
        // BARRA: linea de color de base a base
        draw_set_alpha(0.5);
        draw_rectangle_colour(_mx, _my + _mh / 2 - 1, _mx + _mw, _my + _mh / 2 + 1, _azul, _rojo, _rojo, _azul, false);
        draw_set_alpha(1);
    }

    // Convierte una posicion del mundo al mini mapa
    var _py = function(_wy, _my, _ky, _mh, _modo) { return (_modo == 2) ? _my + _mh / 2 : _my + clamp(_wy * _ky, 0, _mh); };

    // ---------- Bases ----------
    var _bs = 4 * _u;
    with (obj_base_blue) { draw_set_colour(_azul); var _bx = _mx + clamp(x * _kx, 0, _mw), _by = _py(y, _my, _ky, _mh, _modo); draw_rectangle(_bx - _bs, _by - _bs, _bx + _bs, _by + _bs, false); }
    with (obj_base_red)  { draw_set_colour(_rojo); var _bx = _mx + clamp(x * _kx, 0, _mw), _by = _py(y, _my, _ky, _mh, _modo); draw_rectangle(_bx - _bs, _by - _bs, _bx + _bs, _by + _bs, false); }

    // ---------- Lo que ve la camara ----------
    draw_set_colour(c_white);
    draw_set_alpha(0.55);
    if (_modo == 2) draw_rectangle(_mx + _cvx * _kx, _my - 8 * _u, _mx + (_cvx + _cvw) * _kx, _my + _mh + 8 * _u, true);
    else draw_rectangle(_mx + max(0, _cvx) * _kx, _my + max(0, _cvy) * _ky, _mx + min(_RW, _cvx + _cvw) * _kx, _my + min(_RH, _cvy + _cvh) * _ky, true);
    draw_set_alpha(1);

    // ---------- Banderas (parpadean si alguien la lleva) ----------
    var _fsc = (12 * _u) / 17;
    with (oFlag)  { if (!has_flag || _blink) draw_sprite_ext(spr_flag_red,  0, _mx + clamp(x * _kx, 0, _mw), (_modo == 2) ? _my - 9 * _u : _py(y, _my, _ky, _mh, _modo) - 6 * _u, _fsc, _fsc, 0, c_white, 1); }
    with (oFlag2) { if (!has_flag || _blink) draw_sprite_ext(spr_flag_blue, 0, _mx + clamp(x * _kx, 0, _mw), (_modo == 2) ? _my - 9 * _u : _py(y, _my, _ky, _mh, _modo) - 6 * _u, _fsc, _fsc, 0, c_white, 1); }

    // ---------- Jugadores (todos: aliados y enemigos) ----------
    var _r = 3 * _u;
    var _dibujar = function(_wx, _wy, _col, _yo, _mx, _my, _kx, _ky, _mw, _mh, _modo, _r, _py) {
        var _px = _mx + clamp(_wx * _kx, 0, _mw);
        var _pyy = _py(_wy, _my, _ky, _mh, _modo);
        if (_yo) { draw_set_colour(c_white); draw_circle(_px, _pyy, _r + 1.5, false); }
        draw_set_colour(_col);
        draw_circle(_px, _pyy, _r, false);
    };
    // Otros jugadores en linea
    with (oOtherPlayer) {
        if (!visible || state == PLAYERSTATE.DEAD) continue;
        var _t = variable_instance_exists(id, "team") ? string(team) : _rival;
        _dibujar(x, (bbox_top + bbox_bottom) / 2, (_t == "AZUL") ? _azul : _rojo, false, _mx, _my, _kx, _ky, _mw, _mh, _modo, _r, _py);
    }
    // Rival en local (bot / jugador 2)
    with (oPlayer2_local) {
        if (!visible) continue;
        var _t2 = variable_instance_exists(id, "team") ? string(team) : _rival;
        _dibujar(x, (bbox_top + bbox_bottom) / 2, (_t2 == "AZUL") ? _azul : _rojo, false, _mx, _my, _kx, _ky, _mw, _mh, _modo, _r, _py);
    }
    // Yo (al final, para quedar encima)
    var _mcol = (_mi_team == "AZUL") ? _azul : _rojo;
    with (oPlayer)         { if (visible) _dibujar(x, (bbox_top + bbox_bottom) / 2, _mcol, true, _mx, _my, _kx, _ky, _mw, _mh, _modo, _r, _py); }
    with (oPlayer_offline) { if (visible) _dibujar(x, (bbox_top + bbox_bottom) / 2, _mcol, true, _mx, _my, _kx, _ky, _mw, _mh, _modo, _r, _py); }

    draw_set_colour(c_white);
    draw_set_alpha(1);
}


// ======================================================
// VOLUMEN DE MUSICA Y EFECTOS
// Lo que se oye = volumen general x (musica o efectos) x el volumen que tiene el sonido en GameMaker.
// La musica es todo sonido que empiece con "mus_". Lo demas son efectos.
// ======================================================
function scr_audio_base() {
    if (variable_global_exists("audio_ids")) return;
    scr_musica_lista();   // que las canciones queden dentro del juego
    global.audio_ids  = asset_get_ids(asset_sound);
    global.audio_base = [];   // el volumen que le pusiste a cada sonido en GameMaker
    global.audio_mus  = [];   // true si es musica
    for (var i = 0; i < array_length(global.audio_ids); i++) {
        var _id = global.audio_ids[i];
        array_push(global.audio_base, audio_sound_get_gain(_id));
        array_push(global.audio_mus, string_copy(audio_get_name(_id), 1, 4) == "mus_");
    }
}

function scr_audio_volumenes() {
    scr_audio_base();
    var _mu = global.opt.vol_musica / 100;
    var _sf = global.opt.vol_sfx / 100;
    for (var i = 0; i < array_length(global.audio_ids); i++) {
        audio_sound_gain(global.audio_ids[i], global.audio_base[i] * (global.audio_mus[i] ? _mu : _sf), 0);
    }
}

// ======================================================
// MUSICA: cual suena en cada momento (va en el Step de oBrain)
//   Menu y salas ........ mus_menu (loop)
//   Partida ............. mus_nivel1 / mus_nivel2 / mus_nivel3 (loop; si falta, usa mus_nivel1)
//   Ultimos 30 s / muerte subita ... mus_tension (loop; si falta, sigue la del nivel)
//   Fin de partida ...... mus_victoria o mus_derrota (una vez)
// Entre una y otra se apaga suave. En pausa baja a la mitad. Si falta un archivo, silencio.
// ======================================================
#macro MUS_FADE 1000   // milisegundos para pasar de una cancion a otra

// Las canciones se nombran aqui DIRECTO: si solo se buscan por texto, GameMaker cree que
// no se usan y las quita del juego al compilar (por eso no sonaba nada).
// Si agregas otra cancion, ponla tambien en esta lista.
function scr_musica_lista() {
    if (!variable_global_exists("mus_lista")) {
        global.mus_lista = {
            mus_menu:     mus_menu,
            mus_nivel1:   mus_nivel1,
            mus_nivel2:   mus_nivel2,
            mus_nivel3:   mus_nivel3,
            mus_tension:  mus_tension,
            mus_victoria: mus_victoria,
            mus_derrota:  mus_derrota
        };
    }
    return global.mus_lista;
}

function scr_musica_existe(_n) {
    return (_n != "" && variable_struct_exists(scr_musica_lista(), _n));
}

/// Devuelve [nombre, se_repite]
function scr_musica_elegir() {
    if (room == rm_menu) return ["mus_menu", true];

    if (global.game_over) {
        var _gana = (global.winner_team == 1) ? "ROJO" : "AZUL";
        return [(scr_my_team() == _gana) ? "mus_victoria" : "mus_derrota", false];
    }

    if (instance_exists(oBrain)) {
        var _tension = oBrain.reloj_fin || (oBrain.reloj_seg >= 0 && oBrain.reloj_seg <= 30);
        if (_tension && scr_musica_existe("mus_tension")) return ["mus_tension", true];
    }

    var _rn = room_get_name(room);
    var _p = string_pos("stage", _rn);
    var _nivel = (_p > 0) ? string_char_at(_rn, _p + 5) : "1";
    var _nom = "mus_nivel" + _nivel;
    if (!scr_musica_existe(_nom)) _nom = "mus_nivel1";
    return [_nom, true];
}

function scr_musica_step() {
    opt_init();
    if (!variable_global_exists("mus")) global.mus = { nombre: "", inst: -1, g: 1, viejas: [], reintento: 0, paso: -1 };
    var _m = global.mus;
    if (_m.paso == current_time) return;    // ya corrio este frame (lo llaman oBrain y oMenu)
    _m.paso = current_time;
    if (!audio_system_is_available()) return;   // en el navegador el audio arranca hasta que tocas algo

    var _e = scr_musica_elegir();
    var _n = scr_musica_existe(_e[0]) ? _e[0] : "";
    var _g = (variable_global_exists("pausa") && global.pausa) ? 0.5 : 1;

    if (_n != _m.nombre) {
        // la que sonaba se apaga suave
        if (_m.inst != -1 && audio_is_playing(_m.inst)) {
            audio_sound_gain(_m.inst, 0, MUS_FADE);
            array_push(_m.viejas, { i: _m.inst, t: current_time + MUS_FADE + 50 });
        }
        _m.inst = -1;
        _m.nombre = _n;
        _m.g = _g;
        if (_n != "") {
            _m.inst = audio_play_sound(variable_struct_get(scr_musica_lista(), _n), 50, _e[1], 0);
            audio_sound_gain(_m.inst, _g, _e[1] ? MUS_FADE : 0);   // las de ganar/perder entran de golpe
            show_debug_message(">>> MUSICA: " + _n + "  (volumen musica " + string(global.opt.vol_musica) + "%)");
        }
    }
    // Si la que se repite se corto (algo la paro o no pudo arrancar), la vuelve a poner
    else if (_n != "" && _e[1] && (_m.inst == -1 || !audio_is_playing(_m.inst))) {
        _m.reintento -= 1;
        if (_m.reintento <= 0) {
            _m.reintento = 30;
            _m.inst = audio_play_sound(variable_struct_get(scr_musica_lista(), _n), 50, true, 0);
            audio_sound_gain(_m.inst, _g, MUS_FADE);
            _m.g = _g;
            show_debug_message(">>> MUSICA (otra vez): " + _n);
        }
    }
    else if (_m.inst != -1 && _m.g != _g) {
        audio_sound_gain(_m.inst, _g, 300);
        _m.g = _g;
    }

    for (var i = array_length(_m.viejas) - 1; i >= 0; i--) {
        if (current_time >= _m.viejas[i].t) {
            audio_stop_sound(_m.viejas[i].i);
            array_delete(_m.viejas, i, 1);
        }
    }
}


// ======================================================
// PUNTO GANADOR (como el gol que gana en Brawl Stars)
// Al acabarse la partida: flash, la camara se acerca a la base del que gano,
// sale CAPTURA! (o TIEMPO! si fue por reloj) con confeti, y despues los resultados.
// Cada pantalla lo hace sola cuando ve que se acabo la partida (no manda nada por red).
// ======================================================
#macro FEST_FRAMES 150    // cuanto dura el CAPTURA! con confeti (150 = 2.5 segundos)
#macro FEST_PAUSA  60     // pausa despues, antes de los resultados (60 = 1 segundo)
#macro FEST_ZOOM   1.5    // que tanto se acerca la camara

/// Va en el Step de oBrain
function scr_fin_festejo_step() {
    if (!variable_global_exists("fest")) global.fest = { t: -1, x: 0, y: 0, conf: [], txt: "", gana: "", col: c_white };
    var _f = global.fest;
    if (!global.game_over || room == rm_menu) { _f.t = -1; return; }
    if (_f.t == -1) {
        // Si se acabo porque el otro se salio, no hay festejo
        if (instance_exists(oBrain) && oBrain.abandono_activo) { _f.t = 0; return; }
        _f.t = FEST_FRAMES + FEST_PAUSA;
        var _azul = (global.winner_team != 1);   // 1 = ROJO, 2 = AZUL
        var _b = instance_find(_azul ? obj_base_blue : obj_base_red, 0);
        if (_b != noone) { _f.x = _b.x; _f.y = _b.y; }
        else { _f.x = room_width / 2; _f.y = room_height / 2; }
        _f.col  = _azul ? make_color_rgb(61, 157, 240) : make_color_rgb(229, 72, 77);
        _f.gana = _azul ? "GANA AZUL" : "GANA ROJO";
        _f.txt  = (instance_exists(oBrain) && oBrain.reloj_fin) ? "TIEMPO!" : "CAPTURA!";
        _f.conf = [];
        var _oro = make_color_rgb(242, 182, 50);
        repeat (70) {
            array_push(_f.conf, { x: random(1), y: -random(0.6), v: random_range(0.004, 0.010),
                c: choose(_f.col, _f.col, _oro, c_white), r: random(360), w: random_range(-9, 9), s: random_range(0.7, 1.3) });
        }
        scrCamShake(5);
    }
    if (_f.t > 0) _f.t -= 1;
}

function scr_fin_festejo_activo() {
    return variable_global_exists("fest") && global.fest.t > 0;
}

/// Va al inicio del Step de la camara. Devuelve true si este frame la mueve el festejo.
function scr_fin_festejo_camara(_cam) {
    if (!variable_instance_exists(id, "fest_w")) { fest_w = -1; fest_h = -1; fest_z = 1; }
    var _activo = variable_global_exists("fest") && global.game_over && global.fest.t != -1
                  && !(instance_exists(oBrain) && oBrain.abandono_activo);
    if (_activo) {
        var _f = global.fest;
        if (fest_w < 0) { fest_w = camera_get_view_width(_cam); fest_h = camera_get_view_height(_cam); fest_z = 1; }
        fest_z = lerp(fest_z, FEST_ZOOM, 0.06);
        var _w = fest_w / fest_z, _h = fest_h / fest_z;
        var _cx = camera_get_view_x(_cam) + camera_get_view_width(_cam) / 2;
        var _cy = camera_get_view_y(_cam) + camera_get_view_height(_cam) / 2;
        _cx = lerp(_cx, _f.x, 0.08);
        _cy = lerp(_cy, _f.y - 30, 0.08);
        var _x = clamp(_cx - _w / 2, 0, max(0, room_width - _w));
        var _y = clamp(_cy - _h / 2, 0, max(0, room_height - _h));
        camera_set_view_size(_cam, _w, _h);
        camera_set_view_pos(_cam, _x, _y);
        scr_fondo_parallax(_cam);
        return true;
    }
    // Ya no hay festejo: la camara vuelve a su tamano
    if (fest_w > 0) {
        camera_set_view_size(_cam, fest_w, fest_h);
        fest_w = -1;
    }
    return false;
}

/// Va al final del Draw GUI de oBrain
function scr_fin_festejo_draw() {
    if (!variable_global_exists("fest")) return;
    var _f = global.fest;
    if (!global.game_over || _f.t <= 0) return;
    var _e = FEST_FRAMES + FEST_PAUSA - _f.t;    // frames que lleva
    if (_e >= FEST_FRAMES) return;               // ya esta en la pausa: no se dibuja nada
    var _gw = display_get_gui_width(), _gh = display_get_gui_height();
    var _queda = FEST_FRAMES - _e;
    var _fin = (_queda < 20) ? _queda / 20 : 1;  // se desvanece al final

    // Flash blanco al anotar
    if (_e < 10) {
        draw_set_alpha(0.7 * (1 - _e / 10));
        draw_set_colour(c_white);
        draw_rectangle(0, 0, _gw, _gh, false);
    }

    // Confeti
    var _u = _gh / 720;
    for (var i = 0; i < array_length(_f.conf); i++) {
        var _c = _f.conf[i];
        _c.y += _c.v;
        _c.r += _c.w;
        if (_c.y < 0) continue;
        var _px = _c.x * _gw + sin(_c.r * 0.05) * 10 * _u;
        var _py = _c.y * _gh;
        var _lw = 7 * _u * _c.s, _lh = 4 * _u * _c.s;
        var _dx = lengthdir_x(_lw, _c.r), _dy = lengthdir_y(_lw, _c.r);
        var _ex = lengthdir_x(_lh, _c.r + 90), _ey = lengthdir_y(_lh, _c.r + 90);
        draw_set_alpha(_fin);
        draw_set_colour(_c.c);
        draw_triangle(_px - _dx - _ex, _py - _dy - _ey, _px + _dx - _ex, _py + _dy - _ey, _px + _dx + _ex, _py + _dy + _ey, false);
        draw_triangle(_px - _dx - _ex, _py - _dy - _ey, _px + _dx + _ex, _py + _dy + _ey, _px - _dx + _ex, _py - _dy + _ey, false);
    }

    // CAPTURA! (entra creciendo y late un poquito)
    draw_set_font(fnt_menu);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    if (_e > 12) {
        var _k = min(1, (_e - 12) / 15);
        var _pop = 1 + sin(_k * pi) * 0.25;                  // se pasa un poco y regresa
        var _base = (_gh * 0.15) / max(1, string_height(_f.txt));
        var _sc = _base * (0.4 + 0.6 * _k) * _pop * (1 + sin(_e * 0.13) * 0.03);
        var _ty = _gh * 0.38;
        draw_set_alpha(_fin);
        draw_set_colour(c_black);
        for (var _o = 0; _o < 8; _o++) {
            var _ox = lengthdir_x(4 * _u, _o * 45), _oy = lengthdir_y(4 * _u, _o * 45);
            draw_text_transformed(_gw / 2 + _ox, _ty + _oy, _f.txt, _sc, _sc, 0);
        }
        draw_set_colour(_f.col);
        draw_text_transformed(_gw / 2, _ty, _f.txt, _sc, _sc, 0);

        // GANA AZUL / GANA ROJO
        if (_e > 35) {
            var _s2 = (_gh * 0.05) / max(1, string_height(_f.gana));
            var _ty2 = _ty + _gh * 0.12;
            draw_set_colour(c_black);
            for (var _o = 0; _o < 8; _o++) {
                draw_text_transformed(_gw / 2 + lengthdir_x(2 * _u, _o * 45), _ty2 + lengthdir_y(2 * _u, _o * 45), _f.gana, _s2, _s2, 0);
            }
            draw_set_colour(make_color_rgb(242, 182, 50));
            draw_text_transformed(_gw / 2, _ty2, _f.gana, _s2, _s2, 0);
        }
    }
    draw_set_alpha(1);
    draw_set_colour(c_white);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}

// ======================================================
// PANTALLA DE RESPAWN (tipo Brawl Stars)
// "ELIMINADO POR <nombre>" + circulo con cuenta regresiva + "A JUGAR!" al volver.
// Solo dibujo: usa alarm[1] (el timer de respawn que ya existe) y last_killer.
// Se llama en el Draw GUI de oPlayer y oPlayer_offline.
// ======================================================
function scr_respawn_draw(_muerto) {
    if (!variable_instance_exists(id, "resp_fx")) resp_fx = { estaba: false, t: 0, max_al: 120 };
    if (variable_global_exists("game_over") && global.game_over) { resp_fx.estaba = false; resp_fx.t = 0; return; }
    var _gw = display_get_gui_width(), _gh = display_get_gui_height();
    var _u = _gh / 720;

    draw_set_font(fnt_menu);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);

    if (_muerto) {
        if (!resp_fx.estaba) { resp_fx.estaba = true; resp_fx.t = 0; resp_fx.max_al = max(1, alarm[1]); }
        resp_fx.t++;
        var _al = max(0, alarm[1]);
        var _tot = max(1, resp_fx.max_al);
        var _fade = min(1, resp_fx.t / 15);

        // Oscurece la pantalla
        draw_set_alpha(0.65 * _fade);
        draw_set_colour(make_color_rgb(10, 12, 20));
        draw_rectangle(0, 0, _gw, _gh, false);

        var _cx = _gw / 2, _cy = _gh * 0.52;
        var _base = (_gh * 0.045) / max(1, string_height("A"));

        // ELIMINADO POR
        var _quien = (variable_instance_exists(id, "last_killer") && last_killer != "") ? string(last_killer) : "";
        draw_set_alpha(_fade);
        draw_set_colour(make_color_rgb(255, 107, 107));
        draw_text_transformed(_cx, _gh * 0.24, (_quien != "") ? "ELIMINADO POR" : "ELIMINADO", _base, _base, 0);
        if (_quien != "") {
            draw_set_colour(c_white);
            draw_text_transformed(_cx, _gh * 0.32, _quien, _base * 1.6, _base * 1.6, 0);
        }

        // Circulo de cuenta regresiva
        var _r = 70 * _u;
        var _grosor = 10 * _u;
        draw_set_alpha(0.18 * _fade);
        draw_set_colour(c_white);
        scr_resp_arco(_cx, _cy, _r, _grosor, 1);
        draw_set_alpha(_fade);
        draw_set_colour(make_color_rgb(255, 210, 63));
        scr_resp_arco(_cx, _cy, _r, _grosor, _al / _tot);

        // Numero (salta un poquito cada segundo)
        var _seg = max(1, ceil(_al / 60));
        var _frac = (_al mod 60) / 60;
        var _pop = 1 + max(0, _frac - 0.8) * 1.2;
        draw_set_colour(c_white);
        draw_text_transformed(_cx, _cy, string(_seg), _base * 2.6 * _pop, _base * 2.6 * _pop, 0);

        // REAPARECES EN
        draw_set_colour(make_color_rgb(207, 214, 230));
        draw_text_transformed(_cx, _cy + _r + 40 * _u, "REAPARECES EN", _base * 0.8, _base * 0.8, 0);
    }
    else {
        if (resp_fx.estaba) { resp_fx.estaba = false; resp_fx.t = 45; }   // acaba de revivir
        if (resp_fx.t > 0) {
            resp_fx.t--;
            var _a = resp_fx.t / 45;
            var _s = (_gh * 0.07) / max(1, string_height("A")) * (1 + (1 - _a) * 0.3);
            draw_set_alpha(_a);
            draw_set_colour(c_black);
            for (var _o = 0; _o < 8; _o++) draw_text_transformed(_gw / 2 + lengthdir_x(3 * _u, _o * 45), _gh * 0.3 + lengthdir_y(3 * _u, _o * 45), "A JUGAR!", _s, _s, 0);
            draw_set_colour(make_color_rgb(255, 210, 63));
            draw_text_transformed(_gw / 2, _gh * 0.3, "A JUGAR!", _s, _s, 0);
        }
    }
    draw_set_alpha(1);
    draw_set_colour(c_white);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}

// Arco grueso que empieza arriba y va en sentido del reloj (_p de 0 a 1)
function scr_resp_arco(_cx, _cy, _r, _g, _p) {
    if (_p <= 0) return;
    var _n = max(2, ceil(48 * _p));
    var _ri = _r - _g / 2, _ro = _r + _g / 2;
    draw_primitive_begin(pr_trianglestrip);
    for (var i = 0; i <= _n; i++) {
        var _ang = 90 - 360 * _p * (i / _n);
        draw_vertex(_cx + lengthdir_x(_ro, _ang), _cy + lengthdir_y(_ro, _ang));
        draw_vertex(_cx + lengthdir_x(_ri, _ang), _cy + lengthdir_y(_ri, _ang));
    }
    draw_primitive_end();
}

// ======================================================
// EFECTO "LLEVAS LA BANDERA" (opcion A)
// Bordes suaves del color de tu equipo que respiran + cartel arriba + brillo en los pies.
// scr_bandera_gui_draw() va en el Draw GUI; scr_bandera_aura_draw() en el Draw (antes del personaje).
// ======================================================
function scr_bandera_color() {
    return (scr_my_team() == "AZUL") ? make_color_rgb(70, 140, 255) : make_color_rgb(255, 70, 70);
}

function scr_bandera_gui_draw() {
    var _gw = display_get_gui_width(), _gh = display_get_gui_height();
    var _u = _gh / 720;
    var _col = scr_bandera_color();
    var _p = 0.5 + 0.5 * sin(current_time / 1000 * 3);
    var _a = 0.35 + _p * 0.15;

    // Bordes que se desvanecen hacia adentro (sin cuadros duros)
    var _d = 140 * _u;
    draw_primitive_begin(pr_trianglestrip);   // arriba
    draw_vertex_colour(0, 0, _col, _a); draw_vertex_colour(_gw, 0, _col, _a);
    draw_vertex_colour(0, _d, _col, 0); draw_vertex_colour(_gw, _d, _col, 0);
    draw_primitive_end();
    draw_primitive_begin(pr_trianglestrip);   // abajo
    draw_vertex_colour(0, _gh, _col, _a); draw_vertex_colour(_gw, _gh, _col, _a);
    draw_vertex_colour(0, _gh - _d, _col, 0); draw_vertex_colour(_gw, _gh - _d, _col, 0);
    draw_primitive_end();
    draw_primitive_begin(pr_trianglestrip);   // izquierda
    draw_vertex_colour(0, 0, _col, _a); draw_vertex_colour(0, _gh, _col, _a);
    draw_vertex_colour(_d, 0, _col, 0); draw_vertex_colour(_d, _gh, _col, 0);
    draw_primitive_end();
    draw_primitive_begin(pr_trianglestrip);   // derecha
    draw_vertex_colour(_gw, 0, _col, _a); draw_vertex_colour(_gw, _gh, _col, _a);
    draw_vertex_colour(_gw - _d, 0, _col, 0); draw_vertex_colour(_gw - _d, _gh, _col, 0);
    draw_primitive_end();

    // Cartel "LLEVAS LA BANDERA"
    draw_set_font(fnt_menu);
    var _txt = "LLEVAS LA BANDERA";
    var _s = (_gh * 0.032) / max(1, string_height(_txt));
    var _tw = string_width(_txt) * _s;
    var _bh = 46 * _u, _bw = _tw + 80 * _u;
    var _bx = _gw / 2 - _bw / 2, _by = 14 * _u;
    draw_set_alpha(0.8);
    draw_set_colour(make_color_rgb(15, 25, 50));
    draw_rectangle(_bx, _by, _bx + _bw, _by + _bh, false);
    draw_set_alpha(1);
    draw_set_colour(_col);
    draw_rectangle(_bx, _by + _bh - 4 * _u, _bx + _bw, _by + _bh, false);

    // Banderita dibujada
    var _fx = _bx + 18 * _u, _fy = _by + 9 * _u;
    draw_set_colour(c_white);
    draw_rectangle(_fx, _fy, _fx + 3 * _u, _fy + 28 * _u, false);
    draw_set_colour(make_color_rgb(255, 75, 75));
    draw_triangle(_fx + 3 * _u, _fy, _fx + 22 * _u, _fy + 7 * _u, _fx + 3 * _u, _fy + 14 * _u, false);

    draw_set_halign(fa_left);
    draw_set_valign(fa_middle);
    draw_set_colour(c_white);
    draw_text_transformed(_fx + 34 * _u, _by + _bh / 2 - 2 * _u, _txt, _s, _s, 0);
    draw_set_valign(fa_top);
}

function scr_bandera_aura_draw() {
    if (!has_flag) return;
    var _p = 0.5 + 0.5 * sin(current_time / 1000 * 3);
    var _col = scr_bandera_color();
    var _r = 22 + _p * 4;
    gpu_set_blendmode(bm_add);
    draw_set_colour(_col);
    draw_set_alpha(0.25 + _p * 0.15);
    draw_ellipse(x - _r, bbox_bottom - _r * 0.28, x + _r, bbox_bottom + _r * 0.28, false);
    draw_set_alpha(1);
    gpu_set_blendmode(bm_normal);
    draw_set_colour(c_white);
}
