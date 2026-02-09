var gw = display_get_gui_width();
var gh = display_get_gui_height();

draw_set_alpha(alpha);

// --- FONDO (Barras negras que se desvanecen) ---
draw_set_color(c_black);
draw_rectangle(0, 0, gw, 120 * alpha, false);
draw_rectangle(0, gh - (120 * alpha), gw, gh, false);

// --- NOMBRES ---
draw_set_font(fnt_intro);

// Tu nombre: En 0 está en -300, en 1 en el centro-izq, en 2.5 se va a la derecha (fuera)
var x_me = lerp(-300, gw * 0.35, anim); 
draw_set_halign(fa_right);
draw_text_transformed_color(x_me, gh/2, global.myName, 1.5, 1.5, 0, c_aqua, c_aqua, c_white, c_white, alpha);

// Nombre Rival: En 0 está en gw+300, en 1 en centro-der, en 2.5 se va a la izquierda (fuera)
// Para que salga hacia el otro lado, invertimos el lerp de salida:
var x_rival = lerp(gw + 300, gw * 0.65, anim);
draw_set_halign(fa_left);
draw_text_transformed_color(x_rival, gh/2, rivalName, 1.5, 1.5, 0, c_red, c_red, c_white, c_white, alpha);

// El "VS" se hace pequeño o desaparece
var vs_scale = (1 - (anim - 1)) * alpha; // Se encoge al salir
if (estado == INTRO_STATE.ENTRADA) vs_scale = anim;

draw_set_halign(fa_center);
draw_set_alpha(alpha);
draw_text_transformed(gw/2, gh/2, "VS", vs_scale, vs_scale, 0);

draw_set_alpha(1);