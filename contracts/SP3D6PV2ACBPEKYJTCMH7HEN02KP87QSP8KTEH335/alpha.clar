(define-constant error-not-authorised (err u401))
(define-constant error-already-claimed (err u402))

(define-constant contract-owner tx-sender)
(define-constant alpha-amount u10000)

(define-map alpha-claims uint bool)

(define-private (transfer (amount uint) (recipient principal))
    (contract-call? .mega transfer amount (as-contract tx-sender) recipient none))

(define-read-only (has-claimed (alpha-id uint))
    (not (is-eq (is-none (map-get? alpha-claims alpha-id)) true)))

(define-public (drop-alpha (alpha-id uint))
  (begin
    (asserts! (is-eq tx-sender contract-owner) error-not-authorised)
    (asserts! (is-eq (has-claimed alpha-id) false) error-already-claimed)
    (try! (transfer alpha-amount (unwrap-panic (unwrap-panic (contract-call? .megapont-ape-club-nft get-owner alpha-id)))))
    (map-set alpha-claims alpha-id true)
    (ok true)))

;; Things sometimes go wrong
(define-public (withdraw)
  (begin
    (asserts! (is-eq tx-sender contract-owner) error-not-authorised)
    (try! (contract-call? .mega transfer (unwrap-panic (contract-call? .mega get-balance (as-contract tx-sender))) (as-contract tx-sender) contract-owner none))
    (ok true)))
