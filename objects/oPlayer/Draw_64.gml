// --- INDICADOR DE BANDERA TIPO RADAR ---
if (state != PLAYERSTATE.DEAD) {
    
    var target_flag = (global.myTeam == "ROJO") ? oFlag2 : oFlag; 

    if (instance_exists(target_flag)) {
        
        var camX = camera_get_view_x(view_camera[0]);
        var camY = camera_get_view_y(view_camera[0]);
        var camW = camera_get_view_width(view_camera[0]);
        var camH = camera_get_view_height(view_camera[0]);

        // Solo dibujar si la bandera está fuera de la cámara
        if (target_flag.x < camX || target_flag.x > camX + camW || 
            target_flag.y < camY || target_flag.y > camY + camH) {
            
            // 1. Calcular dirección hacia la bandera
            var dir = point_direction(camX + camW/2, camY + camH/2, target_flag.x, target_flag.y);
            
            // 2. Posición base del icono (el centro del conjunto)
            var margin = 55;
            var centerX = clamp(target_flag.x - camX, margin, display_get_gui_width() - margin);
            var centerY = clamp(target_flag.y - camY, margin, display_get_gui_height() - margin);

            var col = (global.myTeam == "ROJO") ? c_blue : c_red;

            // 3. Calcular la posición de la flecha orbitando al icono
            // El 'dist' es qué tan separada está la flecha del centro del icono
            var dist = 25; 
            var arrowX = centerX + lengthdir_x(dist, dir);
            var arrowY = centerY + lengthdir_y(dist, dir);

            // 4. Dibujar primero la flecha (debajo o alrededor)
            // La rotamos hacia 'dir' para que siempre apunte a la bandera
            draw_sprite_ext(sTroangle, 0, arrowX, arrowY, 1, 1, dir, col, 1);
            
            // 5. Dibujar el icono de la bandera en el centro del radar
            // Le ponemos un pequeño fondo o sombra opcional para que resalte
            draw_sprite_ext(spr_flagvacia, 0, centerX, centerY, 2, 2, 0, col, 1);
        }
    }
}