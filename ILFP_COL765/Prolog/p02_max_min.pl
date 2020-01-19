%X,Y,Max_result
max(X, Y, X) :- X >= Y.
max(X, Y, Y) :- X < Y.

%X,Y,Min_result
min(X, Y, X) :- X < Y.
min(X, Y, Y) :- X >= Y.
