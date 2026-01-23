function scrShootFX(_x, _y, _dir, _w)
{
    // Muzzle flash (rápido y bonito)
    // si no tienes partículas, puedes dibujar un sprite flash 1 frame con instance temporal
    // ejemplo: instance_create_layer(_x,_y,"Instances",oMuzzleFlash);

    // Tracer: una línea corta hacia delante (visual)
    var tx = _x + lengthdir_x(40, _dir);
    var ty = _y + lengthdir_y(40, _dir);

    // Guardar datos para dibujar 1 frame (o crea obj tracer con life=2)
    if (!variable_global_exists("tracer_queue")) global.tracer_queue = [];
    array_push(global.tracer_queue, [_x,_y,tx,ty, 2]); // 2 frames
}
