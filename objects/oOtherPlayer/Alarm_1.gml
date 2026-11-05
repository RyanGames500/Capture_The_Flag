SendEventToClient(clientId, "sync_lobby_name", { 
    nombre: global.myName, // Cambiado de 'name' a 'nombre'
    soyHost: false,
    team: scr_my_team() 
});