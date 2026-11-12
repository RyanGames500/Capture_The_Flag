// Create
// (Gamdato se quito del juego: ya no hay setController, leaderboard ni logros de Gamdato.
//  Los logros ahora estan en DatabaseFunctions, LOGROS, y se guardan en tu cuenta / aparato.)

// --- DATOS DEL PERFIL ---
global.lvl = 1;
global.xp = 0;
global.wins = 0;
global.flags_captured = 0; // ¡Clave para tu juego
global.flags_returned = 0;// Bnaderas recuperadas
global.rank = "RECLUTA";   // Rango visual
global.kills = 0; //enemigos eliminados
global.losses = 0;
global.copas = 0; // Tu moneda de progresión competitiva

global.partida_con_bot = false;
global.registrado = 0;
global.myName = "Cargando...";          // Aquí se guardará el nombre final
global.save_version=1;
global.miFriendTag="";
global.lista_amigos = []; // Creamos el array vacío
global.nombre_ultimo_amigo=""; 
global.ONLINE=false;
global.avatar_id = 0;              // El que está puesto
// Justo cuando empieza la partida o cuando recibes los datos del otro
global.ultimo_rival_tag = "";
global.revancha_yo = false;     // ¿Yo pulsé el botón?
global.revancha_rival = false;  // ¿El rival pulsó el botón?
#region Carga local
scr_load_from_local();
#endregion