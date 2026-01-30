function host_spawn_ammo(_x, _y, _amount)
{
    if (!oBrain.AmIPseudoHost) exit;

    // Creamos la entidad
    var a = instance_create_layer(_x, _y, "Instances", oMyEntity);
    
    // Configuramos los datos de oMyEntity
    a.tipo = "ammo"; // <--- Le decimos que es munición
    a.amount = _amount;
    a.sprite_index = spr_ammo; // Pon el sprite de tu caja de balas
    a.life = 0; // Para que no desaparezca por tiempo como las balas
    
    // El net_uid ahora es el entityId que genera oBrain automáticamente
    a.net_uid = a.entityId; 
}