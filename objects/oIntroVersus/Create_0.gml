rivalName = ""; // Ya no lo usaremos tanto, pero lo dejamos por si acaso
aliados = "Cargando..."; 
rivales = "Cargando...";

anim = 0;
alpha = 0;

enum INTRO_STATE { ENTRADA, ESPERA, SALIDA }
estado = INTRO_STATE.ENTRADA;

timer = 120; // Lo subí a 2 segundos para que de tiempo de leer bien los nombres