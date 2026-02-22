// asegurar view 0 activa (ajusta si usas otra)
view_enabled = true;
view_visible[0] = true;

// crear cámara y asignarla a la view 0
cam = camera_create_view(0, 0, 640, 480, 0, noone, 0, 0, 640, 480);
view_camera[0] = cam;

// follow (tu player local)
follow = oPlayer_offline;

// suavizado
xTo = 0;
yTo = 0;
smooth = 10;

// shake
shake = 0;
shake_x = 0;
shake_y = 0;
shake_decay = 0.80;
