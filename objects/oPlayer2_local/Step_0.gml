// 1. Obtener Entradas
key_left  = keyboard_check(ord("A"));
key_right = keyboard_check(ord("D"));
key_jump  = keyboard_check_pressed(ord("W"));
key_shot  =keyboard_check_pressed(ord("J"));

// 2. Aplicar Gravedad (Aplica para casi todos los estados)
if (state != PLAYER2.DEAD) {
    vsp += grv;
}

// 3. Máquina de Estados
switch (state) {
    case PLAYER2.IDLE:
        hsp = 0;
        sprite_index = spr_player_idle;
        if (key_jump && place_meeting(x, y + 1, obj_wall)) { vsp = jumpsp; state = PLAYER2.JUMP; }
        if (key_right || key_left) state = PLAYER2.WALK;
        if (key_shot) { state = PLAYER2.SHOT; image_index = 0; bullet_created = false; }
        break;

    case PLAYER2.WALK:
		// Modifica la línea de hsp dentro de PLAYERSTATE.WALK:
		var _current_speed = has_flag ? walksp * 0.7 : walksp; // 30% más lento si tiene la bandera
		hsp = move * _current_speed;
        move = key_right - key_left;
        sprite_index = spr_player_walk;
        if (hsp != 0) image_xscale = sign(hsp) * 1.5;
        
        if (hsp == 0) state = PLAYER2.IDLE;
        if (key_jump && place_meeting(x, y + 1, obj_wall)) { vsp = jumpsp; state = PLAYER2.JUMP; }
        if (key_shot) { state = PLAYER2.SHOT; image_index = 0; bullet_created = false; }
        break;

    case PLAYER2.JUMP:
        move = key_right - key_left;
        hsp = move * walksp;
        if (hsp != 0) image_xscale = sign(hsp) * 1.5;
        // Aquí podrías poner sprite_index de salto
        if (place_meeting(x, y + 1, obj_wall)) state = PLAYER2.IDLE;
        break;

    case PLAYER2.SHOT:
        hsp = 0; // Se detiene para disparar
        sprite_index = spr_player_shot;
        image_speed = 0.8; // Velocidad controlada
        
        // Crear bala en Frame 1
        if (floor(image_index) == 1 && !bullet_created) 
		{
            var inst = instance_create_layer(x + (23 * sign(image_xscale)), y - 12, "Instances", oPlayer_bullet);
				inst.speed = 10;
				inst.sprite_index = sprMissile;
                inst.direction = (other.image_xscale > 0) ? 0 : 180;
                inst.image_xscale = other.image_xscale;
				bullet_created = true;		
        }
        
        // Volver a Idle al terminar
        if (image_index >= image_number - 1) {
            state = PLAYER2.IDLE;
            image_speed = 1;
        }
        break;

    case PLAYER2.HIT:
        // Lógica de recibir daño (ej: un pequeño salto hacia atrás)
        sprite_index = spr_player_hit;
        if (image_index >= image_number - 1) state = PLAYER2.IDLE;
        break;

		case PLAYER2.DEAD:
        hsp = 0;
	// --- SOLTAR LA ENTIDAD TIPO FLAG ---
        
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

if health2 <= 0 and isDead = false
{
	isDead=true
	state = PLAYER2.DEAD;	
	
	alarm[0] = 120;
}

if (state == PLAYER.DEAD && has_flag == true) 
{
    // 1. El jugador ya no tiene la bandera
    has_flag = false;
    
    // 2. Le avisamos a la bandera que ya es libre
    // Usamos 'with' para asegurarnos de que cambie en el objeto bandera
    with (oFlag2) 
    {
        has_flag = false;
        // Opcional: le damos un empujoncito hacia arriba para que la caída se vea mejor
        velocidad_caida = -5; 
    }
}


// --- COLISIÓN CON BANDERA ENEMIGA (Para capturarla) ---
if (place_meeting(x, y, oFlag2) && state != PLAYER.DEAD) 
{
    has_flag = true;
    with (oFlag2) {
        has_flag = true;
    }
}

// --- COLISIÓN CON BANDERA ALIADA (Para devolverla) ---
if (place_meeting(x, y, oFlag) && state != PLAYER.DEAD) 
{
    // Solo se devuelve si cumple DOS condiciones:
    // 1. Está fuera de su base (x != spawnX)
    // 2. NADIE la tiene cargada (oFlag.has_flag == false)
    if (oFlag.x != oFlag.spawnX && oFlag.has_flag == false) 
    {
        with (oFlag) 
        {
            x = spawnX;
            y = spawnY;
            velocidad_caida = 0; 
            // has_flag ya es false, así que no hace falta cambiarlo
        }
        // ¡Sonido de bandera recuperada!
    }
}