// Este código se ejecuta cuando pasan los 2 segundos
x = spawn_x;
y = spawn_y;
health = 100;      // Le devolvemos la vida
is_dead = false;
state = PLAYER.IDLE;
visible = true;    // Por si lo habías hecho invisible al morir
image_alpha = 1;   // Por si estaba transparente
isDead=false;
invulnerable = true;
alarm[1] = 90; // 1.5 segundos de protección