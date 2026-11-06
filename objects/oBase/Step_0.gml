if (oBrain.AmIPseudoHost) {
    if (hp <= 0) {
        // Si la base roja muere, gana el azul y viceversa
        var winner = (myTeam == "RED") ? "BLUE" : "RED";
        
        // Usamos tu evento de finalizar partida que ya tienes en el switch
        global.game_over = true;
        global.winner_team = winner;
        
        with (oOtherPlayer) if (!es_bot) SendEventToClient(clientId, "finalizar_partida", { winner: winner });
    }
}