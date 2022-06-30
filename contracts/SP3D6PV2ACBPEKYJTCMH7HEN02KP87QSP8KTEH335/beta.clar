(define-constant error-not-authorised (err u401))
(define-constant error-already-claimed (err u402))
(define-constant error-interacting (err u510))

(define-constant contract-owner tx-sender)
(define-constant beta-amount u295)

(define-map beta-claims uint bool)

(define-data-var v1-robot-last-id uint u0)

(define-private (transfer (amount uint) (recipient principal))
    (contract-call? .mega transfer amount (as-contract tx-sender) recipient none))

(define-read-only (has-claimed (beta-id uint))
    (not (is-eq (is-none (map-get? beta-claims beta-id)) true)))

(define-public (drop-beta (beta-id uint))
  (begin
    (asserts! (is-eq tx-sender contract-owner) error-not-authorised)
    (asserts! (is-eq (has-claimed beta-id) false) error-already-claimed)

    (if (<= beta-id (var-get v1-robot-last-id))
        (try! (transfer beta-amount (unwrap-panic (unwrap-panic (contract-call? .megapont-robot-nft get-owner beta-id)))))
        (try! (transfer beta-amount (unwrap-panic (unwrap-panic (contract-call? .megapont-robot-expansion-nft get-owner beta-id)))))
    )

    (map-set beta-claims beta-id true)
    (ok true)))

;; Things sometimes go wrong
(define-public (withdraw)
  (begin
    (asserts! (is-eq tx-sender contract-owner) error-not-authorised)
    (try! (contract-call? .mega transfer (unwrap-panic (contract-call? .mega get-balance (as-contract tx-sender))) (as-contract tx-sender) contract-owner none))
    (ok true)))

;; Things went wrong
(let ((last-minted-v1-robot-id (unwrap! (contract-call? .megapont-robot-nft get-last-token-id) error-interacting)))
  (var-set v1-robot-last-id last-minted-v1-robot-id))
