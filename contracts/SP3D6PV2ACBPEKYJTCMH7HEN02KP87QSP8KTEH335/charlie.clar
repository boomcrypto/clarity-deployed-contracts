(define-constant error-not-authorised (err u401))
(define-constant error-already-claimed (err u402))

(define-constant contract-owner tx-sender)
(define-constant charlie-amount u295)

(define-map charlie-claims uint bool)

(define-private (transfer (amount uint) (recipient principal))
    (contract-call? .mega transfer amount (as-contract tx-sender) recipient none))

(define-read-only (has-claimed (charlie-id uint))
    (not (is-eq (is-none (map-get? charlie-claims charlie-id)) true)))

(define-public (drop-charlie (charlie-id uint))
  (begin
    (asserts! (is-eq tx-sender contract-owner) error-not-authorised)
    (asserts! (is-eq (has-claimed charlie-id) false) error-already-claimed)
    (try! (transfer charlie-amount (unwrap-panic (unwrap-panic (contract-call? .megapont-exquisite-robot-nft get-owner charlie-id)))))
    (map-set charlie-claims charlie-id true)
    (ok true)))

;; Things sometimes go wrong
(define-public (withdraw)
  (begin
    (asserts! (is-eq tx-sender contract-owner) error-not-authorised)
    (try! (contract-call? .mega transfer (unwrap-panic (contract-call? .mega get-balance (as-contract tx-sender))) (as-contract tx-sender) contract-owner none))
    (ok true)))
