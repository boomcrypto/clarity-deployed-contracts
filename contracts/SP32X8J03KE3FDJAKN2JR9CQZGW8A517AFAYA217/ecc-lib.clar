(define-data-var empty-buff (buff 256) (keccak256 0))
(define-data-var tmp int 0)
(define-data-var result (tuple (x int) (y int)) (tuple (x 0) (y 0)))
(define-data-var tmp-point (tuple (x int) (y int)) (tuple (x 0) (y 0)))


(define-private (is-zero-point (p (tuple (x int) (y int)))) 
(ok (and (is-eq (get x p) 0)
    (is-eq (get y p) 0))))

(define-public (ecc-add (p1 (tuple (x int) (y int)))
                        (p2 (tuple (x int) (y int))))
(if (unwrap-panic (is-zero-point p1))
    (ok p2)
    (if (unwrap-panic (is-zero-point p2))
    (ok p1)
    (if (and (is-eq (get x p1) (get x p2)) (is-eq (get y p1) (get y p2)))
        (if (is-eq (get y p1) 0) 
            (ok (tuple (x 0) (y 0)))
            (let 
                ((m (/ (* 3 (* (get x p1) (get x p1))) (* 2 (get y p1))))) 
                (let ((x (- (* m m) (* 2 (get x p1))))) 
                    (ok (tuple (x x ) ( y (- (* m (- (get x p1) x)) (get y p1))))))))
        (if (is-eq (get x p1) (get x p2)) 
            (ok (tuple (x 0) (y 0)))
            (let 
                ((m (/ (- (get y p2) (get y p1)) (- (get x p2) (get x p1))))) 
                (let ((x (- (- (* m m) (get x p1)) (get x p2)))) 
                    (ok (tuple (x x) (y (- (* m (- (get x p1) x)) (get y p1))))))))
        ))))

(define-private (mul-bit (b (buff 1))) 
(begin
    (if (is-eq (mod (var-get tmp) 2) 1)
        (var-set result 
                (unwrap-panic (ecc-add 
                    (var-get result) 
                    (var-get tmp-point))))
        false
        )
    (var-set tmp-point 
        (unwrap-panic (ecc-add 
            (var-get tmp-point) 
            (var-get tmp-point))))
    (var-set tmp 
        (/ (var-get tmp) 2)) 
    ))

(define-public (ecc-mul (p (tuple (x int) (y int)))
                        (scalar int))
(begin (var-set tmp scalar)
    (var-set result (tuple (x 0) (y 0)))
    (var-set tmp-point p)
    (map mul-bit 
        (var-get empty-buff))
        (ok (var-get result))))