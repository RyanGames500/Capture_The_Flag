// Create
gmda_setController("2293_6zm1L7oE22LEmSTvnk5Jcq99czZ9TBz88bRzJ5","2293_vOFiDZbwM6VxcxscewPaRxxzdQNL1XED33zBQA"); // Game Id & Game Key
gmda_setLeaderboard("P165jRqN3uNR2O8zAsN"); //Table key

gmda_define_achievement("Grand Lord","jsKT","Destroy all enemies","1");//achievement 1
gmda_define_achievement("Pig Rider","VOnY","Ride a pig","2");//achievement 2
gmda_define_achievement("Gold fever","H34sjdf34","Get 10,000 gold","3");//achievement 3


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

global.registrado = 0;
global.myName = "Cargando...";          // Aquí se guardará el nombre final
global.save_version=1;

#region Carga local
scr_load_from_local();
#endregion