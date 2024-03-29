
;; uint256-lib
;; <add a description here>

;; constants
;;

;; data maps and vars
;;

;; private functions
;;

;; public functions
;;
(define-constant iter-buff-32 (keccak256 0))
(define-constant iter-buff-64 0x00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000)
(define-constant iter-buff-256 0x00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000)
(define-constant uint64-max u18446744073709551615)
(define-constant uint64-max-limit u18446744073709551616)
(define-constant uint256-zero (tuple (i0 u0) (i1 u0) (i2 u0) (i3 u0)))
(define-constant uint256-one (tuple (i0 u0) (i1 u0) (i2 u0) (i3 u1)))
(define-data-var tmp-uint256 (tuple (i0 uint) (i1 uint) (i2 uint) (i3 uint)) uint256-zero)

(define-public (uint256-add (a (tuple (i0 uint) (i1 uint) (i2 uint) (i3 uint)))
                            (b (tuple (i0 uint) (i1 uint) (i2 uint) (i3 uint)))) 
    (let ((i3 (+ (get i3 a) (get i3 b))))
        (let ((i2 (+ (get i2 a) (get i2 b)
            (if (> i3 uint64-max) (/ i3 uint64-max-limit) u0))))
        (let ((i1 (+ (get i1 a) (get i1 b)
            (if (> i2 uint64-max) (/ i2 uint64-max-limit) u0))))
        (let ((i0 (+ (get i0 a) (get i0 b)
            (if (> i1 uint64-max) (/ i1 uint64-max-limit) u0))))
        (ok (tuple (i0 i0) 
            (i1 ( if (> (/ i1 uint64-max-limit) u0) (mod i1 uint64-max-limit) i1)) 
            (i2 ( if (> (/ i2 uint64-max-limit) u0) (mod i2 uint64-max-limit) i2)) 
            (i3 ( if (> (/ i3 uint64-max-limit) u0) (mod i3 uint64-max-limit) i3)))))))))

(define-public (uint256-cmp (a (tuple (i0 uint) (i1 uint) (i2 uint) (i3 uint)))
                            (b (tuple (i0 uint) (i1 uint) (i2 uint) (i3 uint))))
    (ok (if (is-eq (get i0 a) (get i0 b))
        (if (is-eq (get i1 a) (get i1 b))
            (if (is-eq (get i2 a) (get i2 b))
                (if (is-eq (get i3 a) (get i3 b))
                    0
                    (if (> (get i3 a) (get i3 b)) 1 -1))
                (if (> (get i2 a) (get i2 b)) 1 -1))
            (if (> (get i1 a) (get i1 b)) 1 -1))
        (if (> (get i0 a) (get i0 b)) 1 -1))))

(define-public (uint256-add-short (a (tuple (i0 uint) (i1 uint) (i2 uint) (i3 uint)))
                            (b uint))
    (uint256-add a (tuple (i0 u0) (i1 u0) (i2 (/ b uint64-max-limit)) (i3 (mod b uint64-max-limit)))))

(define-public (uint256-is-eq (a (tuple (i0 uint) (i1 uint) (i2 uint) (i3 uint)))
                            (b (tuple (i0 uint) (i1 uint) (i2 uint) (i3 uint))))
    (ok (is-eq (unwrap-panic (uint256-cmp a b)) 0)))

(define-public (uint256> (a (tuple (i0 uint) (i1 uint) (i2 uint) (i3 uint)))
                            (b (tuple (i0 uint) (i1 uint) (i2 uint) (i3 uint))))
    (ok (> (unwrap-panic (uint256-cmp a b)) 0)))

(define-public (uint256< (a (tuple (i0 uint) (i1 uint) (i2 uint) (i3 uint)))
                            (b (tuple (i0 uint) (i1 uint) (i2 uint) (i3 uint))))
    (ok (< (unwrap-panic (uint256-cmp a b)) 0)))

(define-public (uint256-is-zero (a (tuple (i0 uint) (i1 uint) (i2 uint) (i3 uint))))
    (ok (if (is-eq (get i0 a) u0)
        (if (is-eq (get i1 a) u0)
            (if (is-eq (get i2 a) u0)
                (if (is-eq (get i3 a) u0)
                    true
                    false)
                false)
            false)
        false)))

(define-private (loop-bits-iter (i (buff 1))
                                (val (tuple (num uint) (res uint))))                         
    (if (> (get num val) u0) 
        (tuple (num (/ (get num val) u2)) (res (+ (get res val) u1))) 
        (tuple (num u0) (res (get res val)))))

(define-private (loop-bits (num uint)) 
    (ok (get res (fold loop-bits-iter iter-buff-64 (tuple (num num) (res u0))))))

(define-public (uint256-bits (a (tuple (i0 uint) (i1 uint) (i2 uint) (i3 uint))))
    (ok (if (is-eq (get i0 a) u0) 
        (if (is-eq (get i1 a) u0) 
            (if (is-eq (get i2 a) u0) 
                (unwrap-panic (loop-bits (get i3 a)))
                (+ (unwrap-panic (loop-bits (get i2 a))) u64)) 
            (+ (unwrap-panic (loop-bits (get i1 a))) u128)) 
        (+ (unwrap-panic (loop-bits (get i0 a))) u192))))

(define-public (uint256-bits-64 (a (tuple (i0 uint) (i1 uint) (i2 uint) (i3 uint))))
    (ok (if (is-eq (get i0 a) u0) 
        (if (is-eq (get i1 a) u0) 
            (if (is-eq (get i2 a) u0) 
                (if (is-eq (get i3 a) u0) 
                    u0
                    u1)
                u2) 
            u3) 
        u4)))

(define-public (uint256-rshift-64-overflow (a (tuple (i0 uint) (i1 uint) (i2 uint) (i3 uint))))
    (ok (tuple (i0 (get i1 a)) (i1 (get i2 a)) (i2 (get i3 a)) (i3 u0))))

(define-public (uint256-rshift-overflow (a (tuple (i0 uint) (i1 uint) (i2 uint) (i3 uint)))
                               (b uint))
    (if (< b u128)
        (let ((r (pow u2 b)))
            (let ((i3 (* (get i3 a) r)))
                (let ((i2 (+ (* (get i2 a) r)
                    (if (> i3 uint64-max) (/ i3 uint64-max-limit) u0))))
                (let ((i1 (+ (* (get i1 a) r)
                    (if (> i2 uint64-max) (/ i2 uint64-max-limit) u0))))
                (let ((i0 (+ (* (get i0 a) r)
                    (if (> i1 uint64-max) (/ i1 uint64-max-limit) u0))))
                (ok (tuple 
                    (i0 i0)
                    (i1 (if (> (/ i1 uint64-max-limit) u0) (mod i1 uint64-max-limit) i1)) 
                    (i2 (if (> (/ i2 uint64-max-limit) u0) (mod i2 uint64-max-limit) i2)) 
                    (i3 (if (> (/ i3 uint64-max-limit) u0) (mod i3 uint64-max-limit) i3)))))))))
        (if (< b u256)
            (let ((r (pow u2 (- b u128))))
                    (let ((i1 (* (get i3 a) r)))
                    (let ((i0 (+ (* (get i2 a) r)
                        (if (> i1 uint64-max) (/ i1 uint64-max-limit) u0))))
                    (ok (tuple 
                        (i0 (if (> (/ i0 uint64-max-limit) u0) (mod i0 uint64-max-limit) i0))
                        (i1 (if (> (/ i1 uint64-max-limit) u0) (mod i1 uint64-max-limit) i1)) 
                        (i2 u0) 
                        (i3 u0))))))
            (ok uint256-zero))
        ))

(define-public (uint256-lshift-1 (a (tuple (i0 uint) (i1 uint) (i2 uint) (i3 uint))))
    (let ((r u2))
        (let ((i0 (get i0 a)))
            (let ((i1 (+ (* (mod i0 r) uint64-max-limit) (get i1 a))))
            (let ((i2 (+ (* (mod i1 r) uint64-max-limit) (get i2 a))))
            (let ((i3 (+ (* (mod i2 r) uint64-max-limit) (get i3 a))))
            (ok (tuple 
                (i0 (/ i0 r))
                (i1 (/ i1 r)) 
                (i2 (/ i2 r)) 
                (i3 (/ i3 r))))))))))

(define-public (uint256-check-bit (a (tuple (i0 uint) (i1 uint) (i2 uint) (i3 uint))) (b uint))
    (if (> b u256) (err 1)
        (let ((v (if (is-eq (/ b u64) u3) 
            (get i0 a) 
            (if (is-eq (/ b u64) u2) 
                (get i1 a) 
                (if (is-eq (/ b u64) u1) 
                    (get i2 a) 
                    (get i3 a))))))
            (ok (mod (/ v (pow u2 (mod b u64))) u2)))
        ))

(define-public (uint256-sub (a (tuple (i0 uint) (i1 uint) (i2 uint) (i3 uint)))
                            (b (tuple (i0 uint) (i1 uint) (i2 uint) (i3 uint))))
    (let ((i (if (unwrap-panic (uint256> a b)) a b)) (j (if (unwrap-panic (uint256> a b)) b a )))                         
        (let ((i3 (- (to-int (get i3 i)) (to-int (get i3 j)))))
            (let ((i2 (- (- (to-int (get i2 i)) (to-int (get i2 j)))
                (if (< i3 0) 1 0))))
            (let ((i1 (- (- (to-int (get i1 i)) (to-int (get i1 j))) 
                (if (< i2 0) 1 0))))
            (let ((i0 (- (- (to-int (get i0 i)) (to-int (get i0 j)))
                (if (< i1 0) 1 0))))
            (ok (tuple (i0 (to-uint i0)) 
                (i1 (mod (to-uint (if (< i1 0) (+ (to-int uint64-max-limit) i1) i1)) uint64-max-limit)) 
                (i2 (mod (to-uint (if (< i2 0) (+ (to-int uint64-max-limit) i2) i2)) uint64-max-limit)) 
                (i3 (mod (to-uint (if (< i3 0) (+ (to-int uint64-max-limit) i3) i3)) uint64-max-limit))))))))
        ))

(define-public (uint256-mul-short (a (tuple (i0 uint) (i1 uint) (i2 uint) (i3 uint)))
                            (b uint))
    (let ((i3 (* (get i3 a) b)))
        (let ((i2 (+  (* (get i2 a) b)
            (if (> i3 uint64-max) (/ i3 uint64-max-limit) u0))))
        (let ((i1 (+ (* (get i1 a) b) 
            (if (> i2 uint64-max) (/ i2 uint64-max-limit) u0))))
        (let ((i0 (+ (* (get i0 a) b)
            (if (> i1 uint64-max) (/ i1 uint64-max-limit) u0))))
        (ok (tuple 
            (i0 i0)
            (i1 ( if (> (/ i1 uint64-max-limit) u0) (mod i1 uint64-max-limit) i1)) 
            (i2 ( if (> (/ i2 uint64-max-limit) u0) (mod i2 uint64-max-limit) i2)) 
            (i3 ( if (> (/ i3 uint64-max-limit) u0) (mod i3 uint64-max-limit) i3)))))))))

(define-public (uint256-mul (a (tuple (i0 uint) (i1 uint) (i2 uint) (i3 uint)))
                            (b (tuple (i0 uint) (i1 uint) (i2 uint) (i3 uint))))
    (let ((i7 (* (get i3 a) (get i3 b))))
        (let ((i6 (+  (* (get i3 a) (get i2 b))
            (if (> i7 uint64-max) (/ i7 uint64-max-limit) u0)
            (* (get i2 a) (get i3 b)))))
        (let ((i5 (+ (* (get i3 a) (get i1 b)) 
            (if (> i6 uint64-max) (/ i6 uint64-max-limit) u0)
            (* (get i1 a) (get i3 b))
            (* (get i2 a) (get i2 b)))))
        (let ((i4 (+ (* (get i3 a) (get i0 b))
            (if (> i5 uint64-max) (/ i5 uint64-max-limit) u0)
            (* (get i0 a) (get i3 b))
            (* (get i1 a) (get i2 b))
            (* (get i2 a) (get i1 b)))))
        (let ((i3 (+ (* (get i0 a) (get i2 b))
            (if (> i4 uint64-max) (/ i4 uint64-max-limit) u0)
            (* (get i1 a) (get i1 b))
            (* (get i2 a) (get i0 b)))))
        (let ((i2 (+ (* (get i0 a) (get i1 b))
            (if (> i3 uint64-max) (/ i3 uint64-max-limit) u0)
            (* (get i1 a) (get i0 b)))))
        (let ((i1 (+ (* (get i0 a) (get i0 b))
            (if (> i2 uint64-max) (/ i2 uint64-max-limit) u0))))
        (let ((i0
            (if (> i1 uint64-max) (/ i1 uint64-max-limit) u0)))
        (ok (tuple 
            (i0 i0)
            (i1 ( if (> (/ i1 uint64-max-limit) u0) (mod i1 uint64-max-limit) i1)) 
            (i2 ( if (> (/ i2 uint64-max-limit) u0) (mod i2 uint64-max-limit) i2)) 
            (i3 ( if (> (/ i3 uint64-max-limit) u0) (mod i3 uint64-max-limit) i3)) 
            (i4 ( if (> (/ i4 uint64-max-limit) u0) (mod i4 uint64-max-limit) i4)) 
            (i5 ( if (> (/ i5 uint64-max-limit) u0) (mod i5 uint64-max-limit) i5)) 
            (i6 ( if (> (/ i6 uint64-max-limit) u0) (mod i6 uint64-max-limit) i6)) 
            (i7 ( if (> (/ i7 uint64-max-limit) u0) (mod i7 uint64-max-limit) i7)))))))))))))

(define-private (loop-div-iter (i (buff 1))
                                (val (tuple (p uint) 
                                (q (tuple (i0 uint) (i1 uint) (i2 uint) (i3 uint))) 
                                (r (tuple (i0 uint) (i1 uint) (i2 uint) (i3 uint)))
                                (a (tuple (i0 uint) (i1 uint) (i2 uint) (i3 uint)))
                                (b (tuple (i0 uint) (i1 uint) (i2 uint) (i3 uint))))))
    (let ((t (unwrap-panic (uint256-rshift-overflow (get r val) u1))))
        (if (unwrap-panic (uint256< t (get b val)))
        (tuple 
            (p (+ (get p val) u1)) 
            (a (get a val)) 
            (b (get b val)) 
            (q (get q val))
            (r (unwrap-panic (uint256-add-short 
                t 
                (unwrap-panic (uint256-check-bit (get a val) (- u255 (get p val))))))))
        (tuple 
            (p (+ (get p val) u1)) 
            (a (get a val)) 
            (b (get b val)) 
            (q (unwrap-panic (uint256-add (get q val)
                (unwrap-panic (uint256-rshift-overflow uint256-one (- u255 (get p val)))))))
            (r (unwrap-panic (uint256-sub (unwrap-panic (uint256-add-short 
                t 
                (unwrap-panic (uint256-check-bit (get a val) (- u255 (get p val))))))
                (get b val))))))))

(define-public (uint256-div (a (tuple (i0 uint) (i1 uint) (i2 uint) (i3 uint)))
                            (b (tuple (i0 uint) (i1 uint) (i2 uint) (i3 uint)))) 
    (if (unwrap-panic (uint256-is-zero b))
        (err 1)
        (ok (get q (fold loop-div-iter iter-buff-256 (tuple (p u0) (a a) (b b) (q uint256-zero) (r uint256-zero)))))))

(define-public (uint256-mod (a (tuple (i0 uint) (i1 uint) (i2 uint) (i3 uint)))
                            (b (tuple (i0 uint) (i1 uint) (i2 uint) (i3 uint)))) 
    (if (unwrap-panic (uint256-is-zero b))
        (err 1)
        (ok (get r (fold loop-div-iter iter-buff-256 (tuple (p u0) (a a) (b b) (q uint256-zero) (r uint256-zero)))))))

(define-public (uint512-to-uint256-overflow (a (tuple (i0 uint) (i1 uint) (i2 uint) (i3 uint) (i4 uint) (i5 uint) (i6 uint) (i7 uint))))
    (ok (tuple 
        (i0 (get i4 a))
        (i1 (get i5 a)) 
        (i2 (get i6 a)) 
        (i3 (get i7 a)))))

(define-public (uint-to-uint256 (a uint))
    (ok (tuple 
        (i0 u0)
        (i1 u0) 
        (i2 (/ a uint64-max-limit)) 
        (i3 (mod a uint64-max-limit)))))

(define-public (uint256-mul-mod (a (tuple (i0 uint) (i1 uint) (i2 uint) (i3 uint)))
                                (b (tuple (i0 uint) (i1 uint) (i2 uint) (i3 uint))) 
                                (m (tuple (i0 uint) (i1 uint) (i2 uint) (i3 uint))))
    (let ((a-mod (unwrap-panic (uint256-mod a m))) (b-mod (unwrap-panic (uint256-mod b m))))
    (uint256-mod (unwrap-panic (uint512-to-uint256-overflow 
        (unwrap-panic (uint256-mul 
            a-mod  
            b-mod)))) m)))

(define-public (uint256-mul-mod-short (a (tuple (i0 uint) (i1 uint) (i2 uint) (i3 uint)))
                            (b uint) 
                            (m (tuple (i0 uint) (i1 uint) (i2 uint) (i3 uint))))
    (uint256-mod
        (unwrap-panic (uint256-mul-short a b)) m))
