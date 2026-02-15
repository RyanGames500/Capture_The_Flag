// Ejecutamos lo que hace el barril normal primero
event_inherited(); 

// Sobrescribimos los valores para que sea "más débil"
event_inherited(); // Esto copia lo de arriba
hp = 30;           // Pero luego lo cambiamos
mi_danio = 20;     // Menos daño
radius_value = 50; // Radio más pequeño (el normal es 80)