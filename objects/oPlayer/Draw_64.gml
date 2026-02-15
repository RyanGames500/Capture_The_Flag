// --- INDICADOR DE BANDERA TIPO RADAR (Fix Equipos) ---
if (state != PLAYERSTATE.DEAD) {
    
    // REGLA: Si soy Azul, debo robar la Roja (oFlag). Si soy Rojo, debo robar la Azul (oFlag2).
    var target_flag = (global.myTeam == "AZUL") ? oFlag : oFlag2; 

    if (instance_exists(target_flag)) {
        var camX = camera_get_view_x(view_camera[0]);
        var camY = camera_get_view_y(view_camera[0]);
        var camW = camera_get_view_width(view_camera[0]);
        var camH = camera_get_view_height(view_camera[0]);

        // Solo dibujar si la bandera enemiga está fuera de la cámara
        if (target_flag.x < camX || target_flag.x > camX + camW || 
            target_flag.y < camY || target_flag.y > camY + camH) {
            
            var dir = point_direction(camX + camW/2, camY + camH/2, target_flag.x, target_flag.y);
            
            // Posición en la GUI
            var margin = 55;
            var centerX = clamp(target_flag.x - camX, margin, display_get_gui_width() - margin);
            var centerY = clamp(target_flag.y - camY, margin, display_get_gui_height() - margin);

            // COLOR TIPO BRAWL STARS: El objetivo siempre es "Rojo" para ti
            var col = c_red; 

            var dist = 25; 
            var arrowX = centerX + lengthdir_x(dist, dir);
            var arrowY = centerY + lengthdir_y(dist, dir);

            // Dibujar flecha y bandera
            draw_sprite_ext(sTroangle, 0, arrowX, arrowY, 1, 1, dir, col, 1);
            draw_sprite_ext(spr_flagvacia, 0, centerX, centerY, 2, 2, 0, col, 1);
        }
    }
}