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
    INTRO,
	GRAPPLE
}
state = PLAYERSTATE2.IDLE; // Iniciamos en IDLE directamente en local
can_sfx=false;

push_h = 0; // Fuerza de retroceso acumulada

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
global.myTeam = "AZUL"; 

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

vida_visual = health;
escudo_visual = shield_timer;


// --- SISTEMA DE ARPÓN ---
grapple_active = false;      // ¿Estamos colgados?
grapple_x = 0;               // Punto X donde pegó el gancho
grapple_y = 0;               // Punto Y donde pegó el gancho
grapple_force = 1.2;         // La fuerza con la que te jala (aceleración)
grapple_speed_max = 14;      // Velocidad máxima permitida al estar colgado
grapple_target = noone;
grapple_type = ""; // "PARED" o "ENEMIGO"
grapple_pull_speed = 12; // Velocidad con la que el enemigo viene hacia ti
grapple_timer = 0;
grapple_anim_dist = 0;    // Qué tanto se ha extendido el cable visualmente
grapple_hitting = false;  // ¿Ya llegó al objetivo?


// --- NUEVAS PARA LANZAMIENTO LINEAL ---
grapple_max_dist = 250;     // Alcance máximo del cable
grapple_anim_dist = 0;      // Extensión actual visual
grapple_speed_ext = 20;     // Velocidad de vuelo del gancho (¡Ajústalo!)
grapple_hitting = false;    // ¿Ya impactó algo?
grapple_dir = 0;            // Dirección fija del disparo
grapple_is_returning = false; // ¿Se está devolviendo porque no pegó a nada?