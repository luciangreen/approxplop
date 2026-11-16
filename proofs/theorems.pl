% Theorems about approxplop, proved by exhaustion. Run: swipl -g main -t halt proofs/theorems.pl
:- module(theorems, [main/0]).
:- use_module('../prolog/approxplop').
:- use_module(prove).
:- discontiguous theorem/1.
:- use_module(library(lists)).
:- use_module(library(apply)).
main :- prove_all(theorems).

% Domain: inputs of length 2 over 0..2; every training set of 1..3 distinct inputs with outputs of length 1
% drawn from every function of a few kinds (exact formulas and arbitrary values).
input([A, B]) :- between(0, 2, A), between(0, 2, B).
inputs(Is) :- findall(I, input(I), All), between(1, 3, N), length(Is, N), sublist_of(All, Is).
sublist_of(_, []).
sublist_of([X|Xs], [X|Ys]) :- sublist_of(Xs, Ys).
sublist_of([_|Xs], Ys) :- sublist_of(Xs, Ys).
outputs(Is, Exs) :- maplist([I, I-[C]]>>between(0, 9, C), Is, Exs).
trainset(Exs) :- inputs(Is), length(Is, N), N =< 2, outputs(Is, Exs).

% 1. The model reproduces every training example exactly, exact or not.
theorem(model_fits_training_examples) :- forall(( trainset(Exs), fit(Exs, M) ), forall(member(I-O, Exs), predict(M, I, O))).

% 2. An exact character's formula is right on every training example.
theorem(exact_means_exact) :- forall(( trainset(Exs), fit(Exs, M), nth0(K, M, exact(F)) ), forall(member(I-O, Exs), ( nth0(K, O, C), formula(F, I, C) ))).

% 3. When the data comes from a formula, that character is found exact, and agrees with the formula on the training inputs.
theorem(formulas_are_found_exact) :-
    forall(( inputs(Is), member(F, [in(0), in(1), shift(0, 3), plus(0, 1), const(7)]), maplist([I, I-[C]]>>formula(F, I, C), Is, Exs) ),
           ( fit(Exs, [exact(G)]), forall(member(I, Is), ( formula(F, I, C1), formula(G, I, C2), C1 == C2 )) )).

% 4. Coverage counts the exact characters.
theorem(coverage_counts_exact) :- forall(( trainset(Exs), fit(Exs, M) ), ( coverage(M, N/D), length(M, D), N =< D )).

% 5. Distance is a metric on the inputs: zero exactly on equal inputs, and symmetric.
theorem(distance_is_a_metric) :- forall(( input(A), input(B) ), ( distance(A, B, D1), distance(B, A, D2), D1 == D2, iff(D1 =:= 0, A == B) )).
