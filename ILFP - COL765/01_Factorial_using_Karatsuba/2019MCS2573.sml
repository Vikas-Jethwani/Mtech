exception Invalid_Input_exception of string ;

local
    (* Removes leading zeroes from a Char-List; returns a Char-List *)
    fun strip_Zeroes [] = []
      | strip_Zeroes [a] = [a]
      | strip_Zeroes (h::T) =
            if h = #"0" then strip_Zeroes T
            else h::T ;

    (* Removes leading zeroes from an Int-List; returns an Int-List *)
    fun remove_Leading_Zeroes [] = []
      | remove_Leading_Zeroes [a] = [a]
      | remove_Leading_Zeroes (h::T) =
            if h = 0 then remove_Leading_Zeroes T
            else h::T ;

    (* Reverses a given List *)
    fun reverse([], z) = z
      | reverse(h::T, z) = reverse(T, h::z) ;

    (* Performs a+b on 2 Int-Lists, returns Int-List *)
    fun addition (a, b) =
            let
                fun addn([], [], 1, result) = 1::result
                  | addn([], [], _, result) = result
                  | addn(h1::T1, [], carry, result) =
                        if h1+carry >= 10000 then addn( T1, [], 1, (h1+carry-10000)::result )
                        else addn( T1, [], 0, (h1+carry)::result )
                  | addn([], h2::T2, carry, result) = 
                        if h2+carry >= 10000 then addn( [], T2, 1, (h2+carry-10000)::result )
                        else addn( [], T2, 0, (h2+carry)::result )
                  | addn(h1::T1, h2::T2, carry, result) =
                        if h1+h2+carry >= 10000 then addn( T1, T2, 1, (h1+h2+carry-10000)::result )
                        else addn( T1, T2, 0, (h1+h2+carry)::result ) ;

                val aR = reverse(a, [])
                val bR = reverse(b, [])
            in
                remove_Leading_Zeroes( addn(aR, bR, 0, []) )
            end ;

    (* Performs a-b on 2 Int-Lists, returns Int-List; assumes a>b *)
    fun subtract(a, b) =
            let
                exception b_More_Than_a_In_Subtract_Function ;

                fun sub([], [], 0, result) = result
                  | sub(h1::T1, [], borrow, result) =
                        if h1-borrow < 0 then sub( T1, [], 1, (h1-borrow+10000)::result )
                        else sub( T1, [], 0, (h1-borrow)::result )
                  | sub(h1::T1, h2::T2, borrow, result) =
                        if h1-h2-borrow < 0 then sub( T1, T2, 1, (h1-h2-borrow+10000)::result )
                        else sub( T1, T2, 0, (h1-h2-borrow)::result )
                  | sub([], _, _, result) = raise b_More_Than_a_In_Subtract_Function ;

                val aR = reverse(a, [])
                val bR = reverse(b, [])
            in
                remove_Leading_Zeroes( sub( aR, bR, 0, [] ) )
    end ;

in

    (* Takes a String and returns an Int-List(pair of 4's) *)
    fun fromString str =
            let
                fun adjustAscii num = num - Char.ord(#"0") ;

                (* Pairing of ints into 4-4 size groups using length, mod and counter *)
                fun pairingIntList([], yet, lenMod4, flag) = [yet]
                  | pairingIntList(h::T, yet, lenMod4, flag) =
                        if lenMod4 = 0 andalso flag = 1 then pairingIntList(T, h, (lenMod4-1+4) mod 4, 0)
                        else if lenMod4 = 0 andalso flag = 0 then yet::(pairingIntList(T, h, (lenMod4-1+4) mod 4, 0))
                        else pairingIntList(T, yet*10+h, (lenMod4-1+4) mod 4, 0) ;

                (* Converts to a Char-List then adjusts ascii to make Int-List of single single element *)
                val intArr = map (adjustAscii o Char.ord) ( strip_Zeroes( explode str ) )
                val lenMod4 = (List.length intArr) mod 4
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
                implode( strip_Zeroes( reverse( toString_wr(Lr), [] ) ) )
    end ;

    fun karatsuba x y =
        let
            (* Takes 2 Int-Lists; returns an Int-List *)
            fun karat(x, [0]) = [0]
              | karat([0], y) = [0]
              | karat(x, [1]) = x
              | karat([1], y) = y
              | karat([h1], [h2]) = if h1*h2>=10000 then ((h1*h2) div 10000)::[(h1*h2) mod 10000]
                                    else [(h1*h2) mod 10000]
              | karat(a, b) =
                    let
                        (* Takes 2 Int-Lists and compares them *)
                        fun greater_Than(a, b) =
                            let
                                exception Not_Possible_exception ;

                                fun compare_Wr([], []) = true
                                  | compare_Wr(h1::T1, h2::T2) =
                                        if h1 > h2 then true
                                        else if h1 < h2 then false
                                        else compare_Wr(T1, T2)
                                  | compare_Wr(_, _) = raise Not_Possible_exception ; (* Different sizes not possible here, case already handled *)
                            in
                                if List.length a > List.length b then true
                                else if List.length a < List.length b then false
                                else compare_Wr( a, b )
                            end ;

                        (* Ensures that there isn't overflow *)
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

                        (* Appends [0] to RHS, to increase power by the Base=10000 *)
                        fun pow([], 0) = []
                          | pow([], m) = 0::pow([], m-1)
                          | pow(h::T, m) = h::pow(T, m) ;

                        (* Pads [0] at starting of an Int-List *)
                        fun pad_Left(b, 0) = b
                          | pad_Left(b, count) = 0::pad_Left(b, count-1) ;


                        val al = List.length a
                        val bl = List.length b

                        val mx = if al >= bl then al else bl
                        val a_new = pad_Left(a, mx-al)
                        val b_new = pad_Left(b, mx-bl)
                        val m = (mx+1) div 2

                        val (x1, x0) = List.splitAt(a_new, mx-m)
                        val (y1, y0) = List.splitAt(b_new, mx-m)

                        val X0 = remove_Leading_Zeroes x0
                        val X1 = remove_Leading_Zeroes x1
                        val Y0 = remove_Leading_Zeroes y0
                        val Y1 = remove_Leading_Zeroes y1

                        val z0 = karat(X0, Y0)
                        val z2 = karat(X1, Y1)
                        val z1 = find_z1(X0, X1, Y0, Y1, z0, z2)

                        val term1 = pow(z2, 2*m)
                        val term2 = pow(z1, m)
                    in
                        addition( addition(term1, term2) , z0 )
                    end ;
        in
            karat(x, y)
        end ;

    (* Takes a String input and returns factorial in String format *)
    fun factorial n =
            let
                (* Checks for non numeric character in input *)
                fun validate_Input [] = true
                  | validate_Input (h::T) =
                        if Char.ord(h) < Char.ord(#"0") orelse Char.ord(h) > Char.ord(#"9") then false
                        else validate_Input(T) ;

                (* Calls validate input. Takes String; returns same String *)
                fun factorial_pre "" = raise Invalid_Input_exception ("Input is Empty.")
                  | factorial_pre n =
                        if validate_Input (explode n) then n
                        else raise Invalid_Input_exception("Non-Numeric charater detected in input or negative number as input.")

                fun decr new_n = subtract(new_n, [1]) ;

                fun factorial_wr(new_n, result) =
                        if new_n = [0] then result
                        else factorial_wr( decr new_n, (karatsuba result new_n)  ) ;

                val new_n = fromString( factorial_pre n )
            in
                toString( factorial_wr(new_n, [1]) )
            end

            handle Invalid_Input_exception (msg) => (print("Invalid_Input_exception : " ^ msg ^ "\n") ; "")
end ;