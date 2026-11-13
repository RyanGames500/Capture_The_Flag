// --- HIT-STOP: al conectar un golpe fuerte, mi personaje se congela unos frames ---
if (variable_global_exists("hitstop") && global.hitstop > 0) {
	if (!variable_instance_exists(id, "hs_frozen") || !hs_frozen) {
		hs_spd = image_speed;
		image_speed = 0;
		hs_frozen = true;
	}
	global.hitstop -= 1;
	exit;
}
if (variable_instance_exists(id, "hs_frozen") && hs_frozen) {
	image_speed = hs_spd;
	hs_frozen = false;
}

if (state == PLAYERSTATE.HIT) {
	hsp = hsp * 0.9;
}

if (state == PLAYERSTATE.HIT) {
	if (hit_bloqueo_timer > 0) {
		hit_bloqueo_timer--;
	} else {
		state = PLAYERSTATE.IDLE;
	}
}

if (global.game_over)
{
	hsp = 0;
	vsp = 0;
	exit;
}

if (emote_cd > 0) emote_cd--;

var _emote_to_send = -1;

if (emote_cd <= 0)
{
	if (vkey_pressed(ord("1"))) _emote_to_send = 0;
	if (vkey_pressed(ord("2"))) _emote_to_send = 1;
	if (vkey_pressed(ord("3"))) _emote_to_send = 2;
	if (vkey_pressed(ord("4"))) _emote_to_send = 3;

	if (_emote_to_send != -1)
	{
		var _e = instance_create_layer(x, y - 75, "Instances", oEmote);
		_e.image_index = _emote_to_send;
		_e.owner = id;

		if (global.ONLINE) {
			with(oOtherPlayer) {
				SendEventToClient(clientId, "player_emote", {
					ownerId: global.clientId,
					emoteIndex: _emote_to_send
				});
			}
		}

		emote_cd = 120;
	}
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

	if (shield_timer < 120) {
		shield_alpha_hud = abs(sin(current_time / 100));
	}

	if (shield_timer <= 0) {
		has_shield = false;
		if (global.sfx) audio_play_sound(snd_powerdown, 5, false);
	}
}

// GRAVEDAD LOCA: voltea al muñeco cuando cambia la gravedad (scr_reloj). _gd = 1 normal, -1 al reves
scr_grav_voltear();
var _gd = scr_grav_dir();

if ((_gd > 0) ? (place_meeting(x, y + 1, obj_wall) || place_meeting(x, y + 1, oPlataformaPasable)) : scr_grav_en_techo())
{
	is_grounded = true;
}
else
{
	is_grounded = false;
}

if (!variable_instance_exists(id, "fx_air")) { fx_air = 0; fx_last_s = 0; fx_prev_ground = is_grounded; }
if (fx_prev_ground && !is_grounded && vsp * _gd < 0) fx_dust(x, scr_grav_pies(), 6, 0);
if (!fx_prev_ground && is_grounded && fx_air > 8) fx_dust(x, scr_grav_pies(), 10, 0);
var _fx_s = sign(hsp);
if (is_grounded && _fx_s != 0 && fx_last_s != 0 && _fx_s != fx_last_s && abs(hsp) > 1.5) fx_dust(x, scr_grav_pies(), 6, -_fx_s);
if (_fx_s != 0) fx_last_s = _fx_s;
fx_air = is_grounded ? 0 : fx_air + 1;
fx_prev_ground = is_grounded;

key_left  = vkey(ord("A"));
key_right = vkey(ord("D"));
key_jump  = vkey_pressed(ord("W"));
key_melee = vmouse_pressed(mb_right);

// Efectos de las armas nuevas: aturdido / en la red no camina (scr_armas)
scr_efx_step();
scr_efx_controles();

// Habilidad (Q) y pasivas de tu personaje (scr_personajes)
scr_hab_step();

if (melee_cd > 0) melee_cd--;
if (melee_active > 0) melee_active--;
if (crush_cd > 0) crush_cd--;

if (speed_timer > 0)
{
	if (!alarm[0] && global.EffectTrial) alarm[0] = TimeAlarmEffectTrail;
	speed_timer--;
	walksp_mult = 1.5;
}
else
{
	walksp_mult = 1.0;
}

walksp = walksp_base * walksp_mult;
walksp *= scr_arma_peso_mult();   // la Thompson pesa (scr_armas)
walksp *= scr_hab_vel_mult();     // la coraza del Tanque pesa (scr_personajes)
walksp *= scr_efx_vel_mult();     // el congelador te pone lento (scr_armas)

if (!vmouse(mb_left)) {
	ak_recoil = max(0, ak_recoil - 0.6);
}

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

		if (w == noone || !is_struct(w)) {
			reloading = false;
			exit;
		}

		var t = w.ammoType;
		var res = reserve[$ t];

		if (res == undefined) { reloading = false; exit; }

		var need = w.maxAmmo - w.ammo;
		var take = min(need, res);

		w.ammo += take;
		reserve[$ t] -= take;

		guns[weapon.index] = w;
		reloading = false;
	}
}

if (global.ONLINE && spawn_lock > 0)
{
	spawn_lock--;

	scr_spawn_en_base();   // en la base de mi equipo (antes: x=51 el host, x=591 los demás)

	if (variable_instance_exists(id, "latest_x")) latest_x = x;
	if (variable_instance_exists(id, "latest_y")) latest_y = y;
}

// Cambiar entre tus 2 armas: E, rueda del mouse o tocar el cuadro chico (scr_armas, SEGUNDA ARMA)
scr_arma_cambio_step();

var canShoot = (!has_flag || scr_pj_dispara_con_bandera()) && (state != PLAYERSTATE.DEAD);   // el Sargento si puede (scr_personajes)
if (scr_efx_aturdido()) canShoot = false;   // aturdido o congelado: no dispara

if (melee_active > 0)
{
	var range = 26;
	var hx = x + (range * sign(image_xscale));
	var hy = y - 10;

	if (can_sfx == false)
	{
		var _slash = instance_create_layer(hx, hy, "Instances", oMeleeFX);
		_slash.image_xscale = sign(image_xscale);
		_slash.depth = depth - 10;
		can_sfx = true;
		alarm[4] = 10;
	}

	var target = instance_place(hx, hy, oOtherPlayer);

	if (target != noone)
	{
		if (target.team != global.myTeam)
		{
			melee_active = 0;

			if (global.ONLINE)
			{
				fx_damage_number(target.x, target.bbox_top - 8, melee_damage, 0);
				fx_impact_net(target.x, target.y - 20, (image_xscale > 0) ? 180 : 0, 6, false);
				scr_predict_hit(target, melee_damage, 10);
				scr_hit_confirm(target, false, true);
				SendEventToClient(target.clientId, "hit", {
					damage: melee_damage,
					killer: global.myName,
					reason: "pvp"
				});
			}
			else
			{
				target.health -= melee_damage;
			}
		}
	}
}

if (vmouse_pressed(mb_right) && !scr_efx_aturdido())
{
	if (granadas > 0) {
		granadas -= 1;
		melee_cd = room_speed div 3;
		melee_active = 6;

		var dir = point_direction(x, y - 16, aim_x(), aim_y());
		var fuerza = 8;

		// Electrica o cegadora: misma granada pero con su efecto (scr_armas, GRANADAS)
		if (variable_instance_exists(id, "granada_tipo") && granada_tipo != "") {
			scr_granada_lanzar_efecto(granada_tipo, dir);
			if (granadas <= 0) granada_tipo = "";
		} else {
		var gx = x + lengthdir_x(15, dir);
		var gy = y - 16 + lengthdir_y(15, dir);

		var nade = instance_create_layer(gx, gy, "Instances", oMyEntity);

		nade.owner_name = global.myName;
		nade.sprite_index = spr_granada;
		nade.damage = 40;
		nade.owner_team = global.myTeam;
		nade.owner_id = id;

		nade.is_granada = true;
		nade.is_rocket = true;

		nade.hsp = lengthdir_x(fuerza, dir);
		nade.vsp = lengthdir_y(fuerza, dir) - 2;
		}
	}
	else {
		if (melee_cd <= 0 && state != PLAYERSTATE.DEAD)
		{
			melee_cd = room_speed div 3;
			melee_active = 6;

			if (global.sfx) audio_play_sound(snd_melee, 1, false);

			with(oOtherPlayer) {
				SendEventToClient(clientId, "fx_melee", {
					x: other.x, y: other.y, dir: sign(other.image_xscale)
				});
			}
		}
	}
}

if (state != PLAYERSTATE.DEAD) {
	vsp += grv * _gd;   // GRAVEDAD LOCA: al reves cae hacia el techo
}

if (mi_clase == -1) {
	visible = false;
	exit;
}

// --- PLATAFORMA DE SALTO (scr_jugabilidad): saltar encima de ella te lanza alto ---
if (key_jump && is_grounded && (state == PLAYERSTATE.IDLE || state == PLAYERSTATE.WALK || state == PLAYERSTATE.JUMP || (state == PLAYERSTATE.HIT && abs(push_h) < 1))) {
	if (scr_salto_usar()) { is_grounded = false; key_jump = false; state = PLAYERSTATE.JUMP; }
}

switch (state) {

	case PLAYERSTATE.INTRO:
		sprite_index = anims[mi_clase].idle;
	break;

	case PLAYERSTATE.IDLE:
		if (canShoot && melee_active <= 0)
		{
			scrPlayerWeaponUpdate();
		}

		if (abs(push_h) < 1) hsp = 0;
		sprite_index = anims[mi_clase].idle;
		if (key_jump && is_grounded) { is_grounded = false; vsp = jumpsp * _gd; state = PLAYERSTATE.JUMP; }
		if (key_right || key_left) state = PLAYERSTATE.WALK;
	break;

	case PLAYERSTATE.WALK:
		if (canShoot && melee_active <= 0)
		{
			scrPlayerWeaponUpdate();
		}

		var move = key_right - key_left;
		var _speed_final = has_flag ? walksp * scr_pj_mult_bandera() : walksp;   // cada personaje carga la bandera distinto

		if (abs(push_h) < 1) {
			hsp = move * _speed_final;
		}
		sprite_index = anims[mi_clase].walk;
		if (hsp != 0) image_xscale = sign(hsp) * 1.5;

		if (hsp == 0) state = PLAYERSTATE.IDLE;
		if (key_jump && is_grounded) { is_grounded = false; vsp = jumpsp * _gd; state = PLAYERSTATE.JUMP; }
	break;

	case PLAYERSTATE.JUMP:
		if (canShoot && melee_active <= 0)
		{
			scrPlayerWeaponUpdate();
		}

		var move = key_right - key_left;
		if (abs(push_h) < 1) {
			// Con la bandera también en el aire (antes saltando ibas a velocidad completa)
			hsp = move * (has_flag ? walksp * scr_pj_mult_bandera() : walksp);
		}
		if (hsp != 0) image_xscale = sign(hsp) * 1.5;
		if (is_grounded) state = PLAYERSTATE.IDLE;
	break;

	case PLAYERSTATE.SHOT:
		hsp = 0;
		sprite_index = anims[mi_clase].idle;
		image_speed = 0.8;

		if (floor(image_index) == 1 && !bullet_created)
		{
			var inst = instance_create_layer(x + (23 * sign(image_xscale)), y - 12, "Instances", oMyEntity);
			inst.speed = 10;
			inst.sprite_index = sprOtherMissile;
			inst.direction = (image_xscale > 0) ? 0 : 180;
			inst.image_xscale = image_xscale;
			bullet_created = true;
		}

		if (image_index >= image_number - 1) {
			state = PLAYERSTATE.IDLE;
			image_speed = 1;
		}
	break;

	case PLAYERSTATE.HIT:
		sprite_index = anims[mi_clase].hit;
		// Golpe normal (bala): se ve el golpe pero sigues moviendote, saltando y disparando.
		// Solo te quita el control cuando te avientan (boxeo, mina, caja): ahi manda el empuje.
		if (abs(push_h) < 1) {
			if (canShoot && melee_active <= 0)
			{
				scrPlayerWeaponUpdate();
			}
			var move = key_right - key_left;
			hsp = move * (has_flag ? walksp * scr_pj_mult_bandera() : walksp);
			if (hsp != 0) image_xscale = sign(hsp) * 1.5;
			if (key_jump && is_grounded) { is_grounded = false; vsp = jumpsp * _gd; state = PLAYERSTATE.JUMP; }
		}
		if (image_index >= image_number - 1) state = PLAYERSTATE.IDLE;
	break;

	case PLAYERSTATE.DEAD:
		hsp = 0;
		sprite_index = anims[mi_clase].dead;
		if (image_index >= image_number - 1)
		{
			visible = false;
		}
	break;
}

if (abs(push_h) > 0.8) {
	hsp = push_h;
	push_h = lerp(push_h, 0, 0.1);
} else {
	push_h = 0;
}

// Gancho de la Exploradora: el jalón usa los mismos choques de abajo (scr_personajes)
scr_hab_mov();

var plat = instance_place(x, y + 1, oMovingPlatform);
if (plat != noone && vsp >= 0 && _gd > 0)
{
	var my_bottom = bbox_bottom;
	var plat_top  = plat.bbox_top;
	y -= (my_bottom - plat_top);
	y += plat.dy;
}

// GRAVEDAD LOCA: al reves las plataformas te detienen por abajo (scr_reloj)
if (_gd < 0 && scr_grav_plataforma_techo() && state == PLAYERSTATE.JUMP) state = PLAYERSTATE.IDLE;

if (vsp > 0 && _gd > 0)
{
	var plat2 = instance_place(x, y + vsp, oPlataformaPasable);
	if (plat2 != noone)
	{
		if (bbox_bottom <= plat2.bbox_top + vsp)
		{
			y = plat2.bbox_top - (bbox_bottom - y);
			vsp = 0;

			if (state == PLAYERSTATE.JUMP)
				state = PLAYERSTATE.IDLE;
		}
	}
}

if (place_meeting(x + hsp, y, obj_wall)) {
	while (!place_meeting(x + sign(hsp), y, obj_wall)) x += sign(hsp);
	hsp = 0;
}
x += hsp;

if (place_meeting(x, y + vsp, obj_wall)) {
	while (!place_meeting(x, y + sign(vsp), obj_wall)) {
		y += sign(vsp);
	}
	vsp = 0;
}

y += vsp;

if (health <= 0 && !isDead)
{
	scr_logros_racha_reset();   // te eliminaron: la racha de los logros vuelve a 0 (DatabaseFunctions)
	reloading = false;
	reload_timer = 0;

	if (global.ONLINE)
	{
		var _weapon_to_drop = guns[weapon.index];

		if (oBrain.AmIPseudoHost)
		{
			scr_drop_on_death(_weapon_to_drop, x, y);
		}
		else
		{
			if (instance_exists(oOtherPlayer)) {
				with(oOtherPlayer) {
					SendEventToClient(clientId, "request_drop_on_death", {
						weapon: _weapon_to_drop,
						x: other.x,
						y: other.y
					});
				}
			}
		}
	}

	isDead = true;
	state = PLAYERSTATE.DEAD;
	invulnerable = true;
	alarm[1] = 120;

	var localText  = "";
	var remoteText = "";

	if (death_reason == "crush")
	{
		localText = "Moriste aplastado";
		remoteText = playerName + " murio aplastado";
	}
	else if (death_reason == "lava")
	{
		localText = "Te quemaste en la lava";
		remoteText = playerName + " cayo en la lava";
	}
	else
	{
		var killerName = (last_killer != "") ? last_killer : "Alguien";
		localText = killerName + " te elimino";
		remoteText = killerName + " elimino a " + playerName;
	}

	scrAddKillFeed(localText);

	// TODOS CONTRA TODOS: la baja es del ultimo que me pego (el lider la cuenta) (scr_reloj)
	if (scr_modo_todos()) {
		var _kil = (death_reason == "lava" || death_reason == "crush") ? "" : string(last_killer);
		if (oBrain.AmIPseudoHost) scr_todos_baja(_kil, x, y);
		else SendEventToClient(oBrain.pseudoHostClientId, "todos_baja", { k: _kil, x: x, y: y });
	}

	if (global.ONLINE && instance_exists(oOtherPlayer))
	{
		with(oOtherPlayer) {
			SendEventToClient(clientId, "kill_feed", { msg: remoteText });
		}
	}
}

if (state == PLAYERSTATE.DEAD && has_flag == true)
{
	has_flag = false;
	var bandera_robada = (global.myTeam == "AZUL") ? oFlag : oFlag2;
	var drop_x = x;
	var drop_y = y;

	with (bandera_robada)
	{
		has_flag = false;
		portador_instancia = noone;
		x = drop_x;
		y = drop_y;
		velocidad_caida = -2;
		sprite_index = spr_suela;
	}

	if (global.ONLINE && instance_exists(oOtherPlayer))
	{
		with(oOtherPlayer) {
			SendEventToClient(clientId, "flag_dropped", {
				team: global.myTeam,
				dropX: drop_x,
				dropY: drop_y
			});
		}
	}
	fb_toast("SOLTASTE LA BANDERA", "Quedo en el suelo", FB_ORO);
}

var objetivo = (global.myTeam == "AZUL") ? oFlag : oFlag2;

if (!score_pending && place_meeting(x, y, objetivo) && state != PLAYERSTATE.DEAD && !has_flag && !objetivo.has_flag && !scr_bomba_no_coger() && !scr_modo_sin_banderas())   // (BANDERA BOMBA: el que la paso espera un ratito)
{
	has_flag = true;
	with(objetivo) {
		has_flag = true;
		portador_instancia = other.id;
	}

	if (global.myTeam == "AZUL") global.bandera_roja_robada = true;
	else global.bandera_azul_robada = true;

	if (instance_exists(oOtherPlayer)) {
		with(oOtherPlayer) {
			SendEventToClient(clientId, "flag_capture", { team: global.myTeam });
		}
	}
	fb_banner_tienes();   // B: LA TIENES! (scr_feedback)
}

// BANDERA BOMBA: pasarla tocando a un aliado (scr_reloj)
scr_bomba_jugador_step();

var miBase = (global.myTeam == "AZUL") ? obj_base_blue : obj_base_red;

if (place_meeting(x, y, miBase) && has_flag && !score_pending)
{
	// En sala privada no se suma nada (es partida entre amigos)
	if (!scr_fin_es_privada()) {
		global.flags_captured += 1;
		scr_xp_dar(10);   // capturar bandera (scr_reloj)

		with(oBrain) {
			save_state = "prepare";
			save_timer = room_speed;
		}
	}

	score_pending = true;
	has_flag = false;

	with (objetivo) {
		has_flag = false;
		portador_instancia = noone;
		velocidad_caida = 0;
	}

	if (global.myTeam == "AZUL") global.bandera_roja_robada = false;
	else global.bandera_azul_robada = false;

	var flag_scored = (global.myTeam == "AZUL") ? "ROJA" : "AZUL";

	if (oBrain.AmIPseudoHost) {
		if (global.myTeam == "AZUL") {
			global.puntos_azul++;
			with(oBrain) { marcador_escala_azul = 3; marcador_shake = 15; }
		} else {
			global.puntos_rojo++;
			with(oBrain) { marcador_escala_rojo = 3; marcador_shake = 15; }
		}

		has_flag = false;
		score_pending = false;

		if (flag_scored == "ROJA") {
			with (oFlag) { x = spawnX; y = spawnY; velocidad_caida = 0; has_flag = false; portador_instancia = noone; }
		} else {
			with (oFlag2) { x = spawnX; y = spawnY; velocidad_caida = 0; has_flag = false; portador_instancia = noone; }
		}

		with(oOtherPlayer) {
			SendEventToClient(clientId, "sync_score", {
				azul: global.puntos_azul,
				rojo: global.puntos_rojo,
				resetFlag: flag_scored,
				nombre: global.myName   // opcional: para mostrar quien anoto (las versiones viejas lo ignoran)
			});
		}

		score_pending = false;
		fb_anotacion(global.myTeam, global.myName);   // C2: franja de anotacion (scr_feedback)
	}
	else {
		with(oOtherPlayer) {
			SendEventToClient(clientId, "request_point", {
				team: (global.myTeam == "AZUL") ? "AZUL" : "ROJA",
				resetFlag: flag_scored,
				nombre: global.myName   // opcional
			});
		}
	}
}

var miBandera = (global.myTeam == "AZUL") ? oFlag2 : oFlag;

if (!score_pending && place_meeting(x, y, miBandera) && !miBandera.has_flag && (miBandera.x != miBandera.spawnX))
{
	// En sala privada no se suma nada (es partida entre amigos)
	if (!scr_fin_es_privada()) {
		global.flags_returned += 1;
		scr_xp_dar(5);    // devolver tu bandera (scr_reloj)

		with(oBrain) {
			save_state = "prepare";
			save_timer = room_speed;
		}
	}

	score_pending = true;

	if (oBrain.AmIPseudoHost) {
		with(miBandera) { x = spawnX; y = spawnY; }

		fb_toast("BANDERA DEVUELTA", "Salvaste tu bandera", fb_team_col(global.myTeam));

		with(oOtherPlayer) {
			SendEventToClient(clientId, "sync_score", {
				azul: global.puntos_azul,
				rojo: global.puntos_rojo,
				resetFlag: (global.myTeam == "AZUL") ? "AZUL" : "ROJA",
				reason: "RETORNO",
				nombre: global.myName   // opcional
			});
		}
		score_pending = false;
	}
	else {
		with(oOtherPlayer) {
			SendEventToClient(clientId, "request_point", {
				team: "SISTEMA",
				resetFlag: (global.myTeam == "AZUL") ? "AZUL" : "ROJA",
				nombre: global.myName   // opcional
			});
		}
	}
}

if (invul_timer > 0) {
	invul_timer--;
	invulnerable = true;
	image_alpha = 0.5;
} else {
	if (!isDead) {
		invulnerable = false;
		image_alpha = 1;
	}
}

global.sharedProperties = {
	_x : x,
	_y : y,
	_A : image_angle,
	_H : health,
	_IA: image_alpha,
	_IMYS: image_yscale,
	_IMXS: image_xscale,
	_ST: state,
	_SI: sprite_index,
	_II: (state == PLAYERSTATE.DEAD) ? -1 : image_index,
	_IS: image_speed,
	_BS: bullet_created,
	_KILLS: kills,
	_VIS: visible,
	_HF: has_flag,
	_EF: scr_efx_codigo(),   // efecto que traes encima (scr_armas)
	_WT: (guns[weapon.index] != noone) ? scr_arma_tinte(guns[weapon.index]) : c_white,
	_INV: invulnerable || scr_hab_esquivando(),   // en el impulso las balas tampoco le pegan
	_NAME: playerName,
	_ANG: weapon.angle,
	_WSI: (guns[weapon.index] != noone) ? guns[weapon.index].sprite : 0,
	_AMMO: (guns[weapon.index] != noone) ? guns[weapon.index].ammo : 0,
	_ATYPE: (guns[weapon.index] != noone) ? guns[weapon.index].ammoType : "",
	_REL: reloading,
	_RK: recoil_kick,
	_RA: recoil_angle,
	_MELEE: melee_active,
	_TEAM: team,
	_SH: has_shield,
	_MH: max_health,
	// Habilidad para que los demás la vean (scr_personajes)
	_HCO: (hab_cor_t > 0),
	_HDA: (hab_dash_vis > 0),
	_HGF: hab_g_fase,
	_HGX: round(hab_g_x),
	_HGY: round(hab_g_y)
};

// El nivel ahora sube en scr_xp_dar y la pantalla sale al salir de la partida (scr_reloj)
if (false)
{
	global.lvl += 1;
	global.xp -= 100;

	fb_toast("SUBISTE AL NIVEL " + string(global.lvl) + "!", "", FB_ORO);

	ini_open("data.ini");
	ini_write_real("user", "lvl", global.lvl);
	ini_write_real("user", "xp", global.xp);
	ini_close();

	if (global.sfx) audio_play_sound(snd_levelup, 1, false);
}