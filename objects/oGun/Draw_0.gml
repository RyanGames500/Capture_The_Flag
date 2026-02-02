// 1. Dibujar el arma normal siempre
draw_self();

// 2. EFECTO DE DESTELLO INTERMITENTE (Solo si no ha sido tomada)
if (!taken) {
    // Calculamos el "latido" (brillo) usando sin()
    // current_time * 0.003 controla la velocidad del parpadeo
    // abs() asegura que el valor sea siempre positivo
    var _alpha_destello = abs(sin(current_time * 0.003)); 
    
    // Elegimos el color del destello según el arma (opcional)
    // Por ahora usemos blanco o naranja para que resalte
    var _color_destello = c_white; 

    // Dibujamos una versión un poco más grande y brillante encima
    gpu_set_blendmode(bm_add); // Modo brillo "luz"
    
    draw_sprite_ext(
        sprite_index, 
        image_index, 
        x, 
        y, 
        image_xscale * 1.15, // Un pelín más grande
        image_yscale * 1.15, 
        image_angle, 
        _color_destello, 
        _alpha_destello * 0.6 // El brillo sube y baja
    );
    
    gpu_set_blendmode(bm_normal); // Volver al modo normal
}