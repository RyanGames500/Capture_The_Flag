owner = noone;
distancia = 0;
distancia_max = 160; 
velocidad = 15;
estado = 1; // 1 = Estirando, -1 = Regresando
damage = 0;
hit_list = ds_list_create(); // Para no golpear mil veces al mismo

// --- INICIALIZAR VARIABLES DE POSICIÓN ---
// Esto evita el error de "Variable not set"
x_base = x; 
y_base = y;