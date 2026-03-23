image_speed = 0; 
life = 120;      
vspeed = -0.5;   
owner = noone;   

// --- AJUSTE PARA IMÁGENES GRANDES ---
var tamano_deseado = 64; // El tamaño en píxeles que quieres que tenga en pantalla
escala_final = tamano_deseado / sprite_get_width(sprite_index); 

// Empezamos con la mitad de esa escala para el efecto de "pop"
image_xscale = escala_final * 0.5;
image_yscale = escala_final * 0.5;

depth = -10000;
pop_y_offset = 20;
