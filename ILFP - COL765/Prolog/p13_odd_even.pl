odd([_]).
odd([_,X|T]):-odd(T).

even([]).
even([_,X|T]):-even(T).
