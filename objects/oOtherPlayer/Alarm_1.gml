SendEventToClient(clientId, "sync_lobby_name", { 
    nombre: global.myName, 
    soyHost: false // El invitado avisa que NO es host
});