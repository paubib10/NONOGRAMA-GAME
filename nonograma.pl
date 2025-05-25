%% =============================================================================
%% Práctica final - Lenguajes de Programación - Curso 2024-2025
%% Equipo formado por: Hugo Guerreiro & Pau Bibiloni
%% Fecha: 09/05/2025
%% Asignatura: Lenguajes de Programación, Práctica PROLOG
%% Convocatoria: Ordinaria
%%
%% -------------------------------
%% Ejemplo de uso del programa:
%%
%% ?- nonograma(
%%       [[2], [5], [1,1], [5], [3]],
%%       [[1,1], [3], [2], [5], [2]],
%%       Caselles),
%%    imprimir_tablero(Caselles).
%%
%% Caselles = [[□, ■, ■, □, □],
%%             [■, ■, ■, ■, ■],
%%             [■, □, ■, □, □],
%%             [■, ■, ■, ■, ■],
%%             [□, ■, ■, ■, □]]
%%
%% También puedes generar uno aleatorio:
%%
%% ?- genera_nonograma(5, 5, F, C, Caselles),
%%    write(F), nl, write(C), nl,
%%    imprimir_tablero(Caselles).
%%
%% =============================================================================

:- use_module(library(clpfd)).

%% =============================================================================
%% Predicado principal: nonograma(+Filas, +Columnas, -Caselles)
%% Resuelve un nonograma dados los patrones de filas y columnas.
%% =============================================================================
nonograma(PistasFilas, PistasColumnas, Caselles) :-
    dimensiones_correctas(PistasFilas, PistasColumnas),
    length(PistasFilas, N),
    length(PistasColumnas, M),
    crear_matriz(N, M, Caselles),
    maplist(restringir_linea, PistasFilas, Caselles),
    transpose(Caselles, Transp),
    maplist(restringir_linea, PistasColumnas, Transp),
    maplist(label, Caselles).

%% =============================================================================
%% dimensiones_correctas(+Filas, +Columnas)
%% Verifica que las listas tengan dimensiones válidas.
%% =============================================================================
dimensiones_correctas(PistasFilas, PistasColumnas) :-
    length(PistasFilas, _),
    length(PistasColumnas, _).

%% =============================================================================
%% crear_matriz(+N, +M, -Matriz)
%% Crea una matriz N×M de variables binarias (0 o 1).
%% =============================================================================
crear_matriz(N, M, Matriz) :-
    length(Matriz, N),
    maplist(crear_fila(M), Matriz).

crear_fila(M, Fila) :-
    length(Fila, M),
    Fila ins 0..1.

%% =============================================================================
%% restringir_linea(+Pistas, +Linea)
%% Asegura que una línea de celdas cumple con las pistas dadas.
%% =============================================================================
restringir_linea(Pistas, Linea) :-
    length(Linea, N),
    posibles_lineas(Pistas, N, Posibles),
    member(Linea, Posibles).

posibles_lineas(Pistas, Longitud, Lineas) :-
    findall(Line, genera_linea(Pistas, Longitud, Line), Lineas).

%% =============================================================================
%% genera_linea(+Pistas, +Longitud, -Linea)
%% Genera una posible línea que cumple con las pistas.
%% =============================================================================
genera_linea([], Longitud, Linea) :-
    length(Linea, Longitud),
    maplist(=(0), Linea).

genera_linea([X|Xs], Longitud, Linea) :-
    sum_list(Xs, SumaResto),
    length(Xs, NumResto),
    MinLong is X + SumaResto + NumResto, 
    MaxPadding is Longitud - MinLong,
    MaxPadding >= 0,
    between(0, MaxPadding, Padding),
    length(Prefix, Padding),
    maplist(=(0), Prefix),
    length(Bloque, X),
    maplist(=(1), Bloque),
    RestoLong is Longitud - Padding - X,
    (Xs = [] ->
        genera_linea([], RestoLong, Suffix)
    ;
        SiguienteEspacio is RestoLong - 1,
        SiguienteEspacio >= 0,
        genera_linea(Xs, SiguienteEspacio, SubLinea),
        Suffix = [0|SubLinea]
    ),
    append([Prefix, Bloque, Suffix], Linea),
    length(Linea, Longitud).

%% =============================================================================
%% sum_list(+Lista, -Suma)
%% Calcula la suma de una lista de enteros.
%% =============================================================================
sum_list([X|Xs], Suma) :- sum_list(Xs, S), Suma is X + S.
sum_list([], 0).

%% =============================================================================
%% agrupa(+Lista, -Grupos)
%% Agrupa valores consecutivos iguales en sublistas.
%% =============================================================================
agrupa([], []).
agrupa([X|Xs], [[X|Grupo]|Resto]) :-
    mismo_inicio(X, Xs, Grupo, RestoXs),
    agrupa(RestoXs, Resto).

mismo_inicio(X, [], [], []).
mismo_inicio(X, [X|Xs], [X|Resto], RestoFinal) :-
    mismo_inicio(X, Xs, Resto, RestoFinal).
mismo_inicio(X, [Y|Ys], [], [Y|Ys]) :- X \= Y.

%% =============================================================================
%% es_bloque_pleno(+Sublista)
%% Verifica si una sublista representa un bloque de 1s.
%% =============================================================================
es_bloque_pleno([1|_]).

%% =============================================================================
%% genera_nonograma(+N, +M, -Filas, -Columnas, -Caselles)
%% Genera un nonograma aleatorio de tamaño N×M.
%% =============================================================================
genera_nonograma(N, M, PistasFilas, PistasColumnas, Caselles) :-
    length(Caselles, N),
    maplist(longitud_fila(M), Caselles),
    maplist(random_fila, Caselles),
    maplist(obtener_pistas, Caselles, PistasFilas),
    transpose(Caselles, Transp),
    maplist(obtener_pistas, Transp, PistasColumnas).

longitud_fila(M, Fila) :-
    length(Fila, M).

random_fila(Fila) :-
    maplist(random_binario, Fila).

random_binario(X) :-
    random(0.0, 1.0, R),
    (R < 0.7 -> X = 1 ; X = 0).

%% =============================================================================
%% obtener_pistas(+Fila, -Pistas)
%% Dada una fila, devuelve las pistas que representa.
%% =============================================================================
obtener_pistas(Fila, Pista) :-
    agrupa(Fila, Grupos),
    include(es_bloque_pleno, Grupos, Plenos),
    maplist(length, Plenos, Pista).

%% =============================================================================
%% imprimir_tablero(+Caselles)
%% Muestra en consola el tablero con ■ para 1 y □ para 0.
%% =============================================================================
imprimir_tablero([]).
imprimir_tablero([Fila|Resto]) :-
    maplist(mostrar_casilla, Fila), nl,
    imprimir_tablero(Resto).

mostrar_casilla(1) :- write('■ ').
mostrar_casilla(0) :- write('□ ').