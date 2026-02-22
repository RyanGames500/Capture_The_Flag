// --- DATOS BÁSICOS ---
speed = 0;
direction = 0;
health = 100;
playerName = global.myName; 

// --- ESTADOS ---
enum PLAYERSTATE2 {
    IDLE,
    WALK,
    JUMP,
    SHOT,
    HIT,
    DEAD,
    INTRO
}
state = PLAYERSTATE2.IDLE; // Iniciamos en IDLE directamente en local

// --- SISTEMA DE ARMAS ---
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

granadas = 0;
reloading = false;
reload_timer = 0;
reload_max = 0;

// --- MELEE ---
melee_cd = 0;
melee_active = 0;
melee_damage = 20;

// --- FÍSICA ---
hsp = 0;
vsp = 0;
grv = 0.5;
walksp_base = 3;
walksp = 3;
walksp_mult = 1;
jumpsp = -13;
move = 0;
speed_timer = 0;
is_grounded = false;

// --- COMBATE Y RECOIL ---
invulnerable = false;
invul_timer = 0;
bullet_created = false;
isDead = false;
kills = 0;
ak_recoil = 0;
recoil_kick = 0;
recoil_angle = 0;
recoil_x = 0; 
recoil_y = 0;
empty_cd = 0;
damage_alpha = 0;

// --- LÓGICA DE EQUIPO (Modo Local) ---
// En offline, tú eliges tu equipo. Por defecto te pongo AZUL.
// Puedes cambiar esto desde el menú de "Modo Práctica"
if (!variable_global_exists("myTeam")) global.myTeam = "AZUL"; 

team = global.myTeam; 
global.enemyTeam = (team == "AZUL") ? "ROJO" : "AZUL";

// --- POSICIONAMIENTO ---
spawn_x = x;
spawn_y = y;

// --- LÓGICA DE BANDERA ---
has_flag = false;
score_pending = false;
image_xscale = 1.5;
image_yscale = 1.5;

// --- POWER-UPS ---
has_shield = false;
damage_boost = 1;
infinite_ammo = false;
shield_timer = 0;
damage_timer = 0;
ammo_timer = 0;
shield_alpha_hud = 1;

// --- OTROS ---
emote_cd = 0;
crush_cd = 0;
death_reason = "pvp";
last_killer = "";
is_bot = false;