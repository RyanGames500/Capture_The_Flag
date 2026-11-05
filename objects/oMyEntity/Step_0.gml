entityProperties = {
	_entityId : entityId,
	_type     : tipo,
	_x        : x,
	_y        : y,
	_A        : direction,
	_IMXS     : image_xscale,
	_IMYS     : image_yscale,
	_SI       : sprite_index,
	_IR       : is_rocket,
	_IA       : image_angle,
	_IB       : is_box,
	_XB       : (is_box && instance_exists(owner)) ? owner.x : x,
	_YB       : (is_box && instance_exists(owner)) ? owner.y - 13 : y
};

if (variable_instance_exists(id, "is_box") && is_box)
{
	if (!instance_exists(owner)) { instance_destroy(); exit; }

	var x_base = owner.x;
	var y_base = owner.y - 13;
	image_angle = direction;

	distancia += velocidad * estado;

	if (distancia >= distancia_max) estado = -1;
	if (distancia <= 0 && estado == -1) { instance_destroy(); exit; }

	x = x_base + lengthdir_x(distancia, image_angle);
	y = y_base + lengthdir_y(distancia, image_angle);
}

// Cohete del RPG: sale lento y acelera (scr_armas)
if (variable_instance_exists(id, "acel") && acel > 0) speed = min(speed * acel, vel_max);

if (!variable_instance_exists(id, "is_box") || !is_box) {
	if (life > 0) {
		life--;
		if (life <= 0) instance_destroy();
	}
}

// Balas rápidas: reviso también el tramo que van a recorrer este frame,
// así no atraviesan un muro, una plataforma o a un rival sin pegar (scr_mira)
var _barrido = (speed > 0) && !(variable_instance_exists(id, "is_box") && is_box) && !(variable_instance_exists(id, "is_granada") && is_granada);
var _cruza_muro = _barrido && scr_bala_cruza_muro(x, y, x + hspeed, y + vspeed);

if (place_meeting(x, y, obj_wall) || place_meeting(x, y, oPlataformaPasable) || _cruza_muro)
{
	if (!(variable_instance_exists(id, "is_box") && is_box) && !is_rocket) fx_impact_net(x, y, direction + 180, 6, false);

	if (variable_instance_exists(id, "is_box") && is_box) {
		if (estado == 1) {
			estado = -1;
			if (global.sfx) audio_play_sound(snd_empy, 10, false, 0.5);
		}
	}
	else {
		if (is_rocket && !exploded) {
			exploded = true;
			instance_create_layer(x, y, "Weapons", oExplosionFX);
			if (global.sfx) audio_play_sound(snd_pearl_explodes, 10, false);
			scrCamShake(15);

			if (global.ONLINE) {
				if (oBrain.AmIPseudoHost) {
					with(oOtherPlayer) { SendEventToClient(clientId, "fx_pearl_explosion", { ex: other.x, ey: other.y, isNade: false }); }
				} else {
					var _targetHost = scr_get_host_id();
					if (_targetHost != -1) SendEventToClient(_targetHost, "request_rocket_explosion", { ex: x, ey: y });
				}
			}
		}
		instance_destroy();
	}
}

var target_enemy = instance_place(x, y, oOtherPlayer);
if (target_enemy == noone && _barrido && !_cruza_muro) target_enemy = scr_bala_rival_en_tramo(x, y, x + hspeed, y + vspeed);

if (target_enemy != noone)
{
	if (variable_instance_exists(target_enemy, "team") && target_enemy.team != global.myTeam)
	{
		if (variable_instance_exists(id, "is_box") && is_box) {
			if (ds_list_find_index(hit_list, target_enemy) != -1) exit;
		}
		// Bala que atraviesa (antimaterial): no le pega dos veces al mismo
		if (variable_instance_exists(id, "atraviesa") && ds_list_find_index(hit_list, target_enemy) != -1) exit;

		if (target_enemy.has_shield)
		{
			instance_create_layer(x, y, "Instances", oShieldSparkFX);
			if (global.sfx) audio_play_sound(snd_shield_impact, 20, false, 2.0);
			if (global.ONLINE) {
				with(oOtherPlayer) { SendEventToClient(clientId, "fx_shield_hit", { ex: other.x, ey: other.y }); }
			}

			if (variable_instance_exists(id, "is_box") && is_box) {
				estado = -1; exit;
			} else {
				instance_destroy(); exit;
			}
		}

		if (target_enemy.invulnerable) exit;

		with (target_enemy) {
			if (state != PLAYERSTATE.DEAD) {
				hit_bloqueo_timer = (variable_instance_exists(other, "is_box") && other.is_box) ? 20 : 10;
				state = PLAYERSTATE.HIT;
				image_index = 0;

				if (variable_instance_exists(other, "is_box") && other.is_box) {
					push_h = lengthdir_x(25, other.image_angle);
					vsp = -7;
				}
			}
		}

		if (is_rocket) {
			scrCreateRocketExplosion(x, y, false);
			if (global.ONLINE) {
				if (oBrain.AmIPseudoHost) {
					with(oOtherPlayer) { SendEventToClient(clientId, "fx_pearl_explosion", { ex: other.x, ey: other.y, isNade: false }); }
				} else {
					var _targetHost = scr_get_host_id();
					if (_targetHost != -1) SendEventToClient(_targetHost, "request_fx_explosion", { ex: x, ey: y, isNade: false });
				}
			}
		}

		if (global.sfx) audio_play_sound(snd_hit, 20, false, 1.1);

		if (global.ONLINE) {
			var _reason = (variable_instance_exists(id, "is_box") && is_box) ? "boxeo" : "pvp";
			var _dir_golpe = point_direction(x, y, target_enemy.x, target_enemy.y);

			var _alto = target_enemy.bbox_bottom - target_enemy.bbox_top;
			var _head = (!is_rocket && _reason == "pvp" && y < target_enemy.bbox_top + _alto * 0.28);
			if (_head) damage = round(damage * FX_HEADSHOT_MULT);

			// Con coraza el que recibe solo pierde la mitad: así lo muestro yo también (scr_personajes)
			var _dmg_ver = (variable_instance_exists(target_enemy, "hab_co") && target_enemy.hab_co) ? round(damage * HAB_CORAZA_DANO) : damage;
			fx_damage_number(target_enemy.x, target_enemy.bbox_top - 8, _dmg_ver, is_rocket ? 2 : (_head ? 1 : 0));
			fx_impact_net(x, y, direction + 180, is_rocket ? 4 : 8, is_rocket);

			scr_predict_hit(target_enemy, _dmg_ver, (_reason == "boxeo") ? 20 : 10);
			if (_reason == "boxeo") scr_predict_push(target_enemy, _dir_golpe);
			scr_hit_confirm(target_enemy, _head, _reason == "boxeo");
			SendEventToClient(target_enemy.clientId, "hit", { damage: damage, killer: global.myName, reason: _reason, angle: _dir_golpe });
		}

		if (variable_instance_exists(id, "is_box") && is_box) {
			ds_list_add(hit_list, target_enemy);
			estado = -1;
		} else if (variable_instance_exists(id, "atraviesa") && atraviesa > 1) {
			atraviesa -= 1;              // sigue de largo al siguiente rival
			ds_list_add(hit_list, target_enemy);
		} else {
			instance_destroy();
		}
	}
}

if (is_rocket) {
	if (irandom(2) == 0) {
		var sm = instance_create_layer(x, y, "Instances", oSmokeTrail);
		sm.color = c_gray;
	}
	image_angle = direction;
}

if (variable_instance_exists(id, "is_granada") && is_granada) {
	if (!variable_instance_exists(id, "vsp")) vsp = 0;
	if (!variable_instance_exists(id, "hsp")) hsp = 0;

	vsp += 0.22;
	image_angle -= hsp * 5;

	var target_enemy_nad = instance_place(x + hsp, y + vsp, oOtherPlayer);
	if (target_enemy_nad != noone) {
		if (variable_instance_exists(target_enemy_nad, "team") && target_enemy_nad.team == global.myTeam) target_enemy_nad = noone;
	}

	var hit_wall = place_meeting(x + hsp, y + vsp, obj_wall);
	var hit_platform = false;
	var platform_id = instance_place(x, y + vsp, oPlataformaPasable);
	if (platform_id != noone && vsp > 0) hit_platform = true;

	if (target_enemy_nad != noone || hit_wall || hit_platform) {
		scrCreateRocketExplosion(x, y, true);
		if (global.sfx) audio_play_sound(snd_hit, 20, false, 1.1);

		if (target_enemy_nad != noone && !target_enemy_nad.invulnerable) {
			if (global.ONLINE) {
				fx_damage_number(target_enemy_nad.x, target_enemy_nad.bbox_top - 8, damage, 2);
				scr_predict_hit(target_enemy_nad, damage, 10);
				scr_hit_confirm(target_enemy_nad, false, false);
				SendEventToClient(target_enemy_nad.clientId, "hit", { damage: damage, killer: global.myName, reason: "granada" });
			}
		}

		if (global.ONLINE) {
			if (oBrain.AmIPseudoHost) {
				with(oOtherPlayer) { SendEventToClient(clientId, "fx_pearl_explosion", { ex: other.x, ey: other.y, isNade: true }); }
			} else {
				var _targetHost = scr_get_host_id();
				if (_targetHost != -1) SendEventToClient(_targetHost, "request_fx_explosion", { ex: x, ey: y, isNade: true });
			}
		}

		instance_destroy();
		exit;
	}
	x += hsp;
	y += vsp;
}