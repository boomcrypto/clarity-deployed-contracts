;; Title: A placeholder non-fungible token to use as a safe parameter for non-token transfer transactions.
;; Author: Talha Bugra Bulut & Trust Machiness

(define-non-fungible-token nft-none uint)

(define-read-only (get-last-token-id)
  (ok u99)
)

(define-public (transfer (id uint) (sender principal) (recipient principal))
  (begin 
    (asserts! (is-eq true false) (err u333))  ;;  This token has no value. So no need to confuse people.
    (nft-transfer? nft-none id sender recipient)
  )
)