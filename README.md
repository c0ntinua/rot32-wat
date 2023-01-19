
# rot32-wat

This program was written directly in the text format of Web Assembly. It simply generates a random 32-bit CA rule and uses that rule as its own seed, updating it 32 times and displaying the result in unicode blocks.
![Screenshot 2023-01-19 at 7 21 35 AM](https://user-images.githubusercontent.com/90075803/213445121-467115d1-c4a9-4208-9522-7f84d533e5ed.png)

![Screenshot 2023-01-19 at 7 22 16 AM](https://user-images.githubusercontent.com/90075803/213445173-8cfd0cd1-a0ed-4731-a2fe-0829f7e45277.png)


![Screenshot 2023-01-19 at 7 21 35 AM](https://user-images.githubusercontent.com/90075803/213445233-744e86b6-7aeb-4ef8-869f-40bae4b47909.png)


The crucial logic is in these functions :

    (func $neighbor_code (param $x i32) ( param $i i32) (result i32)
        (i32.rotr ( i32.and ( i32.rotl (i32.const 31 ) (local.get $i)) (local.get $x) ) (local.get $i))
    )
    (func $eval (param $f i32) (param $i i32) (result i32)
        (i32.rotr (i32.and ( i32.rotl (i32.const 1) (local.get $i) ) (  local.get $f )) (local.get $i))
    )
    (func $next (param $s i32) (param $f i32) (param $i i32) (result i32)
        (i32.rotl (call $eval (local.get $f) (call $neighbor_code (local.get $s) (local.get $i))) (i32.add (local.get $i) (i32.const 3)))
    
    )
    (func $turn (param $s i32) (param $f i32) (result i32)
        (local $i i32)
        (local $r i32)
        (local.set $r (i32.const 0))
        (local.set $i (i32.const 0)) 
        (loop $loop 
            (local.set $r (i32.or (local.get $r) (call $next (local.get $s) (local.get $f)(local.get $i))))
            (local.set $i (i32.add (local.get $i) (i32.const 1)))
            (br_if $loop (i32.ge_s (i32.const 32) (local.get $i)))
            
        )
        (local.get $r)
    )


