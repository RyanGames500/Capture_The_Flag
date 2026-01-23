life = 3;
len  = 90;              // largo del tracer
dir  = direction;       // guarda la dirección inicial
depth = -100000;

// puntos iniciales
x1 = x; y1 = y;

// calcular final
x2 = x + lengthdir_x(len, dir);
y2 = y + lengthdir_y(len, dir);
