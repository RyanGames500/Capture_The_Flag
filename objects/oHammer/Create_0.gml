// --- Evento Create de oHammer ---
image_speed = 0; // Empezamos quietos
image_index = 0; // En el primer frame (arriba)

// Usamos la posición para que sea la misma espera en ambas pantallas
random_set_seed(x + y); 
tiempo_espera = room_speed * random_range(1, 4); 
randomize(); 

timer = tiempo_espera;
ataca = false;
// Le damos un ID único basado en su posición para que el Host sepa a cuál se refiere
myHammerId = string(round(x)) + string(round(y));