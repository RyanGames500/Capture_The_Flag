// Generador de armas (local). Ahora vuelve a poner un arma cuando se llevan la suya.
// nivel (código de creación en el room): 1 = pistolas/subfusiles, 2 = rifles/escopetas,
// 3 = las fuertes (esperan 20 s al empezar), 0 = de todo.
nivel = 0;
my_item = noone;
timer = 0;
timer_max = 0;
primera_vez = true;
