(define-public (buy-ads-slot (sender principal))
  (begin
    (asserts! (is-eq sender tx-sender) (err u100)) 
    (try! (stx-transfer? u10000000 tx-sender 'SP378EYJ80BQJJ0WTBPJ9Z7TWFV2C7A096KREFKBP))
    (ok true)
  )
)