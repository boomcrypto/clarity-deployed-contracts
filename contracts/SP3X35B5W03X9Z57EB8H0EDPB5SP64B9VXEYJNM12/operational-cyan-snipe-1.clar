(define-read-only (xor-read (left uint) (right uint))
    (xor left right)
)

(define-public (xor-public (left uint) (right uint))
    (ok (xor left right))
)