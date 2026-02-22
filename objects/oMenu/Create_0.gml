
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