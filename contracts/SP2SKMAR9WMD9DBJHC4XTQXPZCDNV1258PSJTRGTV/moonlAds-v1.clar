(define-data-var price uint u5000000)
(define-constant contract-owner tx-sender)

(define-public (buy-ads-slot (sender principal))
  (begin
    (asserts! (is-eq sender tx-sender) (err u401)) 
    (try! (stx-transfer? (var-get price) tx-sender 'SP378EYJ80BQJJ0WTBPJ9Z7TWFV2C7A096KREFKBP))
    (ok true)
  )
)

(define-public (change-price (amount uint))
    (begin
        (asserts! (and (is-eq contract-owner tx-sender) (is-eq contract-owner contract-caller)) (err u401))
        (ok (var-set price amount))
    )
)