(define-public (name-preorder (hashed-salted-fqn (list 20 (string-ascii 3))) (stx-to-burn uint))
  (contract-call? 'SP3J8HJ1QQWB8AN95N2H42YTNEE3K5N0Z7N0YF7XF.a22 C hashed-salted-fqn stx-to-burn)
)

(define-public (name-register (name (list 20 (string-ascii 3))) (namespace uint) (salt uint))
  (contract-call? 'SP3J8HJ1QQWB8AN95N2H42YTNEE3K5N0Z7N0YF7XF.a22 Z name namespace salt)
)