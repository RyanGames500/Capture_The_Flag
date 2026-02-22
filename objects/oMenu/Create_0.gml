
menu_options = ["PLAY", "PRIVATE", "OPTIONS", "OFFLINE", "EXIT"];
index = 0;

waiting_timer = 0;
waiting_message = "Buscando Rival";
menu_state = "main"; // Empezamos en el menú


global.myName = "";          // Aquí se guardará el nombre final
texto_input = "Escribe tu nombre..."; // Lo que se ve en el cuadro
cursor_timer = 0;            // Para que la rayita del texto parpadee
max_caracteres = 12;         // Que no se pasen de largo
input_activo = false;        // ¿Está el jugador escribiendo?

// --- NUEVAS VARIABLES PARA LOBBY PRIVADO ---
private_options = ["CREATE ROOM", "JOIN WITH CODE", "BACK"];
p_index = 0; // El índice para el menú privado
global.myRoomCode = ""; // Aquí guardaremos el código de 4 letras

// --- CONFIGURACIÓN DE LA SALA ---
setup_options = ["MODO: 1 VS 1", "MAPA: BOSQUE", "CONFIRMAR Y CREAR"];
s_index = 0; // Índice para el menú de setup

global.setup_modo = 0; // 0 = 1vs1, 1 = 2vs2, 2 = 4vs4
global.setup_mapa = 0; // 0 = Bosque, 1 = Arena 2 = Lagos
global.max_players_allowed = 8; // Por defecto

// Para el menú de Kick
show_kick_menu = false;
kick_menu_x = 0;
kick_menu_y = 0;
kick_target_id = -1; // El ID del que vamos a echar

// En el Create de oMenu
if (!variable_global_exists("regresar_a_offline")) {
    global.regresar_a_offline = false;
}

// Si venimos de una partida offline, saltamos el menú principal
if (global.regresar_a_offline) {
    menu_state = "offline_setup";
    global.regresar_a_offline = false; // La reseteamos para la próxima
    
    // Opcional: define aquí las opciones de nuevo para que no aparezcan vacías
    off_index = 0; 
    offline_options = [
        "MAPA: " + (global.off_mapa == 0 ? "BOSQUE" : "ARENA"),
        "OBJETIVO: " + string(global.off_flags) + " BANDERAS",
        "ENEMIGOS: " + (global.off_bots == 0 ? "SOLO (PRÁCTICA)" : "CON BOTS (CPU)"),
        "INICIAR BATALLA",
        "VOLVER"
    ];
}