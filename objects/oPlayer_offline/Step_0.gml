// CONGELAR ACCIONES AL FINAL
if (global.game_over) { hsp = 0; vsp = 0; exit; }

// ======================================================
// 💬 LÓGICA DE EMOTES (Local)
// ======================================================
if (emote_cd > 0) emote_cd--;
var _emote_to_send = -1;

if (emote_cd <= 0) {
    if (keyboard_check_pressed(ord("1"))) _emote_to_send = 0;
    if (keyboard_check_pressed(ord("2"))) _emote_to_send = 1;
    if (keyboard_check_pressed(ord("3"))) _emote_to_send = 2;
    if (keyboard_check_pressed(ord("4"))) _emote_to_send = 3;

    if (_emote_to_send != -1) {
        var _e = instance_create_layer(x, y - 75, "Instances", oEmote);
        _e.image_index = _emote_to_send;
        _e.owner = id;
        emote_cd = 120; 
    }
}

// --- TIMERS DE POWERUPS ---
if (shield_timer > 0) {
    shield_timer--;
    if (shield_timer < 120) shield_alpha_hud = abs(sin(current_time / 100)); 
    if (shield_timer <= 0) { has_shield = false; if (global.sfx) audio_play_sound(snd_powerdown, 5, false); }
}
if (damage_timer > 0) { damage_timer--; if (damage_timer <= 0) damage_boost = 1; }
if (ammo_timer > 0) { ammo_timer--; if (ammo_timer <= 0) infinite_ammo = false; }

// --- SUELO ---
is_grounded = place_meeting(x, y + 1, obj_wall) || place_meeting(x, y + 1, oPlataformaPasable);

// 1. Entradas
key_left  = keyboard_check(ord("A"));
key_right = keyboard_check(ord("D"));
key_jump  = keyboard_check_pressed(ord("W"));
key_melee = mouse_check_button_pressed(mb_right);

if (melee_cd > 0) melee_cd--;
if (melee_active > 0) melee_active--;
if (crush_cd > 0) crush_cd--;

// --- VELOCIDAD ---
if (speed_timer > 0) {
    if (!alarm[0] && global.EffectTrial) alarm[0] = TimeAlarmEffectTrail;
    speed_timer--;
    walksp_mult = 1.5;
} else {
    walksp_mult = 1.0;
}
walksp = walksp_base * walksp_mult;

// --- RECOIL Y RECARGA ---
if (!mouse_check_button(mb_left)) ak_recoil = max(0, ak_recoil - 0.6);
recoil_kick *= 0.75; recoil_angle *= 0.75; recoil_x *= 0.7; recoil_y *= 0.7;

if (reloading) {
    reload_timer--;
    if (reload_timer <= 0) {
        var w = guns[weapon.index];
        if (w != noone && is_struct(w)) {
            var t = w.ammoType;
            var res = reserve[$ t];
            if (res != undefined) {
                var need = w.maxAmmo - w.ammo;
                var take = min(need, res);
                w.ammo += take;
                reserve[$ t] -= take;
                reloading = false;
            }
        }
    }
}

var canShoot = (!has_flag) && (state != PLAYERSTATE2.DEAD);

// --- DAÑO MELEE LOCAL ---
if (melee_active > 0) {
    var range = 26;
    var hx = x + (range * sign(image_xscale));
    var hy = y - 10;
    // En local, solo dañaríamos si creas un oBot o oEnemy
    var target = instance_place(hx, hy, oPlayer2_local); 
    if (target != noone) {
        target.hp -= melee_damage;
        melee_active = 0;
    }
}

// --- ATAQUE SECUNDARIO (GRANADAS / MELEE) ---
if (mouse_check_button_pressed(mb_right)) {
    if (granadas > 0) {
        granadas -= 1;
        melee_cd = room_speed div 3;
        var dir = point_direction(x, y - 16, mouse_x, mouse_y);
        var fuerza = 8;
        var nade = instance_create_layer(x + lengthdir_x(15, dir), y - 16 + lengthdir_y(15, dir), "Instances", oMyEntity);
        nade.owner_name = global.myName;
        nade.sprite_index = spr_granada;
        nade.damage = 40;
        nade.owner_team = global.myTeam;
        nade.is_granada = true;
        nade.hsp = lengthdir_x(fuerza, dir);
        nade.vsp = lengthdir_y(fuerza, dir) - 2;
    } else if (melee_cd <= 0 && state != PLAYERSTATE2.DEAD) {
        melee_cd = room_speed div 3;
        melee_active = 6;
        if (global.sfx) audio_play_sound(snd_melee, 1, false);
    }
}

if (state != PLAYERSTATE2.DEAD) vsp += grv;

// --- MÁQUINA DE ESTADOS ---
switch (state) {
    case PLAYERSTATE2.IDLE:
        if (canShoot && melee_active <= 0) scrPlayerWeaponUpdate_offline();
        sprite_index = spr_player_idle;
        if (key_jump && is_grounded) { vsp = jumpsp; state = PLAYERSTATE2.JUMP; }
        if (key_right || key_left) state = PLAYERSTATE2.WALK;
    break;

    case PLAYERSTATE2.WALK:
        if (canShoot && melee_active <= 0) scrPlayerWeaponUpdate_offline();
        move = key_right - key_left;
        var _current_speed = has_flag ? walksp * 0.7 : walksp;
        hsp = move * _current_speed;
        sprite_index = spr_player_walk;
        if (hsp != 0) image_xscale = sign(hsp) * 1.5;
        if (hsp == 0) state = PLAYERSTATE2.IDLE;
        if (key_jump && is_grounded) { vsp = jumpsp; state = PLAYERSTATE2.JUMP; }
    break;

    case PLAYERSTATE2.JUMP:
        if (canShoot && melee_active <= 0) scrPlayerWeaponUpdate_offline();
        move = key_right - key_left;
        hsp = move * walksp;
        if (hsp != 0) image_xscale = sign(hsp) * 1.5;
        if (is_grounded) state = PLAYERSTATE2.IDLE;
    break;

    case PLAYERSTATE2.DEAD:
        hsp = 0;
        sprite_index = spr_player_dead;
        if (image_index >= image_number - 1) visible = false;
    break;
}

// --- PLATAFORMAS ---
var plat = instance_place(x, y + 1, oMovingPlatform);
if (plat != noone && vsp >= 0) {
    y -= (bbox_bottom - plat.bbox_top);
    y += plat.dy;
}

//plataforma traspasable
if (vsp > 0)
{
    var plat = instance_place(x, y + vsp, oPlataformaPasable);
    if (plat != noone)
    {
        // evitar enganchar desde abajo
        if (bbox_bottom <= plat.bbox_top + vsp)
        {
            y = plat.bbox_top - (bbox_bottom - y);
            vsp = 0;
 

            if (state == PLAYERSTATE2.JUMP)
                state = PLAYERSTATE2.IDLE;
        }
		
    }
	
}

// --- COLISIONES ---
if (place_meeting(x + hsp, y, obj_wall)) {
    while (!place_meeting(x + sign(hsp), y, obj_wall)) x += sign(hsp);
    hsp = 0;
}
x += hsp;

if (place_meeting(x, y + vsp, obj_wall)) {
    while (!place_meeting(x, y + sign(vsp), obj_wall)) y += sign(vsp);
    vsp = 0;
}
y += vsp;

// --- MUERTE LOCAL ---
if (health <= 0 && !isDead) {
    isDead = true;
    state = PLAYERSTATE2.DEAD;
    invulnerable = true;
    alarm[1] = 120; // Respawn
    
    var killerName = (last_killer != "") ? last_killer : "Alguien";
    scrAddKillFeed(killerName + " te elimino");
}

// --- SOLTAR BANDERA AL MORIR (Local) ---
if (state == PLAYERSTATE2.DEAD && has_flag == true) {
    has_flag = false;
    var bandera_robada = (global.myTeam == "AZUL") ? oFlag : oFlag2;
    with (bandera_robada) {
        has_flag = false;
        portador_instancia = noone;
        x = other.x; y = other.y;
        velocidad_caida = -2;
        sprite_index = spr_suela;
    }
}

// --- CAPTURA LOCAL ---
var objetivo = (global.myTeam == "AZUL") ? oFlag : oFlag2;
if (!score_pending && place_meeting(x, y, objetivo) && state != PLAYERSTATE2.DEAD && !has_flag && !objetivo.has_flag) {
    has_flag = true;
    with(objetivo) { has_flag = true; portador_instancia = other.id; }
}

// --- ANOTACIÓN LOCAL ---
var miBase = (global.myTeam == "AZUL") ? obj_base_blue : obj_base_red;
if (place_meeting(x, y, miBase) && has_flag && !score_pending) {
    if (global.myTeam == "AZUL") global.puntos_azul++; else global.puntos_rojo++;
    has_flag = false;
    with (objetivo) { 
        x = spawnX; y = spawnY; 
        has_flag = false; portador_instancia = noone; 
    }
    var notif = instance_create_layer(0, 0, "Instances", oNotification);
    notif.text = "¡ANOTASTE!";
    notif.color = c_lime;
}

// --- DEVOLVER MI BANDERA (Local) ---
var miBandera = (global.myTeam == "AZUL") ? oFlag2 : oFlag;
if (!score_pending && place_meeting(x, y, miBandera) && !miBandera.has_flag && (miBandera.x != miBandera.spawnX)) {
    with(miBandera) { x = spawnX; y = spawnY; }
    var notif = instance_create_layer(0, 0, "Instances", oNotification);
    notif.text = "¡SALVASTE TU BANDERA!";
    notif.color = c_aqua;
}

// --- INVULNERABILIDAD ---
if (invul_timer > 0) {
    invul_timer--;
    invulnerable = true;
    image_alpha = 0.5;
} else if (!isDead) {
    invulnerable = false;
    image_alpha = 1;
}