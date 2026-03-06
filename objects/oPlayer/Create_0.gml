//Player speed
speed = 0
direction = 0
//health = 100
playerName = global.myName; // tu nombre local

// Esperamos un milisegundo a que el equipo esté asignado
// Estados del jugador
enum PLAYERSTATE {
    IDLE,
    WALK,
    JUMP,
    SHOT,
    HIT,
    DEAD,
	INTRO
}
// IE2ZCP
state = PLAYERSTATE.INTRO;
can_sfx=false;
push_h=0;
//ARMAS - 1 a la ves
guns = [noone];
t2=0
weapon = {
    index: 0,
    angle: 0,
    frequency: 0
};

reserve = {
    gun: 0,
    smg: 0,
    escop: 0,
    shell: 0
};

granadas = 0; // Cantidad inicial

reloading = false;
reload_timer = 0;

//Aviso de recarga
reload_max = 0; // duración total de la recarga (frames)

melee_cd = 0;
melee_active = 0;   // frames que el hitbox está activo
melee_damage = 20;  // ajusta

// Física
hsp = 0;
vsp = 0;
grv = 0.5;
walksp = 3;
jumpsp = -13;
move=0;
// --- SPEED BOOST ---
walksp_base = 3;   // guarda la velocidad original
walksp_mult = 1;        // multiplicador (1 = normal)
speed_timer = 0;

invulnerable = false;
invul_timer = 0;
// Control de disparo
bullet_created = false;
isDead = false;
kills=0;
ak_recoil = 0;
ak_recoil_relax = 0;

recoil_kick = 0;      // cuánto empuja el arma hacia atrás
recoil_angle = 0;     // pequeño “kick” angular
recoil_x = 0; recoil_y = 0;

//sonido
empty_cd = 0; // cooldown sonido sin balas



// --- LÓGICA DE EQUIPOS ESTILO BRAWL STARS ---
// El clientId 0 es el Host, el 1 es el primer cliente, etc.
// Dividimos: IDs pares vs IDs impares
if (global.clientId % 2 == 0) {
    global.myTeam = "AZUL";
    global.enemyTeam = "ROJO";
} else {
    global.myTeam = "ROJO";
    global.enemyTeam = "AZUL";
}

team = global.myTeam; // Tu equipo local

spawn_x = x;
spawn_y = y;

has_flag=false;
image_xscale=1.5;
image_yscale=1.5;

my_team = TEAM.NONE;   // Asignar en la sala
tiene_bandera = false; // Al principio nadie tiene la bandera
score_pending = false;


network_tick = 0;
respawn_lock = 0;
spawn_lock = 10;
spawn_left_x  = 51;
spawn_right_x = 591;
spawn_y_fixed = 400;

crush_cd = 0;
death_reason = "pvp";      // "pvp" o "crush"
last_killer  = "";         // nombre del que te mató (para PVP)
is_grounded = false;
damage_alpha = 0; // Controla la transparencia del flash rojo


// Power-ups
has_shield = false;
damage_boost = 1;    // 1 es normal, 2 es doble daño
infinite_ammo = false;

// Timers (para que duren, por ejemplo, 10 segundos)
shield_timer = 0;
damage_timer = 0;
ammo_timer = 0;
emote_cd = 0; // Timer para el cooldown de emotes




// 0: Asalto, 1: Tanque, 2: Medico, 3: (Nuevo Personaje, ej: Scout o Sniper)
anims[0] = { idle: spr_player_idle, walk: spr_player_walk, jump: spr_player_walk, dead: spr_player_dead, hit: spr_player_hit };
anims[1] = { idle: spr_player2_idle, walk: spr_player2_walk, jump: spr_player2_walk, dead: spr_player2_dead, hit: spr_player2_hit };
anims[2] = { idle: spr_player3_idle, walk: spr_player3_walk, jump: spr_player3_walk, dead: spr_player3_dead, hit: spr_player3_hit };
anims[3] = { idle: spr_player4_idle,  walk: spr_player4_walk,  jump: spr_player4_walk,  dead: spr_player4_dead, hit: spr_player4_hit }; // <-- EL CUARTO

// Usamos la variable global que viene de la pantalla de selección
mi_clase = global.pj_selected; 



// Ajuste de estadísticas físicas para los 4
switch(mi_clase) {
    case 0: // ASALTO (Equilibrado)
        walksp_base = 3;   
        health = 100; 
        jumpsp = -13; 
        break; 

    case 1: // TANQUE (Lento y pesado, salta poco)
        walksp_base = 2.5; 
        health = 200; 
        jumpsp = -12; // Salto más bajo por el peso
        break; 

    case 2: // MEDICO (Ágil para rescates)
        walksp_base = 3.5; 
        health = 120; 
        jumpsp = -12.5; // Salto ligeramente superior
        break;

    case 3: // SCOUT (Muy rápido y atlético)
        walksp_base = 4.0; 
        health = 80;  
        jumpsp = -14;  // ¡Gran salto para atajos!
        break; 
}

// Inicializar la vida máxima según lo que se asignó arriba
max_health = health;
vida_visual = health;
escudo_visual = shield_timer; 