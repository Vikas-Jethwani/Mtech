%List, Length_result
list_len([], 0).

%list_len([_|B], N+1):-list_len(B,N).
%problem above as N+1 se expression tree banta hai.
list_len([_|B], N):-list_len(B,N1),N is (N1+1).
