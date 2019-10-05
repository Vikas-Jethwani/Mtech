exception Invalid_Input_exception;

(* Removes leading zeroes from a Char-List *)
fun remove_Leading_Zeroes [] = []
  | remove_Leading_Zeroes [a] = [a]
  | remove_Leading_Zeroes (h::T) =
        if h = #"0" then remove_Leading_Zeroes T
        else h::T ;

(* Removes leading zeroes from a Int-List *)
fun strip_Zeroes [] = []
  | strip_Zeroes [a] = [a]
  | strip_Zeroes (h::T) =
        if h = 0 then strip_Zeroes T
        else h::T ;

(* Reverses a given List *)
fun reverse([], z) = z
  | reverse(h::T, z) = reverse(T, h::z) ;
  
  
(* Reverses a given String and removes leading zeroes, if asked *)
fun string_Rev(str, rem_lead) =
        let
            val reversed_str = reverse( explode str, [] )
        in
            if rem_lead = 1 then implode( remove_Leading_Zeroes reversed_str )
            else implode reversed_str
        end ;


(* Length of a list *)
fun list_Len([], sz) = sz
  | list_Len(h::T, sz) = list_Len(T, sz+1) ;
  
  
(* Takes a String and returns an Int-List(pair of 4's) *)
fun fromString str =
        let
            fun adjustAscii num = num - Char.ord(#"0") ;
            
            (* Actual pairing of ints into 4-4 size groups using length, mod and counter *)
            fun pairingIntList([], yet, lenMod4, flag) = [yet]
              | pairingIntList(h::T, yet, lenMod4, flag) = 
                    if lenMod4 = 0 andalso flag = 1 then pairingIntList(T, h, (lenMod4-1+4) mod 4, 0)
                    else if lenMod4 = 0 andalso flag = 0 then yet::(pairingIntList(T, h, (lenMod4-1+4) mod 4, 0))
                    else pairingIntList(T, yet*10+h, (lenMod4-1+4) mod 4, 0) ;
                    
            val intArr = map (adjustAscii o Char.ord) ( remove_Leading_Zeroes( explode str ) )
            val lenMod4 = list_Len(intArr, 0) mod 4
        in
            pairingIntList(intArr, 0, lenMod4, 1)
        end ; 


(* Takes an Int-List and returns a String *)
fun toString L =
        let
            fun splitInt(num, 0) = []
              | splitInt(num, left) = 
                    Char.chr(48+(num mod 10))::splitInt(num div 10, left-1) ;
                    
            fun toString_wr([]) = []
              | toString_wr(h::T) = 
                    (Char.chr(48+(h mod 10))::splitInt(h div 10, 3)) @ toString_wr(T) ;
            
            val Lr = reverse(L, [])
        in
            
            implode( remove_Leading_Zeroes( reverse( toString_wr(Lr), [] ) ) )
        end ;


(* Performs a-b on 2 Int-Lists, returns Int-List; assumes a>b *)
fun subtract(a, b) =
    let
        exception b_More_Than_a_In_Subtract_Function ;
        
        (* Subtraction done on Char-List in reverse fashion *)
        fun sub([], [], bo) = []
          | sub(h1::T1, [], bo) = 
                if h1=48 andalso bo=1 then #"9"::sub(T1, [], 1) (* num=0 and borrow=1 *)
                else Char.chr(h1-bo)::sub(T1, [], 0)
          | sub(h1::T1, h2::T2, bo) = 
                if h1 > h2 then Char.chr(48+h1-h2-bo)::sub(T1, T2, 0)
                else if h1=h2 andalso bo=0 then #"0"::sub(T1, T2, 0)
                else Char.chr(48+h1-h2+10-bo)::sub(T1, T2, 1) (* case when nums are equal but borrow has been passed on *)
          | sub([], h2::T2, bo) = raise b_More_Than_a_In_Subtract_Function ;
                
        val astr = string_Rev( toString a, 0 )
        val bstr = string_Rev( toString b, 0 )
        val sub_string = implode( sub( map (Char.ord) (explode astr), map (Char.ord) (explode bstr), 0 ) )
    in
        fromString( string_Rev( sub_string, 1 ) )
    end ;    


(* Performs a+b on 2 Int-Lists, returns Int-List *)
fun addition(a, b) =
    let
        (* Addition done on Char-List in reverse fashion *)
        fun add([], [], 1) = [#"1"]
          | add([], [], _) = []
          | add(h1::T1, [], carry) = 
                if h1=57 andalso carry=1 then #"0"::add(T1, [], 1) (* num=9 and carry=1 *)
                else Char.chr(h1+carry)::add(T1, [], 0)
          | add([], h2::T2, carry) = 
                if h2=57 andalso carry=1 then #"0"::add([], T2, 1) (* num=9 and carry=1 *)
                else Char.chr(h2+carry)::add([], T2, 0)
          | add(h1::T1, h2::T2, carry) =
                if h1+h2+carry-96 > 9 then Char.chr(h1+h2+carry-48-10)::add(T1, T2, 1)
                else Char.chr(h1+h2+carry-48)::add(T1, T2, 0) ;
                
        
        val astr = string_Rev( toString a, 0 )
        val bstr = string_Rev( toString b, 0 )
        val add_string = implode( add( map (Char.ord) (explode astr), map (Char.ord) (explode bstr), 0 ) )
    in
        fromString( string_Rev( add_string, 1 ) )
    end ;


(* Pads [0] at starting of an Int-List *)
fun pad_Left(b, 0) = b
  | pad_Left(b, count) = 0::pad_Left(b, count-1) ;

(* Split Int-List into 2-ordered-tuple; left-side-size = count *)
fun split([], _, left, right) = (reverse( left, [] ), reverse( right, [] ) )
  | split(h::T, 0, left, right) = split(T, 0, left, h::right)
  | split(h::T, count, left, right) = split(T, count-1, h::left, right) ;

(* Takes 2 Int-List and compares them *)
fun greater_Than(a, b) =
    let
        exception Not_Possible_exception ;
        
        fun compare_Wr([], []) = true
          | compare_Wr(h1::T1, h2::T2) =
                if h1 > h2 then true
                else if h1 < h2 then false
                else compare_Wr(T1, T2)
          | compare_Wr(_, _) = raise Not_Possible_exception ; (* Different sizes not possible here, case already handled *)
          
        val a_new = strip_Zeroes a
        val b_new = strip_Zeroes b
    in
        if list_Len( a_new, 0 ) > list_Len( b_new, 0 ) then true
        else if list_Len( a_new, 0 ) < list_Len( b_new, 0 ) then false
        else compare_Wr( a_new, b_new )
    end ;  


            
(* Takes 2 Int-List; return Int-List *)
fun karat([h1], [h2]) = if h1*h2>=10000 then ((h1*h2) div 10000)::[(h1*h2) mod 10000]
                        else [(h1*h2) mod 10000]
  | karat(a, b) =
        let
            fun find_z1(x0, x1, y0, y1, z0, z2) =
                if greater_Than(x0, x1) then
                    if greater_Than(y1, y0) then
                        addition( addition(z0 , z2) , ( karat( subtract(x0, x1), subtract(y1, y0) ) ) )
                    else
                        subtract( addition(z0 , z2) , ( karat( subtract(x0, x1), subtract(y0, y1) ) ) )
                else
                    if greater_Than(y1, y0) then
                        subtract( addition(z0 , z2) , ( karat( subtract(x1, x0), subtract(y1, y0) ) ) )
                    else
                        addition( addition(z0 , z2) , ( karat( subtract(x1, x0), subtract(y0, y1) ) ) ) ;

            fun pow([], 0) = []
              | pow([], m) = 0::pow([], m-1)
              | pow(h::T, m) = h::pow(T, m) ;


            val al = list_Len(a, 0)
            val bl = list_Len(b, 0)

            val mx = if al >= bl then al else bl
            val a_new = pad_Left(a, mx-al)
            val b_new = pad_Left(b, mx-bl)
            val m = (mx+1) div 2

            val (x1, x0) = split(a_new, mx-m, [], [])
            val (y1, y0) = split(b_new, mx-m, [], [])

            val z0 = karat(x0, y0)
            val z2 = karat(x1, y1)
            val z1 = find_z1(x0, x1, y0, y1, z0, z2)

            val term1 = pow(z2, 2*m)
            val term2 = pow(z1, m)
        in
            addition( addition(term1, term2) , z0 )
        end ;    
    

fun karatsuba x y = karat(x,y)
   



(* Takes a String input and returns factorial in String format *)
fun factorial n =
        let
            fun validate_Input [] = true
              | validate_Input (h::T) =
                    if Char.ord(h) < Char.ord(#"0") orelse Char.ord(h) > Char.ord(#"9") then false
                    else validate_Input(T) ;
                    
            fun factorial_pre_process "" = raise Invalid_Input_exception
              | factorial_pre_process n =
                    if validate_Input (explode n) then n
                    else raise Invalid_Input_exception ;
                
            fun is_zero([a]) =  if a=0 then true else false
              | is_zero(L) = false ;
              
            fun decr new_n = subtract(new_n, [1]) ;

            fun factorial_wr(new_n, result) = 
                    if is_zero (new_n) then (result)
                    else factorial_wr( decr new_n, karat( result, new_n ) ) ;
                    
            val new_n = fromString( factorial_pre_process n )
        in
            (* toString( factorial_wr(new_n, [1]) ) *)
            factorial_wr(new_n, [1])
        end ;    
        