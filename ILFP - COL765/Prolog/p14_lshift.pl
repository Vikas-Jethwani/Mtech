app_end([],X,[X]).
app_end([Y|T],X,[Y|L]):-app_end(T,X,L).

%Left shift array by 1.
lshift([],[]).
lshift([X|T], L):-app_end(T,X,L).
