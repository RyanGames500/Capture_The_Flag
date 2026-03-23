function scr_check_icon_unlocked(_index) {
    // El 0 y 1 siempre están desbloqueados
    if (_index <= 1) return true;
    
    switch(_index) {
        case 2: // Icono 3: El Guerrero
            return (global.kills >= 100); 
            
        case 3: // Icono 4: El Ganador
            return (global.wins >= 20);
            
        case 4: // Icono 5: El Capturador
            return (global.flags_captured >= 40);
            
        case 5: // Icono 6: Veterano
            return (global.lvl >= 15);
            
        case 6: // Icono 7: Defensor
            return (global.flags_returned >= 30);
            
        // Por defecto, si no has definido el caso, está bloqueado
        default: return false; 
    }
}