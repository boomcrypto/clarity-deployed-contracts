(use-trait ft-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)

;; priviliged calls

(define-public (re-route-ft (token-1 <ft-trait>) (amount-1 uint) (token-2 <ft-trait>) (amount-2 uint) (recipient principal))
  (begin     
    (try! (contract-call? token-1 transfer amount-1 tx-sender recipient none))
    (try! (contract-call? token-2 transfer amount-2 tx-sender recipient none))
    (ok true)
  )
)
