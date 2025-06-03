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

%% =============================================================================
%% Predicado principal: resuelve el nonograma dadas las pistas de filas y columnas
%% =============================================================================
nonograma(Filas, Columnas, Caselles) :-
    length(Columnas, M),
    genera_tauler(Filas, M, Caselles),
    transposta(Caselles, Cols),
    valida_columnes(Columnas, Cols).
%% =============================================================================
%% Genera una matriz Caselles a partir de las pistas de fila
%% =============================================================================
genera_tauler([], _, []).
genera_tauler([P|Ps], M, [F|Fs]) :-
    genera_linea(P, M, F),
    genera_tauler(Ps, M, Fs).

%% =============================================================================
%% Verifica que cada columna obtenida cumple exactamente sus pistas
%% =============================================================================
valida_columnes([], []).
valida_columnes([P|Ps], [C|Cs]) :-
    obtenir_pistes(C, P),
    valida_columnes(Ps, Cs).

%% =============================================================================
%% Genera una línea binaria que satisface una pista dada, con backtracking completo
%% =============================================================================
genera_linea(Pistas, Long, Linea) :-
    sum_list(Pistas, Suma),
    length(Pistas, L),
    MinLen is Suma + L - 1,
    PadMax is Long - MinLen,
    PadMax >= 0,
    entre(0, PadMax, Pad),
    rellenar_ceros(Pad, Inici),
    construeix_blocs(Pistas, Cos),
    append(Inici, Cos, Temp),
    length(Temp, LTemp),
    PadFinal is Long - LTemp,
    rellenar_ceros(PadFinal, Final),
    append(Temp, Final, Linea).

%% =============================================================================
%% Construye los bloques de 1s separados por ceros según la pista
%% =============================================================================
construeix_blocs([], []).
construeix_blocs([X], Bloc) :-
    rellenar_unos(X, Bloc).
construeix_blocs([X|Xs], Bloc) :-
    rellenar_unos(X, Uns),
    construeix_blocs(Xs, R),
    append(Uns, [0|R], Bloc).

%% =============================================================================
%% Extrae las pistas (bloques de 1s consecutivos) de una línea binaria
%% =============================================================================
obtenir_pistes([], []).
obtenir_pistes([0|R], Pistes) :- obtenir_pistes(R, Pistes).
obtenir_pistes([1|R], [N|Ps]) :- conta_uns([1|R], N, Resto), obtenir_pistes(Resto, Ps).

%% =============================================================================
%% Cuenta la cantidad de 1s consecutivos desde el inicio
%% =============================================================================
conta_uns([1|R], N, Rest) :- conta_uns(R, N1, Rest), N is N1 + 1.
conta_uns([0|R], 0, [0|R]).
conta_uns([], 0, []).

%% =============================================================================
%% Genera una lista de ceros de longitud N
%% =============================================================================
rellenar_ceros(0, []).
rellenar_ceros(N, [0|R]) :- N > 0, N1 is N - 1, rellenar_ceros(N1, R).

%% =============================================================================
%% Genera una lista de unos de longitud N
%% =============================================================================
rellenar_unos(0, []).
rellenar_unos(N, [1|R]) :- N > 0, N1 is N - 1, rellenar_unos(N1, R).

%% =============================================================================
%% Generador de números entre A y B (inclusivo), usado para padding
%% =============================================================================
entre(A, B, A) :- A =< B.
entre(A, B, R) :- A < B, A1 is A + 1, entre(A1, B, R).

%% =============================================================================
%% Transpone una matriz (lista de listas)
%% =============================================================================
transposta([], []).
transposta([[]|_], []).
transposta(M, [F|Fs]) :- primera_columna(M, F, R), transposta(R, Fs).

%% =============================================================================
%% Extrae la primera columna de una matriz y devuelve el resto
%% =============================================================================
primera_columna([], [], []).
primera_columna([[X|Xs]|Rs], [X|R1], [Xs|R2]) :- primera_columna(Rs, R1, R2).

%% =============================================================================
%% Imprime una matriz binaria con símbolos gráficos
%% =============================================================================
imprimir_tablero([]).
imprimir_tablero([F|R]) :- imprimir_fila(F), nl, imprimir_tablero(R).

%% =============================================================================
%% Imprime una fila de la matriz con símbolos gráficos
%% =============================================================================
imprimir_fila([]).
imprimir_fila([1|R]) :- write('■ '), imprimir_fila(R).
imprimir_fila([0|R]) :- write('□ '), imprimir_fila(R).
