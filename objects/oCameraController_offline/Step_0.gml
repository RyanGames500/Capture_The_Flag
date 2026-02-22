// follow target
if (instance_exists(follow)) {
    xTo = follow.x - camera_get_view_width(cam) * 0.5;
    yTo = follow.y - camera_get_view_height(cam) * 0.5;
}

// clamp a room
xTo = clamp(xTo, 0, room_width  - camera_get_view_width(cam));
yTo = clamp(yTo, 0, room_height - camera_get_view_height(cam));

// smooth (mueve la cámara)
var cx = camera_get_view_x(cam);
var cy = camera_get_view_y(cam);
cx += (xTo - cx) / smooth;
cy += (yTo - cy) / smooth;

// shake
shake *= shake_decay;
shake_x = random_range(-shake, shake);
shake_y = random_range(-shake, shake);

// aplicar
camera_set_view_pos(cam, cx + shake_x, cy + shake_y);
