/*if (has_flag == true) 
{
    // Sumar punto al equipo Rojo
    obj_control_offline.puntos_rojo += 1;
    
    // Quitarle la bandera al jugador rojo
    oPlayer2_local.has_flag = false;

    // Resetear bandera a su base azul
    has_flag = false;
    x = spawnX;
    y = spawnY;

    // Verificar si el rojo ya ganó
    if (obj_control_offline.puntos_rojo >= obj_control_offline.puntos_para_ganar) {
        obj_control_offline.ganador = "ROJO";
        obj_control_offline.game_over = true;
    }
}