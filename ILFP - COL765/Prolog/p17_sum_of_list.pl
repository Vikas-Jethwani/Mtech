sum_list([],0).
sum_list([X|T],Sum):-sum_list(T,SumT),Sum is SumT+X.
