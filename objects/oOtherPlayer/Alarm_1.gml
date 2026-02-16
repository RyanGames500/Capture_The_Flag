// oOtherPlayer - Alarm 11
if (global.ONLINE) {
    SendEventToClient(clientId, "sync_lobby_name", { 
        nombre: global.myName  // Mandamos nuestro nombre global
    });
}