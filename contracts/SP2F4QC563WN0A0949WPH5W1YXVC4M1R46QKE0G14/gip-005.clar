(use-trait ft-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)

(define-constant ERR-ONLY-OWNER (err u1000))
(define-data-var owner principal tx-sender)

(define-public (move-funds-to-vault (tokens (list 500 <ft-trait>)))
  (begin 
    (asserts! (is-eq tx-sender (var-get owner)) ERR-ONLY-OWNER)
    (ok (fold move tokens u0))
  )
)

(define-private (move (token <ft-trait>) (acc uint))
  (let
    (
      (bal (unwrap-panic (contract-call? .memegoat-stakepool-vault-v1 get-balance token)))
    )
    (unwrap-panic (contract-call? .memegoat-stakepool-vault-v1 transfer-ft token bal .memegoat-vault))
    (+ u1 acc)
  )
)