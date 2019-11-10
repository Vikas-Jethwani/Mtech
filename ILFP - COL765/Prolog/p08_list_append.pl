mem(X,[X|T]).
mem(X,[Y|T]):-mem(X,T).

%If not a member then only append. Append at beginning.
app(X, L, L):- mem(X,L),!.
app(X, L, [X|L]).
