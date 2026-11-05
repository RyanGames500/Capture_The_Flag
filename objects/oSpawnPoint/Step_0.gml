// Los invitados solo cuentan hacia atrás para dibujar el anillo.
// El que manda (host) cuenta y decide en oBrain (sección 4) y avisa con "sync_spawn_point".
if (!instance_exists(oBrain) || oBrain.AmIPseudoHost) exit;
if (!ocupado && cooldown > 0) cooldown--;
