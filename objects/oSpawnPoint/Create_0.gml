tipo_spawn = ""; // Puede ser "ammo", "weapon" o "powerup"
powerup_tipo = ""; // "speed" | "heal"
arma_struct = noone;  // Si es arma, qué struct (pistola, etc.)
cooldown = 0;         // Tiempo para que reaparezca (frames)
ocupado = false;      // ¿Hay algo encima ahora mismo?
myID = -1;            // ID único para que el Host y Cliente sepan cuál es cuál

// --- Spawn por niveles (se pone en el código de creación de cada punto en el room) ---
// armas:   1 = pistolas/subfusiles, 2 = rifles/escopetas, 3 = las fuertes (0 = de todo)
// poderes: 1 = los de la base (curación, velocidad), 2 = los del centro (escudo, daño, balas)
nivel = 0;
cooldown_max = 0;     // para dibujar el anillo que se va llenando
primera_vez = true;   // las armas fuertes esperan 20 segundos al empezar
mi_item = noone;      // (solo host) lo que puso este punto; si ya no existe, se lo llevaron
