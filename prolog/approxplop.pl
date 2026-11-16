% approxplop: where plop2 can't find an exact formula for an output character, fit a small
% learned model for that one character (here a 1-nearest-neighbour table over the examples),
% and mark it, so RENN can later recover readable code from it. Exact characters stay exact.
% Strings are lists of numbers 0..9; examples are Input-Output pairs of equal length.
%?- fit([[1,2]-[2,5], [3,4]-[4,1]], M).      % M = [exact(shift(0,1)), approx(table(...))]
%?- predict(M, [1,2], Out).                  % Out = [2,5]
%?- coverage(M, C).                          % C = 1/2: one of two characters is exact
:- module(approxplop, [formula/3, exact_for/3, fit/2, predict/3, coverage/2, distance/3]).
:- use_module(library(lists)).
:- use_module(library(apply)).

% Formulas for one output character: copy input I, add D to input I (mod 10), a constant,
% or the sum of inputs I and J (mod 10).
formula(in(I), In, C) :- nth0(I, In, C).
formula(shift(I, D), In, C) :- nth0(I, In, X), C is (X + D) mod 10.
formula(const(C), _, C).
formula(plus(I, J), In, C) :- nth0(I, In, X), nth0(J, In, Y), C is (X + Y) mod 10.

candidate(_, const(C)) :- between(0, 9, C).
candidate(Top, in(I)) :- between(0, Top, I).
candidate(Top, shift(I, D)) :- between(0, Top, I), between(1, 9, D).
candidate(Top, plus(I, J)) :- between(0, Top, I), between(I, Top, J).

% exact_for(+Examples, +K, -Formula): the simplest formula giving character K in every example.
exact_for(Exs, K, F) :- Exs = [In0-_|_], length(In0, N), Top is N - 1,
    candidate(Top, F0), forall(member(In-Out, Exs), ( nth0(K, Out, C), formula(F0, In, C) )), !, F = F0.

% fit(+Examples, -Model): per character, exact(Formula) when one fits, else approx(table(Pairs)).
fit(Exs, M) :- Exs = [_-Out0|_], length(Out0, N), Top is N - 1,
    findall(P, ( between(0, Top, K), ( exact_for(Exs, K, F) -> P = exact(F) ; findall(In-C, ( member(In-Out, Exs), nth0(K, Out, C) ), T), P = approx(table(T)) ) ), M0),
    M = M0.

% predict(+Model, +Input, -Output): exact characters by formula; approximate ones from the nearest example.
predict(M, In, Out) :- maplist([P, C]>>predict_char(P, In, C), M, Out0), Out = Out0.
predict_char(exact(F), In, C) :- formula(F, In, C).
predict_char(approx(table(T)), In, C) :- maplist([I-V, D-V]>>distance(In, I, D), T, Ds), keysort(Ds, [_-C|_]).

% distance(+A, +B, -D): how many places differ (Hamming).
distance(A, B, D) :- foldl([X, Y, D0, D1]>>( X =:= Y -> D1 = D0 ; D1 is D0 + 1 ), A, B, 0, D).

coverage(M, N/D) :- include([P]>>(P = exact(_)), M, E), length(E, N), length(M, D).
