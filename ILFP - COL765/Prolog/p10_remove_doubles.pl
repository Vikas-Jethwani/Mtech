del([],X,[]).
del([X|T1], X, T2):-del(T1, X, T2).
del([Y|T1], X, [Y|T2]):-del(T1, X, T2).

app(X, T, [X|T]).

doubles([],[]).
doubles([X],[X]).
doubles([X|Y|L1], Z):-del([Y|L1],X,L3),doubles(L3,L2),app(X,L2,Z).
