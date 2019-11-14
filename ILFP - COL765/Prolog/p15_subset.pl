subset([], []).
%Check if L2 is subset of L1
subset([F|T1], [F|T2]):-subset(T1,T2).
subset([F|T1], T2):-subset(T1,T2).
