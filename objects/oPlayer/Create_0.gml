//Player speed
speed = 0
direction = 0
health = 100
// Esperamos un milisegundo a que el equipo esté asignado
// Estados del jugador
enum PLAYERSTATE {
    IDLE,
    WALK,
    JUMP,
    SHOT,
    HIT,
    DEAD
}

state = PLAYERSTATE.IDLE;

//ARMAS - 1 a la ves
guns = [noone];

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
walksp = 4;
jumpsp = -13;
move=0;
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



if (oBrain.AmIPseudoHost) {
    global.myTeam = "AZUL";
    global.enemyTeam = "ROJO";
} else {
    global.myTeam = "ROJO";
    global.enemyTeam = "AZUL";
}

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


