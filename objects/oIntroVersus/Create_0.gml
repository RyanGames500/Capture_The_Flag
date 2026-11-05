/// @description Intro: equipos con su color, VS y la misión
lista_azul = [];   // { n: nombre, pj: personaje }
lista_rojo = [];
txt_azul = "";
txt_rojo = "";
mi_equipo = "AZUL";

t = 0;              // frames desde que empezó
T_ENTRA  = 36;      // los equipos entran
T_SALEN  = 150;     // los equipos se van
T_MISION = 175;     // aparece la misión
T_FIN    = 330;     // se devuelve el control

// Compatibilidad con el código viejo
rivalName = "";
aliados = "";
rivales = "";
