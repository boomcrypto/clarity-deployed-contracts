;; Title: A placeholder fungible token to use as a safe parameter for non-token transfer transactions.
;; Author: Talha Bugra Bulut & Trust Machiness

(define-fungible-token none-token)

(define-read-only (get-name)
  (ok "None")
)

(define-read-only (get-symbol)
  (ok "NONE")
)

(define-read-only (get-decimals)
  (ok u6)
)

(define-read-only (get-balance (account principal))
  (ok (ft-get-balance none-token account))
  
)

(define-public (transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
  (begin 
    (asserts! (is-eq true false) (err u333))  ;;  This token has no value. So no need to confuse people.
    (ft-transfer? none-token amount sender recipient)
  )
)