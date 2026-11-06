// Feedback de partido limpio en cada mapa (scr_feedback)
fb_init();

if (AmIPseudoHost) {

    // Cada jugador nace solo en la base de su equipo (scr_spawn_en_base).
    // Antes aquí el host se ponía a la izquierda y mandaba a UN solo rival a x=1359.
    with (oPlayer) scr_spawn_en_base();
}



//creacion de municion
var i = 0;
with(oSpawnPoint) {
    myID = i++; // El primer punto es 0, el segundo 1, etc.
}


// 📦 Pedirle al host todo lo que hay en el mapa cuando YO ya cargué (3 veces por si el host aún cargaba)
resync_left = (global.ONLINE && room != rm_menu && !AmIPseudoHost) ? 3 : 0;
resync_cd   = 5;

// Sala privada: el lider pone los bots en los espacios vacios (scr_objetivo)
scr_botnet_crear_todos();
