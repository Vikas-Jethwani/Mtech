%Is already a member?
mem(X,[X|_]).
mem(X,[_|T]):-mem(X,T).

%Base Case.
union([],B,B).
%If already a member, do nothing.
union([X|A],B,L):-
mem(X,B),union(A,B,L).
%If not a member.
union([X|A],B,[X|L]):-
\+ mem(X,B),union(A,B,L).
