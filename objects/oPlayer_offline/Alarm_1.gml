// 1. POSICIONAMIENTO
// En local, simplemente regresamos al spawn original del mapa
x = spawn_x;
y = spawn_y;

// 2. RESETEAR ESTADO FÍSICO Y SALUD
health = variable_instance_exists(id, "max_health") ? max_health : 100;
if (variable_instance_exists(id, "hab_cd")) { scr_hab_reset(); hab_hp_prev = health; }
isDead = false;
state = PLAYERSTATE2.IDLE;
visible = true;

// 3. RESETEAR ARMAS
// Al morir en este juego, pierdes lo que llevabas y vuelves a empezar
for (var i = 0; i < array_length(guns); i++) {
    guns[i] = noone;
}

// 4. INVULNERABILIDAD POST-RESPAWN
// 180 frames = 3 segundos de protección para que no te maten apenas apareces
invul_timer = 180; 
invulnerable = true; 

// 5. EFECTOS VISUALES
image_speed = 1; 
image_index = 0;
image_alpha = 0.5; // Transparencia para indicar invulnerabilidad

// 6. LIMPIEZA DE BANDERAS (Seguridad extra)
has_flag = false;
score_pending = false;

// 7. RESET DE POWER-UPS (Opcional, si quieres que al morir pierda todo)
has_shield = false;
shield_timer = 0;
damage_boost = 1;
damage_timer = 0;