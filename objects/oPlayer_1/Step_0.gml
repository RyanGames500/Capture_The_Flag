/* 1. Obtener Entradas
key_left  = keyboard_check(vk_left) || keyboard_check(ord("A"));
key_right = keyboard_check(vk_right) || keyboard_check(ord("D"));
key_jump  = keyboard_check_pressed(vk_space) || keyboard_check_pressed(ord("W"));
key_shot  = keyboard_check_pressed(ord("Z")) || keyboard_check_pressed(ord("J"));

// 2. Aplicar Gravedad (Aplica para casi todos los estados)
if (state != PLAYERSTATE.DEAD) {
    vsp += grv;
}

// 3. Máquina de Estados
switch (state) {
    case PLAYERSTATE.IDLE:
        hsp = 0;
        sprite_index = spr_player_idle;
        if (key_jump && place_meeting(x, y + 1, obj_wall)) { vsp = jumpsp; state = PLAYERSTATE.JUMP; }
        if (key_right || key_left) state = PLAYERSTATE.WALK;
        if (key_shot) { state = PLAYERSTATE.SHOT; image_index = 0; bullet_created = false; }
        break;

    case PLAYERSTATE.WALK:
		// Modifica la línea de hsp dentro de PLAYERSTATE.WALK:
		var _current_speed = has_flag ? walksp * 0.7 : walksp; // 30% más lento si tiene la bandera
		hsp = move * _current_speed;
        move = key_right - key_left;
        sprite_index = spr_player_walk;
        if (hsp != 0) image_xscale = sign(hsp) * 1.5;
        
        if (hsp == 0) state = PLAYERSTATE.IDLE;
        if (key_jump && place_meeting(x, y + 1, obj_wall)) { vsp = jumpsp; state = PLAYERSTATE.JUMP; }
        if (key_shot) { state = PLAYERSTATE.SHOT; image_index = 0; bullet_created = false; }
        break;

    case PLAYERSTATE.JUMP:
        move = key_right - key_left;
        hsp = move * walksp;
        if (hsp != 0) image_xscale = sign(hsp) * 1.5;
        // Aquí podrías poner sprite_index de salto
        if (place_meeting(x, y + 1, obj_wall)) state = PLAYERSTATE.IDLE;
        break;

    case PLAYERSTATE.SHOT:
        hsp = 0; // Se detiene para disparar
        sprite_index = spr_player_shot;
        image_speed = 0.8; // Velocidad controlada
        
        // Crear bala en Frame 1
        if (floor(image_index) == 1 && !bullet_created) {
            var inst = instance_create_layer(x + (20 * sign(image_xscale)), y - 14, "Instances", oMyEntity);
				inst.speed = 10;
				inst.sprite_index = sprMissile;
                inst.direction = (other.image_xscale > 0) ? 0 : 180;
                inst.image_xscale = other.image_xscale;
				inst.type1 = "bullet";
				bullet_created = true;
        }
        
        // Volver a Idle al terminar
        if (image_index >= image_number - 1) {
            state = PLAYERSTATE.IDLE;
            image_speed = 1;
        }
        break;

    case PLAYERSTATE.HIT:
        // Lógica de recibir daño (ej: un pequeño salto hacia atrás)
        sprite_index = spr_player_hit;
        if (image_index >= image_number - 1) state = PLAYERSTATE.IDLE;
        break;

		case PLAYERSTATE.DEAD:
        hsp = 0;
// --- SOLTAR LA ENTIDAD TIPO FLAG ---
    if (has_flag) {
        has_flag = false;
        
 
    }
        
        sprite_index = spr_player_dead;
        if (image_index >= image_number - 1) visible=false;
        break;
}

// 4. Colisiones (El código que ya teníamos)
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

if health <= 0 and isDead = false
{
	isDead=true
	state = PLAYERSTATE.DEAD;	
}

if (state == PLAYERSTATE.DEAD && has_flag == true) {
    has_flag = false;
    // Creamos un struct con la info de la caída
    var dropData = {
        fx: x,
        fy: y,
        team_flag: "red" // o la que lleves
    };
    
    // Lo enviamos a todos (puedes usar un loop para enviar a todos los clientId que conoces)
    // O mejor aún, deja que el PseudoHost detecte el cambio en tu sharedProperties._HF
}

global.sharedProperties = {
    _x : x,
    _y : y,
    _A : image_angle,
    _H : health,
    _IMYS: image_yscale,
    _IMXS: image_xscale,
    _ST: state,
    _SI: sprite_index,
    _II: image_index,
    _IS: image_speed,
    _TEAM: team,
    _BS: bullet_created, // Para que los otros "vean" cuando sale la bala de tu arma
	_KILLS: kills,
	_VIS: visible,
	_HF: has_flag
}

