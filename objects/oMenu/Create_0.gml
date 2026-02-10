menu_options = ["PLAY", "OPTIONS", "EXIT"];
index = 0;

// --- NUEVO: Modos de Juego ---
game_modes = ["1 VS 1", "2 VS 2", "3 VS 3", "4 VS 4"];
gamemode_names = ["MODO: CAPTURA", "MODO: DESTRUCCIÓN"];
mode_index = 0; // Por defecto 1vs1
// -----------------------------

waiting_timer = 0;
waiting_message = "Buscando Partida";
menu_state = "main";

global.myName = "";
texto_input = "Escribe tu nombre...";
cursor_timer = 0;
max_caracteres = 12;
input_activo = false;

// --- Animaciones (Visuales) ---
menu_x_offset = array_create(array_length(menu_options), 0); // Para que las opciones se muevan al seleccionarlas
bg_grad_alpha = 0; // Para un efecto de glow al entrar
selection_lerp = 0; // Para que la barrita de selección se deslice suave