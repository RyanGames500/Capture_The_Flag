// Create
gmda_setController("2293_6zm1L7oE22LEmSTvnk5Jcq99czZ9TBz88bRzJ5","2293_vOFiDZbwM6VxcxscewPaRxxzdQNL1XED33zBQA"); // Game Id & Game Key
gmda_setLeaderboard("3c1pq9YLwsD88StilkXRKRD"); //Table key

// --- DEFINICIÓN DE LOGROS (GAMDATO) ---

// 1. Exterminador (50 bajas)
gmda_define_achievement("Exterminador", "EDfBTkqW", "Elimina a 50 enemigos en total.", "1");

// 2. Conquistador (10 victorias)
gmda_define_achievement("Conquistador", "bQlLwO0e", "Consigue 10 victorias para tu equipo.", "2");

// 3. Centinela (10 recuperaciones)
gmda_define_achievement("Centinela", "Mgt4bwuS", "Recupera tu bandera 10 veces fuera de la base.", "3");

// 4. Capturador (10 agarres)
gmda_define_achievement("Capturador", "wpMbRYcU", "Agarra la bandera enemiga 10 veces.", "4");

// 5. Estratega (Racha de 5)
gmda_define_achievement("Estratega", "lJjtqUBp", "Consigue una racha de 5 bajas sin morir.", "5");

// 6. Segador de Almas (500 bajas)
gmda_define_achievement("Segador de Almas", "K4ynEN93", "Elimina a 500 enemigos en total.", "6");

// 7. Leyenda Viva (100 victorias)
gmda_define_achievement("Leyenda Viva", "54FbyQ8N", "Consigue 100 victorias totales.", "7");

// 8. Guardian Eterno (50 recuperaciones)
gmda_define_achievement("Guardian Eterno", "Y8c81dy3", "Recupera tu bandera 50 veces.", "8");

// 9. Infiltrado Real (200 capturas)
gmda_define_achievement("Infiltrado Real", "Zm9IBCfG", "Captura la bandera enemiga 200 veces.", "9");

// 10. Fantasma del Campo (Racha de 15)
gmda_define_achievement("Fantasma del Campo", "JkLFQ8yq", "Elimina a 15 enemigos sin ser derrotado.", "10");


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