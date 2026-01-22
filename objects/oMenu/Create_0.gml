menu_options = ["PLAY", "OPTIONS", "EXIT"];
index = 0;

waiting_timer = 0;
waiting_message = "Buscando Rival";
menu_state = "main"; // Empezamos en el menú


global.myName = "";          // Aquí se guardará el nombre final
texto_input = "Escribe tu nombre..."; // Lo que se ve en el cuadro
cursor_timer = 0;            // Para que la rayita del texto parpadee
max_caracteres = 12;         // Que no se pasen de largo
input_activo = false;        // ¿Está el jugador escribiendo?
