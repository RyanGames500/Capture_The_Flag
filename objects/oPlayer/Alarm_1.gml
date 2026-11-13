
if (global.ONLINE) {
    // Reaparece en la base de su equipo (antes: host a la izquierda y todos los demás en x=591)
    scr_spawn_en_base();

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
scr_eq_dar();   // EQUIPAMIENTO: vuelves con tus 2 armas (scr_armas)
health = max_health;   // la vida de tu personaje (scr_personajes)
scr_hab_reset();
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