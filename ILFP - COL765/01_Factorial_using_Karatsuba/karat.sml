exception Invalid_Input_exception;

fun fromString str =
        let
            fun adjustAscii num = num - Char.ord(#"0")
            
            fun len([], sz) = sz
            | len(h::T, sz) = len(T, sz+1)
            
            fun pairingIntList([], yet, lenMod4, flag) = [yet]
              | pairingIntList(h::T, yet, lenMod4, flag) = 
                    if lenMod4 = 0 andalso flag = 1 then pairingIntList(T, h, (lenMod4-1+4) mod 4, 0)
                    else if lenMod4 = 0 andalso flag = 0 then yet::(pairingIntList(T, h, (lenMod4-1+4) mod 4, 0))
                    else pairingIntList(T, yet*10+h, (lenMod4-1+4) mod 4, 0)
                    
            val intArr = map (adjustAscii o Char.ord) (explode str)
            val lenMod4 = len(intArr, 0) mod 4
        in
            pairingIntList(intArr, 0, lenMod4, 1)
        end; 


fun toString L =
        let
            fun adjustAscii num = num + Char.ord(#"0")
        in
            implode (map (Char.chr o adjustAscii) L)
        end; 

(*
local
    fun into2 x = 2*x;        
    fun hof x = map into2 x;
in
    fun karatsuba x y = (hof x) @ y
end;    




fun factorial n =
        let
            fun validate_Input [] = true
              | validate_Input (h::T) =
                if Char.ord(h) < Char.ord(#"0") orelse Char.ord(h) > Char.ord(#"9")
                    then false
                else validate_Input(T);    
        in
            if validate_Input (explode n) then n^"2"
            else raise Invalid_Input_exception
        end;    
        
*)