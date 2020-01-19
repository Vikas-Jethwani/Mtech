%Is X a member of list.
list_mem(X, [X|_]). 
list_mem(X, [Y|Tail]) :- list_mem(X,Tail). 
