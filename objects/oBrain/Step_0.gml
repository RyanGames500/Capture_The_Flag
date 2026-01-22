// --- 1. LÓGICA MIENTRAS SE JUEGA (SOLO HOST) ---
if (global.game_over == false) 
{
    if (oBrain.AmIPseudoHost) 
    {
        var _ganador = 0;
        if (global.puntos_rojo >= 3) _ganador = 1;
        if (global.puntos_azul >= 3) _ganador = 2;

        if (_ganador != 0) 
        {
            global.game_over = true;
            global.winner_team = _ganador;

            // Avisamos al cliente
            var _data = { winner: _ganador };
            if (instance_exists(oOtherPlayer)) {
                SendEventToClient(oOtherPlayer.clientId, "finalizar_partida", _data);
            }
        }
    }
}

// --- 2. LÓGICA DE PANTALLA DE VICTORIA (PARA TODOS) ---
if (global.game_over == true) 
{
    // Aparecer suavemente (fade in)
    if (victory_alpha < 1) {
        victory_alpha += 0.05; 
    }

    // Acciones cuando la pantalla ya es visible
    if (victory_alpha >= 0.9) 
    {
        if (keyboard_check_pressed(vk_escape)) 
        {
            /* Si soy el Host, le aviso al cliente que nos vamos
            if (oBrain.AmIPseudoHost && instance_exists(oOtherPlayer)) {
                SendEventToClient(oOtherPlayer.clientId, "host_abandono", {});
            }*/
            
            // Ambos ejecutan esto para cerrar su socket y limpiar
            LeaveRoom();
        }
    }
} 
else 
{
    victory_alpha = 0; // Reset si no hay game over
}