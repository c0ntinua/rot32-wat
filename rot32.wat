(module
    (import "wasi_unstable" "fd_write" (func $fd_write (param i32 i32 i32 i32) (result i32)))
    (import "wasi_unstable" "random_get" (func $random_get (param i32 i32) (result i32) ))
    (global $stdout i32 (i32.const 1))
    (global $iovecp i32 (i32.const 0))
    (global $iovecl i32 (i32.const 4))
    (global $out i32 (i32.const 8))
    (memory 1)
    (export "memory" (memory 0))
    (func $print (param $byte i32)
        (local $location i32)
        (local.set $location (i32.const 100))
        (i32.store (get_global $iovecp) (get_local $location))
        (i32.store (get_global $iovecl) (i32.const 1)) 
        (i32.store (get_local $location) (get_local $byte))
        (call $fd_write 
            (get_global $stdout) 
            (get_global $iovecp) 
            (get_global $iovecl)
            (local.get $location)
        )
        (drop)
    )
    (func $print_bit_as_block (param $bit i32)
        (if (local.get $bit) 
            (then (call $print_block ))
            (else (call $print (i32.const 0x20)))
        )
    )
    (func $ith_bit (param $x i32) (param $i i32) (result i32)
        (local $mask i32)
        (local.set $mask (i32.rotl (i32.const 1) (local.get $i)))
        (local.set $mask (i32.and (local.get $mask) (local.get $x)))
        (i32.rotr (local.get $mask) (local.get $i) )
    )
    (func $print_block 
        (call $print (i32.const 0xE2))
        (call $print (i32.const 0x96))
        (call $print (i32.const 0x88))
    )
    (func $as_ascii (param $bit i32) (result i32)
        (i32.add (get_local $bit) (i32.const 0x30))
    )
    (func $print_i32_as_blocks (param $x i32) 
        (local $i i32 ) 
        (local.set $i (i32.const 31))
        (loop $loop
            (call $print_bit_as_block ( call $ith_bit (local.get $x) (local.get $i) ))
            (call $print_bit_as_block ( call $ith_bit (local.get $x) (local.get $i) ))  
            (local.set $i (i32.sub (local.get $i) (i32.const 1))) 
            (br_if $loop (i32.le_s (i32.const 0) (local.get $i) ))
        )
    )
    (func $rand_32 (result i32)
        (call $random_get (get_global $iovecp) (i32.const 4) )
        drop
        (i32.load (get_global $iovecp))
    )
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
    (func $main (export "_start")
        (local $f i32)
        (local $s i32)
        (local $i i32)
        (local.set $f (call $rand_32))
        (local.set $s (local.get $f))    
        (local.set $i (i32.const 0)) 
        (loop $loop 
            (local.set $s (call $turn (local.get $s) (local.get $f)))
            (call $print_i32_as_blocks (local.get $s))
            (call $print (i32.const 0x0A))
            (local.set $i (i32.add (local.get $i) (i32.const 1)))
            (br_if $loop (i32.ge_s (i32.const 32) (local.get $i)))
        )
        (call $print (i32.const 0x0A))
    )
)