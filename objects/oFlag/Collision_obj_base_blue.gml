/* 1. Solo anota punto si alguien la trae cargada
if (has_flag == true) 
{
    // 2. Sumar punto al equipo Azul (porque ellos trajeron la bandera roja a su base)
    obj_control_offline.puntos_azul += 1;
    
    // 3. Avisar al jugador que ya no tiene la bandera
    // Buscamos al jugador azul (o el que la traiga) y le quitamos el estado
    oPlayer_local.has_flag = false; 

    // 4. Resetear la bandera a su base roja
    has_flag = false;
    x = spawnX;
    y = spawnY;
    
    // 5. Verificar si el azul ya ganó
    if (obj_control_offline.puntos_azul >= obj_control_offline.puntos_para_ganar) {
        obj_control_offline.ganador = "AZUL";
        obj_control_offline.game_over = true;
    }
}