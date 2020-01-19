app_end([],X,[X]).
app_end([Y|T],X,[Y|L]):-app_end(T,X,L).

rev([],[]).
rev([X|T1], T2):-rev(T1,T3),app_end(T3,X,T2).

%Palindrome if equal to its reverse.
palin(L):-rev(L,L).
