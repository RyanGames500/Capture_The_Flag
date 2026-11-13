// Ejecutamos lo que hace el barril normal primero
event_inherited(); 

// Sobrescribimos los valores para que sea "más débil"
event_inherited(); // Esto copia lo de arriba
hp = 30;           // Pero luego lo cambiamos
mi_danio = 25;     // Menos daño
radius_value = 85; // Radio más pequeño (el rojo llega a 130)