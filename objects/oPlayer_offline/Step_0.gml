
// CONGELAR ACCIONES AL FINAL
if (global.game_over) { hsp = 0; vsp = 0; exit; }

// Esto debería estar en el Step de tu objeto enemigo/jugador
if (state == PLAYERSTATE2.HIT) {
    hsp = hsp * 0.9; // Fricción: pierde 10% de velocidad cada frame
}

// En el Step del Enemigo
if (state == PLAYERSTATE2.HIT) {
    if (hit_bloqueo_timer > 0) {
        hit_bloqueo_timer--;
    } else {
        state = PLAYERSTATE2.IDLE; // Aquí recupera el control
    }
}
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

	if(can_sfx=false)
	{
    // --- SOLO ESTO PARA EL EFECTO ---
    var _slash = instance_create_layer(hx, hy, "Instances", oMeleeFX);
    _slash.image_xscale = sign(image_xscale);
    _slash.depth = depth - 10; 
    // -------------------------------
	can_sfx=true;
	alarm[4]=10;
	}

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
        var nade = instance_create_layer(x + lengthdir_x(15, dir), y - 16 + lengthdir_y(15, dir), "Instances", oGranada);
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
	var move = key_right - key_left;
    var _speed_final = has_flag ? walksp * 0.7 : walksp;

    // SOLO camina si no está siendo empujado fuertemente
    if (abs(push_h) < 1) { 
        hsp = move * _speed_final;
    }
        sprite_index = spr_player_walk;
        if (hsp != 0) image_xscale = sign(hsp) * 1.5;
        if (hsp == 0) state = PLAYERSTATE2.IDLE;
        if (key_jump && is_grounded) { vsp = jumpsp; state = PLAYERSTATE2.JUMP; }
    break;

    case PLAYERSTATE2.JUMP:
        if (canShoot && melee_active <= 0) scrPlayerWeaponUpdate_offline();
	var move = key_right - key_left;
    if (abs(push_h) < 1) {
        hsp = move * walksp;
    }
        if (hsp != 0) image_xscale = sign(hsp) * 1.5;
        if (is_grounded) state = PLAYERSTATE2.IDLE;
    break;

    case PLAYERSTATE2.DEAD:
        hsp = 0;
        sprite_index = spr_player_dead;
        if (image_index >= image_number - 1) visible = false;
    break;
}


//ARPON
// ======================================================
// ⚓ SISTEMA DE ARPÓN MANUAL Y LINEAL
// ======================================================

// --- 1. ACTIVACIÓN (Disparo directo al Mouse) ---
if (mouse_check_button_pressed(mb_middle) && state != PLAYERSTATE2.GRAPPLE) {
    state = PLAYERSTATE2.GRAPPLE;
    grapple_hitting = false;
    grapple_is_returning = false;
    grapple_anim_dist = 0;
    grapple_type = "";
    grapple_target = noone;
    grapple_timer = 0;
    
    // Fijamos la dirección exacta hacia el mouse en este instante
    grapple_dir = point_direction(x, y - 20, mouse_x, mouse_y);
    
    // Sonido de lanzamiento
    if (global.sfx) audio_play_sound(snd_shoot, 10, false);
}

// --- 2. LÓGICA MIENTRAS EL ARPÓN ESTÁ ACTIVO ---
if (state == PLAYERSTATE2.GRAPPLE) {
    
    // --- FASE A: EL GANCHO VA VOLANDO O VOLVIENDO ---
    if (!grapple_hitting) {
        
        // Tú no te mueves mientras el gancho vuela
        //hsp = 0; 
        //vsp = 0;

        if (!grapple_is_returning) {
            // --- EXTENSIÓN (Hacia afuera) ---
            grapple_anim_dist += grapple_speed_ext;
            
            // Calculamos dónde está la punta del gancho AHORA
            var _tip_x = x + lengthdir_x(grapple_anim_dist, grapple_dir);
            var _tip_y = (y - 20) + lengthdir_y(grapple_anim_dist, grapple_dir);
            
            // --- DETECCION DE COLISIONES EN LA PUNTA ---
            
            // A. Chequear Enemigo (oPlayer2_local)
            var _enemigo = instance_position(_tip_x, _tip_y, oPlayer2_local);
            if (_enemigo != noone) {
                grapple_hitting = true;
                grapple_type = "ENEMIGO";
                grapple_target = _enemigo;
                
                // Ajustamos el punto exacto al centro del enemigo
                grapple_x = _enemigo.x;
                grapple_y = _enemigo.y - 15;
                
                if (global.sfx) audio_play_sound(snd_hit, 10, false, 2);
            }
            
            // B. Chequear Pared (obj_wall) - Si no pegó a enemigo
            else if (position_meeting(_tip_x, _tip_y, obj_wall)) {
                grapple_hitting = true;
                grapple_type = "PARED";
                
                // Guardamos el punto exacto del impacto
                grapple_x = _tip_x;
                grapple_y = _tip_y;
                
                if (global.sfx) audio_play_sound(snd_hit, 10, false, 2);
            }
            
            // C. LLegó al límite sin pegar nada
            else if (grapple_anim_dist >= grapple_max_dist) {
                grapple_is_returning = true; // Empieza a devolverse
            }
        } 
        else {
            // --- RETORNO (Se devuelve) ---
            grapple_anim_dist -= grapple_speed_ext * 1.5; // Vuelve más rápido
            
            // Si ya volvió a la mano, cancelamos el estado
            if (grapple_anim_dist <= 0) {
                state = PLAYERSTATE2.IDLE;
            }
        }
    } 
    
    // --- FASE B: YA IMPACTÓ, EMPIEZA EL JALÓN ---
    else {
        // Aumentamos el timer de seguridad
        grapple_timer++;

        if (grapple_type == "PARED") {
            // --- CASO PARED: VAS TÚ ---
            var _dir_hacia_pared = point_direction(x, y, grapple_x, grapple_y);
            var _dist = point_distance(x, y, grapple_x, grapple_y);
            
            hsp = lengthdir_x(16, _dir_hacia_pared);
            vsp = lengthdir_y(16, _dir_hacia_pared);
            
            // Soltar si llegas, presionas espacio o pasa mucho tiempo
            if (_dist < 35 || keyboard_check_pressed(vk_space) || grapple_timer > 50) {
                state = PLAYERSTATE2.IDLE;
                vsp = -4; // Saltito de salida
            }
        } 
        else if (grapple_type == "ENEMIGO") {
            // --- CASO ENEMIGO: VIENE ÉL (Jalón Scorpion) ---
            if (instance_exists(grapple_target)) {
                var _dir_hacia_mi = point_direction(grapple_target.x, grapple_target.y, x, y);
                var _dist_enemigo = point_distance(x, y, grapple_target.x, grapple_target.y);
                
                // Actualizamos el punto del cable al enemigo (por si se mueve)
                grapple_x = grapple_target.x;
                grapple_y = grapple_target.y - 15;
                
                // Mover enemigo hacia nosotros
                with(grapple_target) {
                    hsp = lengthdir_x(other.grapple_pull_speed, _dir_hacia_mi);
                    vsp = lengthdir_y(other.grapple_pull_speed, _dir_hacia_mi);
                    x += hsp;
                    y += vsp;
                }
                
                // Soltar si llega, espacio o tiempo
                if (_dist_enemigo < 50 || keyboard_check_pressed(vk_space) || grapple_timer > 60) {
                    state = PLAYERSTATE2.IDLE;
                    // Opcional: Activar stun o ataque melee aquí
                }
            } else {
                state = PLAYERSTATE2.IDLE; // El enemigo desapareció
            }
        }
    }
} else {
    // Si no estamos en GRAPPLE, el timer vuelve a 0
    grapple_timer = 0;
}



if (abs(push_h) > 0.8) {
    hsp = push_h; // AQUÍ SÍ: Sobreescribe el hsp que puso el WALK o JUMP
    push_h = lerp(push_h, 0, 0.1); 
} else {
    push_h = 0;
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
    
    // 1. ACTUALIZAR PUNTOS Y ACTIVAR EFECTO SEXY EN OBRAIN
    if (global.myTeam == "AZUL") {
        global.puntos_azul++;
        with(oBrain) { 
            marcador_escala_azul = 3; 
            marcador_shake = 15; 
        }
    } else {
        global.puntos_rojo++;
        with(oBrain) { 
            marcador_escala_rojo = 3; 
            marcador_shake = 15; 
        }
    }

    // 2. LÓGICA DE LA BANDERA (Lo que ya tenías)
    has_flag = false;
    with (objetivo) { 
        x = spawnX; 
        y = spawnY; 
        has_flag = false; 
        portador_instancia = noone; 
    }

    // 3. NOTIFICACIÓN
    var notif = instance_create_layer(0, 0, "Instances", oNotification);
    notif.text = "ANOTASTE!";
    notif.color = c_lime;
}

// --- DEVOLVER MI BANDERA (Local) ---
var miBandera = (global.myTeam == "AZUL") ? oFlag2 : oFlag;
if (!score_pending && place_meeting(x, y, miBandera) && !miBandera.has_flag && (miBandera.x != miBandera.spawnX)) {
    with(miBandera) { x = spawnX; y = spawnY; }
    var notif = instance_create_layer(0, 0, "Instances", oNotification);
    notif.text = "SALVASTE TU BANDERA!";
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