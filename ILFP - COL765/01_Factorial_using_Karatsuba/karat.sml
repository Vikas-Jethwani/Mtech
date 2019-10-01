exception Invalid_Input_exception;

fun remove_leading_zeroes [] = []
  | remove_leading_zeroes [a] = [a]
  | remove_leading_zeroes (h::T) =
        if h = #"0" then remove_leading_zeroes T
        else h::T;
                    
(* Takes a string and returns an int-list(pair of 4's) *)
fun fromString str =
        let
            fun adjustAscii num = num - Char.ord(#"0");
            
            fun len([], sz) = sz
              | len(h::T, sz) = len(T, sz+1);
            
            fun pairingIntList([], yet, lenMod4, flag) = [yet]
              | pairingIntList(h::T, yet, lenMod4, flag) = 
                    if lenMod4 = 0 andalso flag = 1 then pairingIntList(T, h, (lenMod4-1+4) mod 4, 0)
                    else if lenMod4 = 0 andalso flag = 0 then yet::(pairingIntList(T, h, (lenMod4-1+4) mod 4, 0))
                    else pairingIntList(T, yet*10+h, (lenMod4-1+4) mod 4, 0);
                    
            val intArr = map (adjustAscii o Char.ord) (explode str)
            val lenMod4 = len(intArr, 0) mod 4
        in
            pairingIntList(intArr, 0, lenMod4, 1)
        end; 


(* Takes an int-list and returns a string *)
fun toString L =
        let
            fun reverse([], z) = z
              | reverse(x, z) = reverse(tl(x), hd(x)::z);
              
            fun splitInt(num, 0) = []
              | splitInt(num, left) = 
                    Char.chr(48+(num mod 10))::splitInt(num div 10, left-1);
                    
            fun toString_wr([]) = []
              | toString_wr(h::T) = 
                    (Char.chr(48+(h mod 10))::splitInt(h div 10, 3)) @ toString_wr(T);
                    
            fun adjustAscii num = num + Char.ord(#"0");
            
            val Lr = reverse(L, [])
        in
            
            implode( remove_leading_zeroes( reverse(toString_wr(Lr), [])))
        end;





(* performs a-b on 2 int-lists, returns int lists
fun subtract(
*)






(*
local
    fun into2 x = 2*x;        
    fun hof x = map into2 x;
in
    fun karatsuba x y = (hof x) @ y
end;    
*)



fun factorial n =
        let
            fun validate_Input [] = true
              | validate_Input (h::T) =
                if Char.ord(h) < Char.ord(#"0") orelse Char.ord(h) > Char.ord(#"9")
                    then false
                else validate_Input(T);
                    
            fun factorial_wr "" = raise Invalid_Input_exception
              | factorial_wr n =
                if validate_Input (explode n)
                    then implode (remove_leading_zeroes (explode n))
                else raise Invalid_Input_exception;
        in
            factorial_wr n
        end;    
        