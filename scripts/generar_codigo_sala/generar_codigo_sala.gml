function generar_codigo_sala(_length) {
    randomize(); // <--- ¡Justo aquí! Esto garantiza que el código sea distinto en cada ejecución
    var _chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    var _code = "";
    repeat(_length) {
        _code += string_char_at(_chars, irandom_range(1, string_length(_chars)));
    }
    return _code;
}