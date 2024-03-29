
;; uint256-private-lib
;; <add a description here>

;; constants
;;

;; data maps and vars
;;

;; private functions
;;

;; public functions
;;
(define-constant iter-buff-64 0x00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000)
(define-constant iter-buff-256 0x00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000)
(define-constant uint64-max u18446744073709551615)
(define-constant uint64-max-limit u18446744073709551616)
(define-constant uint256-zero (tuple (i0 u0) (i1 u0) (i2 u0) (i3 u0)))
(define-constant uint256-one (tuple (i0 u0) (i1 u0) (i2 u0) (i3 u1)))

(define-private (uint256-add (a (tuple (i0 uint) (i1 uint) (i2 uint) (i3 uint)))
                            (b (tuple (i0 uint) (i1 uint) (i2 uint) (i3 uint)))) 
    (let ((i3 (+ (get i3 a) (get i3 b))))
        (let ((i2 (+ (get i2 a) (get i2 b)
            (if (> i3 uint64-max) (/ i3 uint64-max-limit) u0))))
        (let ((i1 (+ (get i1 a) (get i1 b)
            (if (> i2 uint64-max) (/ i2 uint64-max-limit) u0))))
        (let ((i0 (+ (get i0 a) (get i0 b)
            (if (> i1 uint64-max) (/ i1 uint64-max-limit) u0))))
            (tuple (i0 i0) 
            (i1 ( if (> (/ i1 uint64-max-limit) u0) (mod i1 uint64-max-limit) i1)) 
            (i2 ( if (> (/ i2 uint64-max-limit) u0) (mod i2 uint64-max-limit) i2)) 
            (i3 ( if (> (/ i3 uint64-max-limit) u0) (mod i3 uint64-max-limit) i3))))))))

(define-private (uint256-cmp (a (tuple (i0 uint) (i1 uint) (i2 uint) (i3 uint)))
                            (b (tuple (i0 uint) (i1 uint) (i2 uint) (i3 uint))))
    (if (is-eq (get i0 a) (get i0 b))
    (if (is-eq (get i1 a) (get i1 b))
        (if (is-eq (get i2 a) (get i2 b))
            (if (is-eq (get i3 a) (get i3 b))
                0
                (if (> (get i3 a) (get i3 b)) 1 -1))
            (if (> (get i2 a) (get i2 b)) 1 -1))
        (if (> (get i1 a) (get i1 b)) 1 -1))
    (if (> (get i0 a) (get i0 b)) 1 -1)))

(define-private (uint256-add-short (a (tuple (i0 uint) (i1 uint) (i2 uint) (i3 uint)))
                            (b uint))
(uint256-add a (tuple (i0 u0) (i1 u0) (i2 (/ b uint64-max-limit)) (i3 (mod b uint64-max-limit)))))

(define-private (uint256-is-eq (a (tuple (i0 uint) (i1 uint) (i2 uint) (i3 uint)))
                            (b (tuple (i0 uint) (i1 uint) (i2 uint) (i3 uint))))
(is-eq (uint256-cmp a b) 0))

(define-private (uint256> (a (tuple (i0 uint) (i1 uint) (i2 uint) (i3 uint)))
                            (b (tuple (i0 uint) (i1 uint) (i2 uint) (i3 uint))))
(> (uint256-cmp a b) 0))

(define-private (uint256< (a (tuple (i0 uint) (i1 uint) (i2 uint) (i3 uint)))
                            (b (tuple (i0 uint) (i1 uint) (i2 uint) (i3 uint))))
(< (uint256-cmp a b) 0))

(define-private (uint256-is-zero (a (tuple (i0 uint) (i1 uint) (i2 uint) (i3 uint))))
(if (is-eq (get i0 a) u0)
    (if (is-eq (get i1 a) u0)
        (if (is-eq (get i2 a) u0)
            (if (is-eq (get i3 a) u0)
                true
                false)
            false)
        false)
    false))

(define-private (loop-bits-iter (i (buff 1))
                                (val (tuple (num uint) (res uint))))                         
(if (> (get num val) u0) 
    (tuple (num (/ (get num val) u2)) (res (+ (get res val) u1))) 
    (tuple (num u0) (res (get res val)))))

(define-private (loop-bits (num uint)) 
(get res (fold loop-bits-iter iter-buff-64 (tuple (num num) (res u0)))))

(define-private (uint256-bits (a (tuple (i0 uint) (i1 uint) (i2 uint) (i3 uint))))
    (if (is-eq (get i0 a) u0) 
    (if (is-eq (get i1 a) u0) 
        (if (is-eq (get i2 a) u0) 
            (loop-bits (get i3 a))
            (+ (loop-bits (get i2 a)) u64)) 
        (+ (loop-bits (get i1 a)) u128)) 
    (+ (loop-bits (get i0 a)) u192)))

(define-private (uint256-bits-64 (a (tuple (i0 uint) (i1 uint) (i2 uint) (i3 uint))))
    (if (is-eq (get i0 a) u0) 
    (if (is-eq (get i1 a) u0) 
        (if (is-eq (get i2 a) u0) 
            (if (is-eq (get i3 a) u0) 
                u0
                u1)
            u2) 
        u3) 
    u4))

(define-private (uint256-rshift-64-overflow (a (tuple (i0 uint) (i1 uint) (i2 uint) (i3 uint))))
(tuple (i0 (get i1 a)) (i1 (get i2 a)) (i2 (get i3 a)) (i3 u0)))

(define-private (uint256-rshift-overflow (a (tuple (i0 uint) (i1 uint) (i2 uint) (i3 uint)))
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
            (tuple 
                (i0 i0)
                (i1 (if (> (/ i1 uint64-max-limit) u0) (mod i1 uint64-max-limit) i1)) 
                (i2 (if (> (/ i2 uint64-max-limit) u0) (mod i2 uint64-max-limit) i2)) 
                (i3 (if (> (/ i3 uint64-max-limit) u0) (mod i3 uint64-max-limit) i3))))))))
    (if (< b u256)
        (let ((r (pow u2 (- b u128))))
                (let ((i1 (* (get i3 a) r)))
                (let ((i0 (+ (* (get i2 a) r)
                    (if (> i1 uint64-max) (/ i1 uint64-max-limit) u0))))
                (tuple 
                    (i0 (if (> (/ i0 uint64-max-limit) u0) (mod i0 uint64-max-limit) i0))
                    (i1 (if (> (/ i1 uint64-max-limit) u0) (mod i1 uint64-max-limit) i1)) 
                    (i2 u0) 
                    (i3 u0)))))
        uint256-zero)
    ))

(define-private (uint256-lshift-1 (a (tuple (i0 uint) (i1 uint) (i2 uint) (i3 uint))))
(let ((r u2))
    (let ((i0 (get i0 a)))
        (let ((i1 (+ (* (mod i0 r) uint64-max-limit) (get i1 a))))
        (let ((i2 (+ (* (mod i1 r) uint64-max-limit) (get i2 a))))
        (let ((i3 (+ (* (mod i2 r) uint64-max-limit) (get i3 a))))
            (tuple 
            (i0 (/ i0 r))
            (i1 (/ i1 r)) 
            (i2 (/ i2 r)) 
            (i3 (/ i3 r)))))))))

(define-private (uint256-check-bit (a (tuple (i0 uint) (i1 uint) (i2 uint) (i3 uint))) (b uint))
(if (> b u256) u0
(let ((v (if (is-eq (/ b u64) u3) 
    (get i0 a) 
    (if (is-eq (/ b u64) u2) 
        (get i1 a) 
        (if (is-eq (/ b u64) u1) 
            (get i2 a) 
            (get i3 a))))))
        (mod (/ v (pow u2 (mod b u64))) u2))
))

(define-private (uint256-sub (a (tuple (i0 uint) (i1 uint) (i2 uint) (i3 uint)))
                            (b (tuple (i0 uint) (i1 uint) (i2 uint) (i3 uint)))) 
(let ((i (if (uint256> a b) a b)) (j (if (uint256> a b) b a )))
    (let ((i3 (- (to-int (get i3 i)) (to-int (get i3 j)))))
        (let ((i2 (- (- (to-int (get i2 i)) (to-int (get i2 j)))
            (if (< i3 0) 1 0))))
        (let ((i1 (- (- (to-int (get i1 i)) (to-int (get i1 j))) 
            (if (< i2 0) 1 0))))
        (let ((i0 (- (- (to-int (get i0 i)) (to-int (get i0 j)))
            (if (< i1 0) 1 0))))
            (tuple (i0 (to-uint i0)) 
            (i1 (mod (to-uint (if (< i1 0) (+ (to-int uint64-max-limit) i1) i1)) uint64-max-limit)) 
            (i2 (mod (to-uint (if (< i2 0) (+ (to-int uint64-max-limit) i2) i2)) uint64-max-limit)) 
            (i3 (mod (to-uint (if (< i3 0) (+ (to-int uint64-max-limit) i3) i3)) uint64-max-limit)))))))
    ))

(define-private (uint256-mul-short (a (tuple (i0 uint) (i1 uint) (i2 uint) (i3 uint)))
                            (b uint))
(let ((i3 (* (get i3 a) b)))
    (let ((i2 (+  (* (get i2 a) b)
        (if (> i3 uint64-max) (/ i3 uint64-max-limit) u0))))
    (let ((i1 (+ (* (get i1 a) b) 
        (if (> i2 uint64-max) (/ i2 uint64-max-limit) u0))))
    (let ((i0 (+ (* (get i0 a) b)
        (if (> i1 uint64-max) (/ i1 uint64-max-limit) u0))))
        (tuple 
        (i0 i0)
        (i1 ( if (> (/ i1 uint64-max-limit) u0) (mod i1 uint64-max-limit) i1)) 
        (i2 ( if (> (/ i2 uint64-max-limit) u0) (mod i2 uint64-max-limit) i2)) 
        (i3 ( if (> (/ i3 uint64-max-limit) u0) (mod i3 uint64-max-limit) i3))))))))

(define-private (uint256-mul (a (tuple (i0 uint) (i1 uint) (i2 uint) (i3 uint)))
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
        (tuple 
        (i0 i0)
        (i1 ( if (> (/ i1 uint64-max-limit) u0) (mod i1 uint64-max-limit) i1)) 
        (i2 ( if (> (/ i2 uint64-max-limit) u0) (mod i2 uint64-max-limit) i2)) 
        (i3 ( if (> (/ i3 uint64-max-limit) u0) (mod i3 uint64-max-limit) i3)) 
        (i4 ( if (> (/ i4 uint64-max-limit) u0) (mod i4 uint64-max-limit) i4)) 
        (i5 ( if (> (/ i5 uint64-max-limit) u0) (mod i5 uint64-max-limit) i5)) 
        (i6 ( if (> (/ i6 uint64-max-limit) u0) (mod i6 uint64-max-limit) i6)) 
        (i7 ( if (> (/ i7 uint64-max-limit) u0) (mod i7 uint64-max-limit) i7))))))))))))

(define-private (loop-div-iter (i (buff 1))
                                (val (tuple (p uint) 
                                (q (tuple (i0 uint) (i1 uint) (i2 uint) (i3 uint))) 
                                (r (tuple (i0 uint) (i1 uint) (i2 uint) (i3 uint)))
                                (a (tuple (i0 uint) (i1 uint) (i2 uint) (i3 uint)))
                                (b (tuple (i0 uint) (i1 uint) (i2 uint) (i3 uint))))))
(let ((t (uint256-rshift-overflow (get r val) u1)))
    (if (uint256< t (get b val))
    (tuple 
        (p (+ (get p val) u1)) 
        (a (get a val)) 
        (b (get b val)) 
        (q (get q val))
        (r (uint256-add-short 
            t 
            (uint256-check-bit (get a val) (- u255 (get p val))))))
    (tuple 
        (p (+ (get p val) u1)) 
        (a (get a val)) 
        (b (get b val)) 
        (q (uint256-add (get q val)
            (uint256-rshift-overflow uint256-one (- u255 (get p val)))))
        (r  (uint256-sub (uint256-add-short 
            t 
            (uint256-check-bit (get a val) (- u255 (get p val))))
            (get b val)))))))

(define-private (uint256-div (a (tuple (i0 uint) (i1 uint) (i2 uint) (i3 uint)))
                            (b (tuple (i0 uint) (i1 uint) (i2 uint) (i3 uint)))) 
(if (uint256-is-zero b)
    uint256-zero
    (get q (fold loop-div-iter iter-buff-256 (tuple (p u0) (a a) (b b) (q uint256-zero) (r uint256-zero))))))

(define-private (uint256-mod (a (tuple (i0 uint) (i1 uint) (i2 uint) (i3 uint)))
                            (b (tuple (i0 uint) (i1 uint) (i2 uint) (i3 uint)))) 
(if (uint256-is-zero b)
    uint256-zero
    (get r (fold loop-div-iter iter-buff-256 (tuple (p u0) (a a) (b b) (q uint256-zero) (r uint256-zero))))))

(define-private (uint512-to-uint256-overflow (a (tuple (i0 uint) (i1 uint) (i2 uint) (i3 uint) (i4 uint) (i5 uint) (i6 uint) (i7 uint))))
    (tuple 
    (i0 (get i4 a))
    (i1 (get i5 a)) 
    (i2 (get i6 a)) 
    (i3 (get i7 a))))


(define-private (uint-to-uint256 (a uint))
    (tuple 
    (i0 u0)
    (i1 u0) 
    (i2 (/ a uint64-max-limit)) 
    (i3 (mod a uint64-max-limit))))

(define-private (uint256-mul-mod (a (tuple (i0 uint) (i1 uint) (i2 uint) (i3 uint)))
                            (b (tuple (i0 uint) (i1 uint) (i2 uint) (i3 uint))) 
                            (m (tuple (i0 uint) (i1 uint) (i2 uint) (i3 uint))))

    (let ((a-mod (uint256-mod a m)) (b-mod (uint256-mod b m)))
    (uint256-mod (uint512-to-uint256-overflow 
        (uint256-mul 
            a-mod  
            b-mod)) m)))

(define-private (uint256-mul-mod-short (a (tuple (i0 uint) (i1 uint) (i2 uint) (i3 uint)))
                            (b uint) 
                            (m (tuple (i0 uint) (i1 uint) (i2 uint) (i3 uint))))

    (uint256-mod
        (uint256-mul-short a b) m))

