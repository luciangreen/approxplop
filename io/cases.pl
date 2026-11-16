:- module(cases, [title/1, case/3]).
:- use_module('../prolog/approxplop').
:- use_module(engine).
title('approxplop').
in_g(N, I) :- length(I, N), maplist([X]>>rnd_int(0, 9, X), I).
exs_g(Exs) :- rnd_int(2, 3, N), rnd_int(1, 3, Len), rnd_int(2, 4, K), length(Exs, K),
    length(Fs, Len), Top is N - 1, maplist([F]>>( rnd_int(0, Top, I), rnd_int(1, 9, D), rnd_pick([in(I), shift(I, D), plus(0, I), noise], F) ), Fs),
    maplist([In-Out]>>( in_g(N, In), maplist([F, C]>>( F == noise -> rnd_int(0, 9, C) ; formula(F, In, C) ), Fs, Out) ), Exs).
case(fit, [Exs], fit) :- exs_g(Exs).
case(predict, [M, In], predict) :- exs_g(Exs), fit(Exs, M), Exs = [I0-_|_], length(I0, N), in_g(N, In).
case(coverage, [M], coverage) :- exs_g(Exs), fit(Exs, M).
case(distance, [A, B], distance) :- rnd_int(1, 5, N), in_g(N, A), in_g(N, B).
