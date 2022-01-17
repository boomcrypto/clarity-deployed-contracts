(define-constant contract-owner tx-sender)
(define-constant burn-earn-stx u1000000)
(define-public (load-up-contract (amount uint))
  (begin
    (asserts! (is-eq tx-sender contract-owner) (err u101))
    (ok (stx-transfer? amount tx-sender (as-contract tx-sender)))
  )
)
(define-public (test-send-as-contract)
  (begin
    (asserts! (is-eq tx-sender contract-owner) (err u101))
    (ok (as-contract (stx-transfer? burn-earn-stx (as-contract tx-sender) tx-sender)))
  )
)