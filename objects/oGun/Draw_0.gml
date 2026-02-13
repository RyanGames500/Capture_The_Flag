// 1. BLINDAJE: Si no hay arma, no dibujes NADA
if (weapon == noone || !is_struct(weapon)) exit;

// 2. OBTENER EL SPRITE REAL
// Usamos el sprite que viene dentro de la estructura 'weapon'
var _mySprite = weapon.sprite;

// Si por alguna razón el sprite no es válido, nos salimos
if (!sprite_exists(_mySprite)) exit;

// 3. DIBUJAR EL ARMA NORMAL
draw_sprite_ext(
    _mySprite, 
    0, 
    x, 
    y, 
    image_xscale, 
    image_yscale, 
    image_angle, 
    c_white, 
    1
);

// 4. EFECTO DE DESTELLO INTERMITENTE (Solo si no ha sido tomada)
if (!taken) {
    var _alpha_destello = abs(sin(current_time * 0.003)); 
    var _color_destello = c_white; 

    gpu_set_blendmode(bm_add); // Modo brillo "luz"
    
    draw_sprite_ext(
        _mySprite, // USAMOS EL SPRITE DEL ARMA, NO EL DEL OBJETO
        0, 
        x, 
        y, 
        image_xscale * 1.15, 
        image_yscale * 1.15, 
        image_angle, 
        _color_destello, 
        _alpha_destello * 0.6 
    );
    
    gpu_set_blendmode(bm_normal); // Volver al modo normal
}