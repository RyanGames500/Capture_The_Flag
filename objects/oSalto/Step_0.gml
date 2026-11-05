if (golpe > 0) golpe -= 1;

// En línea: si otro jugador sale disparado desde aquí, también se ve el golpe
with (oOtherPlayer) {
	if (abs(x - other.x) < 26 && bbox_bottom > other.y - 40 && bbox_bottom < other.y + 6 && y - yprevious < -8) other.golpe = 12;
}
