%List, Item, Result_List
del([X|[]], X, []).
del([X|T], X, T).
del([Y|T1], X, [Y|T2]):-del(T1, X, T2).
