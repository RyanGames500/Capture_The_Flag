
// Menú principal más limpio
menu_options = ["PLAY","OFFLINE","FRIENDS","ACHIEVEMENTS", "PROFILE", "OPTIONS", "EXIT"];
index = 0;

// Nueva lista para cuando elijas PLAY
play_modes = ["QUICK MATCH", "PRIVATE ROOM", "BACK"];
play_index = 0;

waiting_timer = 0;
waiting_message = "Buscando Rival";
menu_state = "main";		 // Empezamos en el menú
save_state = "idle";
save_timer = 0;

texto_input = "Name";		 // Lo que se ve en el cuadro
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
//timer para copiar ids
copiado_timer = 0;
timer_latido = 0;
//Sistema de buscar y agregar amigos
busqueda_nombre_tecleado = ""; 
request_buscar_id = -1;
request_datos_rival = -1;
datos_busqueda_resultado = -1; // Aquí guardaremos lo que encontremos
estado_busqueda = "idle"; // "idle", "buscando", "encontrado", "error"


// --- NUEVO SISTEMA DE AMIGOS ---
friends_options = ["FRIENDS", "ADD", "BACK"];
friends_index = 0;

// Variables para "Añadir Amigos"
friends_search_input = ""; 
request_sugeridos = -1;
lista_sugeridos = []; // Aquí guardaremos los perfiles aleatorios
amigos_agregados = []; // Aquí irán tus amigos reales (puedes cargarlos de local después)


// Estado del menú de amigos
friends_state = "main"; // "main", "lista", "anadir"
search_timer = 0


// --- VARIABLES INICIALES DEL BUZÓN ---
hay_solicitud_pendiente = false;
datos_solicitud_recibida = -1;
request_solicitud = -1;
peticion_recibida = false;

// --- POSICIÓN DEL ICONO DEL BUZÓN ---
// Estas variables ahora existen para TODO el objeto
mail_x = (display_get_gui_width() / 2) + 600; 
mail_y = (display_get_gui_height() / 2) - 270;

scroll_y = 0;
scroll_target = 0;
friend_selected = 0; // Para saber a quién tienes resaltado

scroll_y_target = 0;       // Para que el scroll sea suave
ventana_iconos_alto = 220; // El alto del "hueco" donde se ven los iconos

// Revisar estado de amigos cada 5 segundos (60 fps * 5)
alarm[2] = 1;
alarm[3] = room_speed * 2;

avatar_seleccionado = 0;     // El que estás viendo en la ventanita
mostrando_selector = false;  // Controla si la ventana está abierta
