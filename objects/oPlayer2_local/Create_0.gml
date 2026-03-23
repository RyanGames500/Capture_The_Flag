// --- DATOS BÁSICOS ---
speed = 0;
direction = 0;
playerName = "BOT1"; 

// --- ESTADOS ---
enum PLAYER2 {
    IDLE,
    WALK,
    JUMP,
    SHOT,
    HIT,
    DEAD,
    INTRO
}
state = PLAYER2.IDLE; // Iniciamos en IDLE directamente en local

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
can_sfx=false;
push_h=0;
current_node = noone;
target_node  = noone;
path_node    = noone;
granadas = 0;
reloading = false;
reload_timer = 0;
reload_max = 0;

// --- MELEE ---
melee_cd = 0;
melee_active = 0;
melee_damage = 20;
mi_guante = noone;
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
hp=100;
max_hp=100;
hit=false;
hit_time=5;
old_hp = hp; // O usa health si es la variable que definiste
timer_esquive_techo = 0;
dir_esquive = 1;
stuck_timer = 0;
last_x = x;
puedo_saltar_timer = 0;
escape_offset_y = 0;
escape_timer = 0;
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
esquivando_timer = 0;
direccion_esquive = 1;
lanzar_granada_timer = 0; // Para que no las tire todas juntas

// --- LÓGICA DE EQUIPO (Modo Local) ---
// En offline, tú eliges tu equipo. Por defecto te pongo AZUL.
// Puedes cambiar esto desde el menú de "Modo Práctica"

team = "ROJO"; 
global.enemyTeam = (team == "ROJO") ? "AZUL" : "ROJO";

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

ai_state = "CHASE";

is_bot = true;
key_shoot = false;
// --- Dificultad (1: Fácil, 2: Normal, 3: Difícil) ---
dificultad = 1; 

// --- Variables de control ---
puedo_disparar_ia = true;
timer_rafaga = 0;
espera_entre_rafagas = 0;
hp = 100; // O la vida que uses
hp_max = 100;
estado_animo = "normal"; // "atacar", "huir", "objetivo"
// Referencias
if (team == "ROJO") {
    mi_base = instance_find(obj_base_red, 0);
    mi_bandera_propia = instance_find(oFlag, 0);
    bandera_enemiga = instance_find(oFlag2, 0);
}
else {
    mi_base = instance_find(obj_base_blue, 0);
    mi_bandera_propia = instance_find(oFlag2, 0);
    bandera_enemiga = instance_find(oFlag, 0);
}