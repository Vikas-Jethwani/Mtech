split([],[],[]).
split([X],[X],[]).
split([X1,X2|T],[X1|T1], [X2|T2]):-split(T,T1,T2).

merge(A,[],A).
merge([],B,B).
merge([X|A],[Y|B],[X|L]):-X=<Y,merge(A,[Y|B],L).
merge([X|A],[Y|B],[Y|L]):-X>Y,merge([X|A],B,L).

mergesort([],[]).
mergesort([X],[X]).
mergesort([X,Y|T],L):-split([X,Y|T],L1,L2),mergesort(L1,S1),mergesort(L2,S2),merge(S1,S2,L).
