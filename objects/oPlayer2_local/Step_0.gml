// Esto debería estar en el Step de tu objeto enemigo/jugador
if (state == PLAYER2.HIT) {
    hsp = hsp * 0.9; // Fricción: pierde 10% de velocidad cada frame
}

// En el Step del Enemigo
if (state == PLAYER2.HIT) {
    if (hit_bloqueo_timer > 0) {
        hit_bloqueo_timer--;
    } else {
        state = PLAYER2.IDLE; // Aquí recupera el control
    }
}
// ======================================================
// ❄ CONGELAR AL FINAL
// ======================================================
if (global.game_over) { 
    hsp = 0; 
    vsp = 0; 
    exit; 
}

// --- TIMERS DE POWERUPS ---
if (shield_timer > 0) {
    shield_timer--;
    if (shield_timer <= 0) has_shield = false;
}

if (damage_timer > 0) {
    damage_timer--;
    if (damage_timer <= 0) damage_boost = 1;
}

if (ammo_timer > 0) {
    ammo_timer--;
    if (ammo_timer <= 0) infinite_ammo = false;
}

if (shield_timer > 0) {
    shield_timer--;
    
    // Si quedan menos de 2 segundos (120 frames), que el alfa del HUD parpadee
    if (shield_timer < 120) {
        // Esto crea un parpadeo sexy
        shield_alpha_hud = abs(sin(current_time / 100)); 
    }

    if (shield_timer <= 0) {
        has_shield = false;
        // Sonido de "se acabó el poder" (opcional)
        if (global.sfx) audio_play_sound(snd_powerdown, 5, false);
    }
}

	// Lógica del timer
	if (invul_timer > 0) {
	    invul_timer--;
	    invulnerable = true;
	    image_alpha = 0.5; // Efecto visual de transparencia
	} else {
if (!isDead) {
        invulnerable = false;
        image_alpha = 1;
    }
	}

// --- LÓGICA DE VELOCIDAD ---
if (speed_timer > 0) 
{
	//Rastro Fantasma
	if !alarm[0] and global.EffectTrial
	alarm[0] = TimeAlarmEffectTrail;
	//timer
    speed_timer--;
	//multiplo de velocidad
    walksp_mult = 1.5; // El multiplicador del Power-Up
} 
else 
{
    walksp_mult = 1.0; // VELOCIDAD NORMAL (1 = sin cambios)
}

// Ahora sí, se calcula la velocidad final
walksp = walksp_base * walksp_mult;

if (!mouse_check_button(mb_left)) {
    ak_recoil = max(0, ak_recoil - 0.6); // qué tan rápido se “calma”
}

// se va “recuperando” solo
recoil_kick *= 0.75;
recoil_angle *= 0.75;
recoil_x *= 0.7;
recoil_y *= 0.7;

if (reloading)
{
    reload_timer--;

    if (reload_timer <= 0)
    {
        var w = guns[weapon.index];
        
        // 🔥 FILTRO DE SEGURIDAD: Si el arma no existe, abortamos
        if (w == noone || !is_struct(w)) {
            reloading = false;
            exit; 
        }

        var t = w.ammoType;
        var res  = reserve[$ t];
        
        // Verificamos que el tipo de munición exista en la reserva
        if (res == undefined) { reloading = false; exit; }

        var need = w.maxAmmo - w.ammo;
        var take = min(need, res);

        w.ammo += take;
        reserve[$ t] -= take;

        guns[weapon.index] = w;
        reloading = false;
    }
}

// ======================================================
// RESET DE TECLAS
// ======================================================
key_left  = false;
key_right = false;
key_jump  = false;
key_melee = false;
key_shoot = false;


// ======================================================
// IA – SOLO PERSEGUIR BANDERA
// ======================================================
var objetivo_bandera;
var miBandera;
var miBase;

if (team == "AZUL") {
    objetivo_bandera = oFlag;      // bandera enemiga (roja)
    miBandera        = oFlag2;     // bandera propia (azul)
    miBase           = obj_base_blue;
} else {
    objetivo_bandera = oFlag2;     // bandera enemiga (azul)
    miBandera        = oFlag;      // bandera propia (roja)
    miBase           = obj_base_red;
}

if (state != PLAYER2.DEAD) {
    // ======================================================
    // IA DE EMOTES 
    // ======================================================
    if (emote_cd > 0) emote_cd--;
    var _emote_auto = -1;

    if (emote_cd <= 0) {
        if (hit == true || (old_hp > hp)) {
            if (random(100) < 5) _emote_auto = 1; 
        }
        if (has_flag && distance_to_object(miBase) < 200) {
            if (random(100) < 1) _emote_auto = 1; 
        }
        if (instance_exists(oExplosionFX)) {
            var ex = instance_nearest(x, y, oExplosionFX);
            if (point_distance(x, y, ex.x, ex.y) < 100) {
                if (random(100) < 10) _emote_auto = 3; 
            }
        }
        if (instance_exists(oPlayer_offline) && oPlayer_offline.state == PLAYERSTATE2.DEAD) {
            if (point_distance(x, y, oPlayer_offline.x, oPlayer_offline.y) < 400) {
                if (random(100) < 2) _emote_auto = 0; 
            }
        }
        if (hp == max_hp && alarm[1] == 119) { 
            _emote_auto = 3; 
        }
    }

    old_hp = hp; 

    if (_emote_auto != -1) {
        var _e = instance_create_layer(x, y - 75, "Instances", oEmote);
        if (instance_exists(_e)) {
            _e.image_index = _emote_auto;
            _e.owner = id;
            emote_cd = 150; 
        }
    }

    var target_x;
    var target_y;

    // ======================================================
    // LÓGICA DE DISPARO (Ignora si el player está muerto)
    // ======================================================
    key_shoot = false; 

    if (instance_exists(oPlayer_offline) && oPlayer_offline.state != PLAYERSTATE2.DEAD && !has_flag) {
        var dist = point_distance(x, y, oPlayer_offline.x, oPlayer_offline.y);
        var w = guns[weapon.index]; 

        if (w != noone && w.ammo > 0) {
            if (dist < 400 && !collision_line(x, y - 16, oPlayer_offline.x, oPlayer_offline.y - 16, obj_wall, true, true)) {
                if (random(100) < 20) { 
                    key_shoot = true; 
                }
            }
        } else if (w != noone && w.ammo <= 0) {
            scrReloadWeapon();
        }
    }

    // ======================================================
    // LOGICA DE MELEE Y GRANADAS
    // ======================================================
    if (melee_cd > 0) melee_cd--;

    if (instance_exists(oPlayer_offline) && oPlayer_offline.state != PLAYERSTATE2.DEAD) {
        var dist = point_distance(x, y, oPlayer_offline.x, oPlayer_offline.y);

        if (dist > 150 && dist < 450 && granadas > 0 && dificultad >= 2) {
            if (lanzar_granada_timer > 0) lanzar_granada_timer--;
            if (lanzar_granada_timer <= 0 && random(100) < 2) { 
                granadas -= 1;
                lanzar_granada_timer = room_speed * 2; 
                var dir = point_direction(x, y - 20, oPlayer_offline.x, oPlayer_offline.y - 20);
                var nade = instance_create_layer(x, y - 20, "Instances", oGranada_enemy);
                if (instance_exists(nade)) {
                    nade.hsp = lengthdir_x(9, dir);
                    nade.vsp = lengthdir_y(9, dir) - 3;
                }
            }
        }
        
        if (dist < 40 && melee_cd <= 0) {
            var w = guns[weapon.index];
            if (w == noone || w.ammo <= 0) {
                melee_cd = 30;
                melee_active = 6;
                if (global.sfx) audio_play_sound(snd_melee, 1, false);
            }
        }
    }

    // --- 🛡️ EJECUCIÓN DEL DAÑO MELEE CON ESCUDO ---
    if (melee_active > 0) 
    {
        melee_active--;
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
 
        var target = instance_place(hx, hy, oPlayer_offline); 
        if (target != noone && target.state != PLAYERSTATE2.DEAD) {
            
            // FILTRO DE ESCUDO: Si el objetivo tiene escudo, no recibe daño
            if (!target.has_shield) {
                health -= melee_damage; 
                with(target) { 
                    image_blend = c_red; 
                    alarm[0] = 5; 
                } 
            } else {
                // Feedback de que golpeó un escudo
                if (global.sfx) audio_play_sound(snd_shield_impact, 20, false);
            }
            melee_active = 0; 
        }
    }

	// ======================================================
    // PRIORIDADES Y TARGET
    // ======================================================
    var dist_jugador = 10000;
    var player_vivo = false;
    var player_tiene_mi_bandera = false;

    if (instance_exists(oPlayer_offline)) {
        if (oPlayer_offline.state != PLAYERSTATE2.DEAD) {
            dist_jugador = point_distance(x, y, oPlayer_offline.x, oPlayer_offline.y);
            player_vivo = true;
            // Checamos si el jugador tiene la bandera del equipo del bot
            if (oPlayer_offline.has_flag) player_tiene_mi_bandera = true;
        }
    }

    // --- TOMA DE DECISIÓN CRÍTICA ---
    if (player_tiene_mi_bandera) {
        // PRIORIDAD 1: ¡El jugador robó nuestra bandera! A por él sin importar nada.
        target_x = oPlayer_offline.x;
        target_y = oPlayer_offline.y;
    } 
    else if (has_flag) {
        // PRIORIDAD 2: Tengo la bandera enemiga, voy a mi base.
        target_x = miBase.x; 
        target_y = miBase.y;
    } 
    else {
        // PRIORIDAD 3: Juego normal (Atacar o ir por la bandera enemiga)
        var umbral_persecucion = (dificultad == 1) ? 150 : (dificultad == 2 ? 300 : 500);
        var lo_veo = player_vivo ? !collision_line(x, y - 16, oPlayer_offline.x, oPlayer_offline.y - 16, obj_wall, true, true) : false;

        if (player_vivo && dist_jugador < umbral_persecucion && lo_veo) {
            target_x = oPlayer_offline.x;
            target_y = oPlayer_offline.y;
        } else {
            if (objetivo_bandera != noone) {
                target_x = objetivo_bandera.x;
                target_y = objetivo_bandera.y;
            }
        }
    }

 
    if (instance_exists(oPlayer_offline) && dist_jugador < 40 && melee_cd <= 0) {
        melee_cd = room_speed div 3;
        melee_active = 6;
        if (global.sfx) audio_play_sound(snd_melee, 1, false);
    }

    if (has_flag && miBase != noone) {
        target_x = miBase.x;
        target_y = miBase.y;
    }

    //if (target_x == undefined) exit;

    var dx = target_x - x;
    var dy = target_y - y;
    var dir = sign(dx);

    if (abs(dx) > 8) {
        if (dx > 0) { key_right = true; key_left = false; } 
        else { key_left = true; key_right = false; }
    }

    var grounded = place_meeting(x, y + 1, obj_wall) || place_meeting(x, y + 1, oPlataformaPasable);
    var wall_ahead = place_meeting(x + dir * 12, y, obj_wall);

    if (puedo_saltar_timer > 0) puedo_saltar_timer--;
    if (!grounded) puedo_saltar_timer = 15; 

    if (grounded && puedo_saltar_timer <= 0) {
        if (wall_ahead || dy < -40 || (abs(dx) > 10 && abs(hsp) < 0.2)) {
            key_jump = true;
            puedo_saltar_timer = 25;
        }
    }
}



// ======================================================
// MAQUINA DE ESTADOS
// ======================================================

is_grounded = place_meeting(x, y + 1, obj_wall) 
           || place_meeting(x, y + 1, oPlataformaPasable);

switch (state) {

    case PLAYER2.IDLE:
        sprite_index = spr_player_idle;
        hsp = 0;
		scrPlayerWeaponUpdate_bot();
        if (key_right || key_left)
            state = PLAYER2.WALK;

        if (key_jump && is_grounded) {
            vsp = jumpsp;
            state = PLAYER2.JUMP;
        }
    break;


case PLAYER2.WALK:

	var move = key_right - key_left;
    var _speed_final = has_flag ? walksp * 0.7 : walksp;

    // SOLO camina si no está siendo empujado fuertemente
    if (abs(push_h) < 1) { 
        hsp = move * _speed_final;
    }
        
        scrPlayerWeaponUpdate_bot();
        sprite_index = spr_player_walk;

        if (hsp != 0) image_xscale = sign(hsp) * 1.5;

        if (move == 0) state = PLAYER2.IDLE;

        if (key_jump && is_grounded) {
            vsp = jumpsp;
            state = PLAYER2.JUMP;
        }
    break;

    case PLAYER2.JUMP:
	var move = key_right - key_left;
    if (abs(push_h) < 1) {
        hsp = move * walksp;
    }
		scrPlayerWeaponUpdate_bot();
        if (hsp != 0)
            image_xscale = sign(hsp) * 1.5;

        if (is_grounded)
            state = PLAYER2.IDLE;
    break;


    case PLAYER2.DEAD:
        hsp = 0;
        sprite_index = spr_player_dead;

        if (image_index >= image_number - 1)
            visible = false;
    break;
}

if (abs(push_h) > 0.8) {
    hsp = push_h; // AQUÍ SÍ: Sobreescribe el hsp que puso el WALK o JUMP
    push_h = lerp(push_h, 0, 0.1); 
} else {
    push_h = 0;
}

// --- MUERTE LOCAL ---
if (hp <= 0 && !isDead) {
    isDead = true;
    state = PLAYERSTATE2.DEAD;
    invulnerable = true;
    alarm[1] = 120; // Respawn
    
    var killerName = (last_killer != "") ? last_killer : "Alguien";
    scrAddKillFeed(killerName + " te elimino");
}

// ======================================================
// GRAVEDAD
// ======================================================
if (state != PLAYER2.DEAD)
    vsp += grv;


// ======================================================
// COLISION HORIZONTAL
// ======================================================
if (place_meeting(x + hsp, y, obj_wall)) {
    while (!place_meeting(x + sign(hsp), y, obj_wall))
        x += sign(hsp);
    hsp = 0;
}
x += hsp;


// ======================================================
// COLISION PLATAFORMA PASABLE
// ======================================================
if (vsp > 0) {
    var plat = instance_place(x, y + vsp, oPlataformaPasable);

    if (plat != noone && bbox_bottom <= plat.bbox_top) {
        y = plat.bbox_top - (bbox_bottom - y);
        vsp = 0;

        if (state == PLAYER2.JUMP)
            state = PLAYER2.IDLE;
    }
}


// ======================================================
// COLISIÓN VERTICAL
// ======================================================
if (place_meeting(x, y + vsp, obj_wall)) {
    while (!place_meeting(x, y + sign(vsp), obj_wall))
        y += sign(vsp);
    vsp = 0;
}
y += vsp;

//Capturar Bandera
if (place_meeting(x, y, objetivo_bandera)
&& state != PLAYER2.DEAD
&& !has_flag
&& !objetivo_bandera.has_flag) {

    has_flag = true;

    with (objetivo_bandera) {
        has_flag = true;
        portador_instancia = other.id;
    }
}

//ANOTAR
if (place_meeting(x, y, miBase)
&& has_flag
&& state != PLAYER2.DEAD) {

    //if (team == "ROJO") global.puntos_azul++;
    //else global.puntos_rojo++;
    // 1. ACTUALIZAR PUNTOS Y ACTIVAR EFECTO SEXY EN OBRAIN
    if (team == "ROJO") {
        global.puntos_rojo++;
        with(oBrain) { 
            marcador_escala_rojo = 3; 
            marcador_shake = 15; 
        }
    } else {
        global.puntos_azul++;
        with(oBrain) { 
            marcador_escala_azul = 3; 
            marcador_shake = 15; 
        }
    }
    has_flag = false;

    with (objetivo_bandera) {
        x = spawnX;
        y = spawnY;
        has_flag = false;
        portador_instancia = noone;
    }

    var notif = instance_create_layer(0, 0, "Instances", oNotification);
    notif.text  = "EL ENEMIGO ANOTO!";
    notif.color = c_red;
}

//DEVOLVER SU BANDERA
if (place_meeting(x, y, miBandera)
&& !miBandera.has_flag
&& (miBandera.x != miBandera.spawnX)) {

    with (miBandera) {
        x = spawnX;
        y = spawnY;
    }
}

// --- SISTEMA DE FLASH ROJO ---
if (hit == true) {
    image_blend = c_red; // Forzamos el rojo mientras dure el golpe
    hit_time--;
    
    if (hit_time <= 0) {
        hit = false;
        hit_time = 3;
        image_blend = c_white; // SOLO aquí vuelve a la normalidad
    }
}
