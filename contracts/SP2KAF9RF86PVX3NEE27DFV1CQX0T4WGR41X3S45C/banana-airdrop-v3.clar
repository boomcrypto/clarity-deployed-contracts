
(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-NOT-AUTHORIZED u401)

(define-public (admin-airdrop (addresses (list 1000 principal)) (amounts (list 1000 uint)))
  (begin
    (print (map airdrop addresses amounts))
    (ok true)
  )
)

(define-private (airdrop (address principal) (amount uint))
    (contract-call? .btc-monkeys-bananas transfer amount tx-sender address none)
)