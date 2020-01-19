%is se asli mein operation hota hai; symbol se sirf expression tree banta hai.
series(X,Y,Z) :- Z is (X+Y).
parallel(X,Y,Z) :- Z is ((X*Y)/(X+Y)).

%test on below input.
%	parallel(10,40,X),series(X,12,Y),parallel(Y,30,R).
