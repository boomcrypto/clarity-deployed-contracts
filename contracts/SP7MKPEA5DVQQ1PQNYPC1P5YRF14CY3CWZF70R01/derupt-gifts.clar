;; .derupt-gifts Contract
;; (use-trait sip-010-trait 'ST3D8PX7ABNZ1DPP9MRRCYQKVTAC16WXJ7VCN3Z97.sip-010-trait-ft-standard.sip-010-trait)
(use-trait sip-010-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)

;; (use-trait derupt-ext-trait 'ST1ZK0A249B4SWAHVXD70R13P6B5HNKZAA0WNTJTR.derupt-ext-trait.derupt-ext)
(use-trait derupt-ext-trait 'SP7MKPEA5DVQQ1PQNYPC1P5YRF14CY3CWZF70R01.derupt-ext-trait.derupt-ext)

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
  (contractId <sip-010-trait>) (amount uint) (memo (optional (buff 34))) (ext (optional <derupt-ext-trait>))
)
  (let 
    ((derupt-core-contract (unwrap! (get-derupt-core-contract) ERR-NOTFOUND))) 
    (asserts! (is-eq contract-caller derupt-core-contract) ERR-UNAUTHORIZED)
    (print { event: "gift", sender: sender, recipient: recipient, is-stx: is-stx, contractId: contractId, amount: amount, memo: memo, ext: ext})
    (ok true)
  )
)