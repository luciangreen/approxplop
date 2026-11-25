# approxplop

where plop2 can't find an exact formula for an output character, fit a small learned model for that one character (here a 1-nearest-neighbour table over the examples), and mark it, so RENN can later recover readable code from it. Exact characters stay exact. Strings are lists of numbers 0..9; examples are Input-Output pairs of equal length.

## Use

```prolog
?- use_module(prolog/approxplop).
?- fit([[1,2]-[2,5], [3,4]-[4,1]], M).      % M = [exact(in(1)), approx(table(...))]: in(1) and shift(0,1) both fit; copies are tried before shifts
?- predict(M, [1,2], Out).                  % Out = [2,5]
?- coverage(M, C).                          % C = 1/2: one of two characters is exact
```

## Proofs

`proofs/theorems.pl` proves 5 theorems by exhaustion: each one is checked for every case in a finite domain that covers every branch of the definitions. inputs of length 2 over 0..2; every training set of 1..3 distinct inputs with outputs of length 1

1. The model reproduces every training example exactly, exact or not.
2. An exact character's formula is right on every training example.
3. When the data comes from a formula, that character is found exact, and agrees with the formula on the training inputs.
4. Coverage counts the exact characters.
5. Distance is a metric on the inputs: zero exactly on equal inputs, and symmetric.

```sh
swipl -g main -t halt proofs/theorems.pl
```

## 200 inputs and outputs

`io/ios.txt` lists 200 inputs and outputs from real runs, and `io/ios.pl` has the same as Prolog facts. The inputs come from a fixed seed (`io/cases.pl`). `swipl -g check -t halt io/run.pl` runs them again. It fails if any output changes, or if a predicate doesn't confirm its own recorded output, which checks steadfastness. GitHub Actions runs the proofs and the examples on every push, and records the examples on the first push.

Licence: BSD-3-Clause.
