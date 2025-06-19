%% =============================================================================
%% Práctica final - Lenguajes de Programación - Curso 2024-2025
%% Equipo formado por: Pau Bibiloni & Hugo Guerreiro
%% Fecha: 09/05/2025
%% Asignatura: Lenguajes de Programación, Práctica PROLOG
%% Convocatoria: Ordinaria
%%
%% -------------------------------
%% Ejemplo de uso del programa:
%%
%% ?- nonograma(
%%       [[5], [5], [1,1], [3], [2]],
%%       [[2,2], [5], [2,1], [2], [3]],
%%       Caselles),
%%    imprimir_tablero(Caselles).
%%
%% Caselles = [[■, ■, ■, ■, ■],
%%             [■, ■, ■, ■, ■],
%%             [□, ■, □, □, ■],
%%             [■, ■, ■, □, □],
%%             [■, ■, □, □, □]]
%%
%% También puedes generar uno aleatorio:
%%
%% ?- genera_nonograma(5, 5, F, C, Caselles),
%%    write(F), nl, write(C), nl,
%%    imprimir_tablero(Caselles).
%%
%% =============================================================================


%% =============================================================================
%% Predicat principal
%% =============================================================================
nonograma(PistasFilas, PistasColumnas, Caselles) :-
    longitud(PistasFilas, N),
    longitud(PistasColumnas, M),
    crear_filas(N, M, Caselles),
    restringir_lineas(PistasFilas, Caselles),
    transpose(Caselles, Transp),
    restringir_lineas(PistasColumnas, Transp),
    etiquetar_lineas(Caselles).

%% =============================================================================
%% Crear matriu de N files de M columnes amb variables lliures
%% =============================================================================
crear_filas(0, _, []).
crear_filas(N, M, [Fila|Resto]) :-
    N > 0,
    crear_fila(M, Fila),
    N1 is N - 1,
    crear_filas(N1, M, Resto).

crear_fila(0, []).
crear_fila(M, [_|Resto]) :-
    M > 0,
    M1 is M - 1,
    crear_fila(M1, Resto).

%% =============================================================================
%% Aplicar restriccions de les pistes sobre cada línia
%% =============================================================================
restringir_lineas([], []).
restringir_lineas([P|Ps], [L|Ls]) :-
    restringir_linea(P, L),
    restringir_lineas(Ps, Ls).

restringir_linea(Pistas, Linea) :-
    longitud(Linea, N),
    generar_linea(Pistas, N, Linea),
    etiquetar_linea(Linea).

%% =============================================================================
%% Generar línia binària que compleix les pistes
%% =============================================================================
generar_linea([], Longitud, Linea) :-
    ceros(Longitud, Linea).

generar_linea([X|Xs], Longitud, Linea) :-
    suma(Xs, SumaRestos),
    longitud(Xs, NumRestos),
    MinLong is X + SumaRestos + NumRestos,
    MaxPadding is Longitud - MinLong,
    MaxPadding >= 0,
    entre(0, MaxPadding, Padding),
    ceros(Padding, Prefijo),
    unos(X, Bloque),
    RestoLong is Longitud - Padding - X,
    generar_sufijo(Xs, RestoLong, Suffix),
    append(Prefijo, Bloque, Parte),
    append(Parte, Suffix, Linea),
    longitud(Linea, Longitud).

generar_sufijo([], RestoLong, Suffix) :-
    ceros(RestoLong, Suffix).

generar_sufijo([Y|Ys], RestoLong, [0|SubLinea]) :-
    RestoLong1 is RestoLong - 1,
    RestoLong1 >= 0,
    generar_linea([Y|Ys], RestoLong1, SubLinea).

%% =============================================================================
%% Utilitats bàsiques
%% =============================================================================
ceros(0, []).
ceros(N, [0|R]) :-
    N > 0,
    N1 is N - 1,
    ceros(N1, R).

unos(0, []).
unos(N, [1|R]) :-
    N > 0,
    N1 is N - 1,
    unos(N1, R).

longitud([], 0).
longitud([_|Xs], N) :-
    longitud(Xs, M),
    N is M + 1.

suma([], 0).
suma([X|Xs], R) :-
    suma(Xs, S),
    R is X + S.

entre(X, _, X).
entre(Min, Max, X) :-
    Min < Max,
    Min1 is Min + 1,
    entre(Min1, Max, X).

%% =============================================================================
%% Etiquetar línia amb 0 o 1 per backtracking
%% =============================================================================
etiquetar_linea([]).
etiquetar_linea([X|Xs]) :-
    (X = 0 ; X = 1),
    etiquetar_linea(Xs).

etiquetar_lineas([]).
etiquetar_lineas([Fila|Resto]) :-
    etiquetar_linea(Fila),
    etiquetar_lineas(Resto).

%% =============================================================================
%% Agrupar valors consecutius i extreure pistes
%% =============================================================================
agrupa([], []).
agrupa([X|Xs], [[X|Grupo]|Resto]) :-
    iguals(X, Xs, Grupo, RestoXs),
    agrupa(RestoXs, Resto).

iguals(_, [], [], []).
iguals(X, [X|Xs], [X|R], Resto) :-
    iguals(X, Xs, R, Resto).
iguals(X, [Y|Ys], [], [Y|Ys]) :-
    diferent(X, Y).

diferent(0, 1).
diferent(1, 0).

es_bloque_pleno([1|_]).

filtrar([], []).
filtrar([G|Gs], [G|Rs]) :-
    es_bloque_pleno(G),
    filtrar(Gs, Rs).
filtrar([G|Gs], Rs) :-
    no_bloque(G),
    filtrar(Gs, Rs).

no_bloque([0|_]).

longitudes([], []).
longitudes([L|Ls], [N|Ns]) :-
    longitud(L, N),
    longitudes(Ls, Ns).

%% =============================================================================
%% Generador aleatori de nonogrames
%% =============================================================================
genera_nonograma(N, M, PistasFilas, PistasColumnas, Caselles) :-
    crear_filas(N, M, Caselles),
    aleatoritzar_tauler(Caselles),
    obtenir_pistes(Caselles, PistasFilas),
    transpose(Caselles, Transp),
    obtenir_pistes(Transp, PistasColumnas).

aleatoritzar_tauler([]).
aleatoritzar_tauler([F|Fs]) :-
    aleatoritzar_fila(F),
    aleatoritzar_tauler(Fs).

aleatoritzar_fila([]).
aleatoritzar_fila([X|Xs]) :-
    random(0.0, 1.0, R),
    assigna_valor(R, X),
    aleatoritzar_fila(Xs).

assigna_valor(R, 1) :- R < 0.7.
assigna_valor(R, 0) :- R >= 0.7.

obtenir_pistes([], []).
obtenir_pistes([F|Fs], [P|Ps]) :-
    agrupa(F, Grups),
    filtrar(Grups, Plens),
    longitudes(Plens, P),
    obtenir_pistes(Fs, Ps).

%% =============================================================================
%% Transposar matriu (implementació pròpia)
%% =============================================================================
transpose([], []).
transpose([[]|_], []).
transpose(M, [F|Fs]) :-
    columna(M, F, R),
    transpose(R, Fs).

columna([], [], []).
columna([[X|Xs]|Resto], [X|Primers], [Xs|Restants]) :-
    columna(Resto, Primers, Restants).

%% =============================================================================
%% Impressió del tauler
%% =============================================================================
imprimir_tablero([]).
imprimir_tablero([Fila|Resto]) :-
    imprimir_fila(Fila), nl,
    imprimir_tablero(Resto).

imprimir_fila([]).
imprimir_fila([1|Xs]) :- write('■ '), imprimir_fila(Xs).
imprimir_fila([0|Xs]) :- write('□ '), imprimir_fila(Xs).
