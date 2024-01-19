
(define-trait sip-010-trait
  (
    (get-name () (response (string-ascii 32) uint))    

    (get-balance (principal) (response uint uint))

    (transfer (uint principal principal (optional (buff 34))) (response bool uint))
 )
)


(define-trait executor-trait
  (
    (execute (uint uint) (response (list 2 uint) uint))
  )
)
