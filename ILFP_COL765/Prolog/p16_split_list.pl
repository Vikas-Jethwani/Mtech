split([],[],[]).
split([X],[X],[]).
%Split like we did in SML.
split([X1,X2|T], [X1|T1], [X2|T2]):-split(T,T1,T2).
