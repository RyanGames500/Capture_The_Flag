function scr_generar_id_amigo() {
    var caracteres = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    var nuevo_id = "";
    repeat(6) {
        var pos = irandom(string_length(caracteres) - 1);
        nuevo_id += string_char_at(caracteres, pos + 1);
    }
    return nuevo_id;
}