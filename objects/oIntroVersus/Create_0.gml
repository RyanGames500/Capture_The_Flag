rivalName = "Cargando..."; 
anim = 0;
alpha = 0;

enum INTRO_STATE { ENTRADA, ESPERA, SALIDA }
estado = INTRO_STATE.ENTRADA;

timer = 90; // Tiempo que se quedan en el centro (1.5 segundos a 60fps)