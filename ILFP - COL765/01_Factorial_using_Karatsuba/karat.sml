exception Invalid_Input_exception;

fun remove_leading_zeroes [] = []
  | remove_leading_zeroes [a] = [a]
  | remove_leading_zeroes (h::T) =
        if h = #"0" then remove_leading_zeroes T
        else h::T;
                    
fun reverse([], z) = z
  | reverse(x, z) = reverse(tl(x), hd(x)::z);
  
  
  
(* Takes a string and returns an int-list(pair of 4's) *)
fun fromString str =
        let
            fun adjustAscii num = num - Char.ord(#"0");
            
            (* Length of a list *)
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





(* performs a-b on 2 int-lists, returns int lists; assumes a>b *)
fun subtract(a, b) =
    let
        fun sub([], [], bo) = []
          | sub(h1::T1, [], bo) = 
                if h1=48 andalso bo=1 then Char.chr(57)::sub(T1, [], 1)
                else Char.chr(h1-bo)::sub(T1, [], 0)
          | sub(h1::T1, h2::T2, bo) = 
                if h1 >= h2 then Char.chr(48+h1-h2-bo)::sub(T1, T2, 0)
                else Char.chr(48+h1-h2+10-bo)::sub(T1, T2, 1)
        
        val astr = (String.rev (toString a))
        val bstr = (String.rev (toString b))
        val sub_string = implode ( sub(map (Char.ord) (explode astr), map (Char.ord) (explode bstr), 0) )
    in
        (* fromString( String.rev(sub_string) ) *)
        fromString( implode (remove_leading_zeroes (explode (String.rev(sub_string) ) ) ) )
    end;    

(* performs a+b on 2 int-lists, returns int lists *)
fun addition(a, b) =
    let
        fun add([], [], 0) = []
          | add([], [], 1) = [#"1"]
          | add(h1::T1, [], carry) = 
                if h1=57 andalso carry=1 then Char.chr(48)::add(T1, [], 1)
                else Char.chr(h1+carry)::add(T1, [], 0)
          | add([], h2::T2, carry) = 
            if h2=57 then Char.chr(48)::add([], T2, 1)
            else Char.chr(h2+carry)::add([], T2, 0)
          | add(h1::T1, h2::T2, carry) =
                if h1+h2+carry-96 > 9 then Char.chr(h1+h2+carry-48-10)::add(T1, T2, 1)
                else Char.chr(h1+h2+carry-48)::add(T1, T2, 0)
                
        
        val astr = (String.rev (toString a))
        val bstr = (String.rev (toString b))
        val add_string = implode ( add( map (Char.ord) (explode astr), map (Char.ord) (explode bstr), 0) )
    in
        fromString( String.rev(add_string) )
    end;    



fun justify_length(b, 0) = b
  | justify_length(b, count) = 0::justify_length(b, count-1);

fun split([], _, left, right) = (reverse(left,[]), reverse(right,[]))
  | split(h::T, 0, left, right) = split(T, 0, left, h::right)
  | split(h::T, count, left, right) = split(T, count-1, h::left, right);


(* Takes 2 int-list and compares them *)
fun greater_than(a, b) =
    let
        fun check_wr([], []) = true
          | check_wr(h1::T1, h2::T2) =
                if h1 > h2 then true
                else if h1 < h2 then false
                else check_wr(T1, T2)
    in
        if List.length(a) > List.length(b) then true
        else if List.length(a) < List.length(b) then false
        else check_wr(a, b)
    end;  


            
(* Takes 2 int-list; return int *)
fun karat([h1], [h2]) = h1*h2
  | karat(a, b) =
    let
        fun find_z1(x0, x1, y0, y1, z0, z2) =
            if greater_than(x0, x1) then
                if greater_than(y1, y0) then
                    z0 + z2 + ( karat( subtract(x0, x1), subtract(y1, y0) ) )
                else
                    z0 + z2 - ( karat( subtract(x0, x1), subtract(y0, y1) ) )
            else
                if greater_than(y1, y0) then
                    z0 + z2 - ( karat( subtract(x1, x0), subtract(y1, y0) ) )
                else
                    z0 + z2 + ( karat( subtract(x1, x0), subtract(y0, y1) ) )
        val al = List.length(a)
        val bl = List.length(b)
        val b_new = justify_length(b, al-bl)
        val m = Real.ceil(Real.fromInt(al)/2.0)
        val (x1, x0) = split(a, al-m, [], [])
        val (y1, y0) = split(b, bl-m, [], [])
        val z0 = karat(x0, y0) (* is in integer *)
        val z2 = karat(x1, y1)
        val z1 = find_z1(x0, x1, y0, y1, z0, z2)
    in
        z1
    end;    
    


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
        