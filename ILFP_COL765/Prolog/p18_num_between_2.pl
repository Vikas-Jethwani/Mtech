app(X, L, [X|L]).

num(N2,N2,[N2|[]]).
%Append N1 to answer list
num(N1,N2,L):-N1<N2,Newnum1 is (N1+1),num(Newnum1,N2,L1),app(N1,L1,L).
