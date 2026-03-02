
// Menú principal más limpio
menu_options = ["PLAY","OFFLINE","ACHIEVEMENTS", "PROFILE", "OPTIONS", "EXIT"];
index = 0;

// Nueva lista para cuando elijas PLAY
play_modes = ["QUICK MATCH", "PRIVATE ROOM", "BACK"];
play_index = 0;

waiting_timer = 0;
waiting_message = "Buscando Rival";
menu_state = "main"; // Empezamos en el menú
save_state = "idle";
save_timer = 0;

texto_input = "Name"; // Lo que se ve en el cuadro
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
global.max_players = 2; 
global.current_players = 1;
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

random_tips = ["Usa las paredes como cobertura", "Captura la bandera enemiga rapido", "El trabajo en equipo es la clave"];
tip_index = 0;



menu_delay = 0; // Para evitar que el ENTER del nombre active el menú
mensaje_texto = "";
mensaje_alpha = 0; // Para que aparezca y desaparezca suave


//scroll de logros
scroll_y = 0;
scroll_target = 0;
scroll_max = (10 * 90) - 450; 
ach_surf = -1;
copiado_timer = 0;