// --- Dentro de tu Alarma 1 ---
x = spawn_x;
y = spawn_y;
health = 100;
isDead = false;
state = PLAYERSTATE.IDLE;
visible = true;

// Activamos el timer para que sea invulnerable 3 segundos MÁS después de aparecer
invul_timer = 180; 
invulnerable = true; 

image_speed = 1; 
image_index = 0;
image_alpha = 0.5; // Ponlo un poco transparente para que sepa que es invulnerable