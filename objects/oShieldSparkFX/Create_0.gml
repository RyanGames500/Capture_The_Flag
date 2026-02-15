image_speed = 0;
// Creamos una explosión de chispas azules
repeat(10) {
    var p = instance_create_layer(x, y, "Instances", oSmokeTrail); // Reusamos tu objeto de humo
    p.speed = random_range(2, 5);
    p.direction = random(360);
    p.color = c_aqua; // Color azul escudo
    p.life = 15;      // Que duren poquito
}
instance_destroy(); // Se destruye al instante tras crear las chispas