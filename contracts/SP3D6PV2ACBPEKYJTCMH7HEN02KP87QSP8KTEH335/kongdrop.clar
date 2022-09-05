(define-constant error-not-authorised (err u401))
(define-constant error-already-claimed (err u402))
(define-constant error-interacting (err u510))

(define-constant contract-owner tx-sender)

(define-constant kong-amount u3233)

(define-private (transfer (amount uint) (recipient principal))
    (contract-call? .mega transfer amount tx-sender recipient none))

(define-public (drop-mega (kong-count uint) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender contract-owner) error-not-authorised)
    (try! (transfer (* kong-amount kong-count) recipient))
    (ok true)))
