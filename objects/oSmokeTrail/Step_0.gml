// Step Event de oSmokeTrail
image_alpha -= fade_speed;
image_xscale += 0.01; // El humo se expande un poco
image_yscale += 0.01;

if (image_alpha <= 0) instance_destroy();