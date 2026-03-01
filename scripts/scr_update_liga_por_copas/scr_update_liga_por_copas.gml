function scr_update_liga_por_copas() {
    var _c = global.copas;
    
    if (_c < 100)        global.rank = "Bronce I";
    else if (_c < 300)   global.rank = "Bronce II";
    else if (_c < 600)   global.rank = "Plata I";
    else if (_c < 1000)  global.rank = "Plata II";
    else if (_c < 1500)  global.rank = "Oro I";
    else if (_c < 2100)  global.rank = "Oro II";
    else if (_c < 3000)  global.rank = "Platino";
    else if (_c < 4500)  global.rank = "Diamante";
    else if (_c < 6000)  global.rank = "Maestro";
    else                 global.rank = "Gran Maestro";
    
    // Cada vez que cambien las copas, actualizamos el rango y guardamos
    scr_save_to_local();
    scr_save_to_cloud();
}