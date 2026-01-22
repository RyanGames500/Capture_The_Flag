y_offset -= 0.5; // Velocidad de subida
alpha -= 0.01;   // Se desvanece poco a poco

if (alpha <= 0) {
    instance_destroy();
}