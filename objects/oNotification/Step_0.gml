// Efecto de aparición suave (Lerp de escala)
scale = lerp(scale, target_scale, 0.15);

// Desvanecimiento al final
if (timer > 0) {
    timer--;
} else {
    alpha -= 0.05;
    if (alpha <= 0) instance_destroy();
}