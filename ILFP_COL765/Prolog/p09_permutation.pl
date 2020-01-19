del([X|T], X, T).
del([Y|T1], X, [Y|T2]):-del(T1, X, T2).

%Generate all permutations.
perm([],[]).
perm(L,[X|P]):-del(L,X,L1),perm(L1,P).
