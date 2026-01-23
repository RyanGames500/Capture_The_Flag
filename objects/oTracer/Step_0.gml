dir = direction;

x1 = x; y1 = y;
x2 = x + lengthdir_x(len, dir);
y2 = y + lengthdir_y(len, dir);

life--;
if (life <= 0) instance_destroy();

