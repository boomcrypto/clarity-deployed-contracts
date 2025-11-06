(define-constant contract-owner 'SP3DHDMBPFC2PDGCF8VPC4JG0PF2MY2688BBQHE6Y)

;; Define WHYCOIN token
(define-fungible-token WHYCOIN)

;; Mint initial supply directly in contract body - 1,000,000 WHY with 6 decimals
(ft-mint? WHYCOIN u1000000000000 contract-owner)

;; Basic token functions
(define-public (transfer (to principal) (amount uint))
  (begin
    (ft-transfer? WHYCOIN amount tx-sender to)
  )
)

(define-public (mint (to principal) (amount uint))
  (begin
    ;; Only owner can mint
    (asserts! (is-eq tx-sender contract-owner) (err u100))
    (ft-mint? WHYCOIN amount to)
  )
)

(define-public (get-balance (who principal))
  (ok (ft-get-balance WHYCOIN who))
)

(define-public (get-total-supply)
  (ok (ft-get-supply WHYCOIN))
)

(define-public (get-name)
  (ok "WHYCOIN")
)

(define-public (get-symbol)
  (ok "WHY")
)

(define-public (get-decimals)
  (ok u6)
)