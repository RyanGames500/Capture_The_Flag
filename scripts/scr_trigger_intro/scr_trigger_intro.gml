function scr_trigger_intro(_azules, _rojos) {
    if (!instance_exists(oIntroVersus)) {
        var intro = instance_create_layer(0, 0, "Instances", oIntroVersus);

        // Respaldo: los nombres en texto como antes ("Ryan & Ana")
        intro.txt_azul = _azules;
        intro.txt_rojo = _rojos;

        // Cada jugador con su personaje y su equipo de verdad
        var _yo = scr_my_team();
        intro.mi_equipo = _yo;
        var _mine = { n: global.myName, pj: global.pj_selected };
        if (_yo == "AZUL") array_push(intro.lista_azul, _mine); else array_push(intro.lista_rojo, _mine);
        with (oOtherPlayer) {
            var _tm = (variable_instance_exists(id, "team") && team != "") ? team : lobby_team;
            var _p  = { n: Name, pj: variable_instance_exists(id, "mySelectedPJ") ? mySelectedPJ : 0 };
            if (_tm == "AZUL") array_push(intro.lista_azul, _p); else array_push(intro.lista_rojo, _p);
        }
        // Contra el bot de partida rápida: el rival con su nombre y personaje
        if (variable_global_exists("bot_partida") && global.bot_partida) {
            var _bt = { n: global.bot_nombre, pj: global.bot_pj };
            if (_yo == "AZUL") array_push(intro.lista_rojo, _bt); else array_push(intro.lista_azul, _bt);
        }

        // TODOS CONTRA TODOS: no hay equipos, todos repartidos a los dos lados (scr_reloj)
        if (scr_modo_todos()) {
            var _todos = [];
            for (var _j = 0; _j < array_length(intro.lista_azul); _j++) array_push(_todos, intro.lista_azul[_j]);
            for (var _j = 0; _j < array_length(intro.lista_rojo); _j++) array_push(_todos, intro.lista_rojo[_j]);
            intro.lista_azul = []; intro.lista_rojo = [];
            for (var _j = 0; _j < array_length(_todos); _j++) { if (_j mod 2 == 0) array_push(intro.lista_azul, _todos[_j]); else array_push(intro.lista_rojo, _todos[_j]); }
        }

        // JEFE GIGANTE: todos de un lado y el jefe del otro (scr_reloj)
        if (scr_modo_jefe()) {
            for (var _j = 0; _j < array_length(intro.lista_rojo); _j++) array_push(intro.lista_azul, intro.lista_rojo[_j]);
            intro.lista_rojo = [{ n: "EL JEFE", pj: 3 }];
            intro.mi_equipo = "AZUL";
        }

        if (instance_exists(oPlayer)) oPlayer.state = PLAYERSTATE.INTRO;
    }
}
