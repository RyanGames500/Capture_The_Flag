
if (global.ONLINE) {
    if (oBrain.AmIPseudoHost) x = spawn_left_x; else x = spawn_right_x;
    y = spawn_y_fixed;

    // alinear red si existe
    if (variable_instance_exists(id, "latest_x")) latest_x = x;
    if (variable_instance_exists(id, "latest_y")) latest_y = y;

    // 🔥 IMPORTANTÍSIMO: forzar unos frames
    respawn_lock = 10;
} else {
    x = spawn_x;
    y = spawn_y;
}

// 2. Resetear armas
for (var i = 0; i < array_length(guns); i++) {
    guns[i] = noone;
}
switch(mi_clase) {
        case 0: health = 100; break;
        case 1: health = 200; break;
        case 2: health = 120; break;
        case 3: health = 80;  break;
    }
isDead = false;
state = PLAYERSTATE.IDLE;
visible = true;
t2=0;
// Activamos el timer para que sea invulnerable 3 segundos MÁS después de aparecer
invul_timer = 180; 
invulnerable = true; 

image_speed = 1; 
image_index = 0;
image_alpha = 0.5; // Ponlo un poco transparente para que sepa que es invulnerable