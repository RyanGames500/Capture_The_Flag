/* A demo implementation of Rocket Networking
//ConnectToServer()

//Player speed
speed = 0
direction = 0
health = 100

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

// Física
hsp = 0;
vsp = 0;
grv = 0.5;
walksp = 4;
jumpsp = -13;
move=0;

// Control de disparo
bullet_created = false;

isDead = false;
kills=0;


if (oBrain.AmIPseudoHost) {
    team = "blue";
    image_blend = c_blue;
} else {
    team = "red";
    image_blend = c_red;
}

image_xscale=1.5;
image_yscale=1.5;

has_flag = false;