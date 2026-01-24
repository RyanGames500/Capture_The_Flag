//Player speed
speed = 0
direction = 0
health = 100

// Estados del jugador
enum PLAYER {
    IDLE,
    WALK,
    JUMP,
    SHOT,
    HIT,
    DEAD
}

state = PLAYER.IDLE;

// Física
hsp = 0;
vsp = 0;
grv = 0.6;
walksp = 4;
jumpsp = -13;
move=0;
invulnerable = false;
// Control de disparo
bullet_created = false;
isDead = false;
kills=0;


spawn_x = x;
spawn_y = y;

has_flag=false;
image_xscale=1.5;
image_yscale=1.5;

my_team = TEAM.NONE;   // Asignar en la sala
tiene_bandera = false; // Al principio nadie tiene la bandera