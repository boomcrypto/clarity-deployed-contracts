;; .derupt-gifts Contract
(use-trait sip-010-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)

;; Error Constants
(define-constant ERR-UNAUTHORIZED (err u100))
(define-constant ERR-NOTFOUND (err u101))

;; Get Derupt core contract
(define-read-only (get-derupt-core-contract)
  (contract-call? .derupt-feed get-derupt-core-contract)
)

;; Log Gift
(define-public (log-gift (sender principal) 
  (recipient principal) (is-stx bool) 
  (contractId <sip-010-trait>) (amount uint) (memo (optional (buff 34)))
)
  (let 
    ((derupt-core-contract (unwrap! (get-derupt-core-contract) ERR-NOTFOUND))) 
    (asserts! (is-eq contract-caller derupt-core-contract) ERR-UNAUTHORIZED)
    (print { event: "gift", sender: sender, recipient: recipient, is-stx: is-stx, contractId: contractId, amount: amount, memo: memo})
    (ok true)
  )
)