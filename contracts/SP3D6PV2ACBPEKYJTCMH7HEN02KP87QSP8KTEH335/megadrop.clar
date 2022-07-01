(define-constant error-not-authorised (err u401))
(define-constant error-already-claimed (err u402))
(define-constant error-interacting (err u510))

(define-constant contract-owner tx-sender)

(define-constant alpha-amount u10000)
(define-map alpha-claims uint bool)

(define-constant beta-amount u295)
(define-map beta-claims uint bool)

(define-constant delta-amount u295)
(define-map delta-claims uint bool)

(define-constant gamma-amount u100)
(define-map gamma-claims uint bool)

(define-data-var v1-robot-last-id uint u0)

(define-private (transfer (amount uint) (recipient principal))
    (contract-call? .mega transfer amount tx-sender recipient none))

(define-read-only (has-claimed-alpha (alpha-id uint))
    (not (is-eq (is-none (map-get? alpha-claims alpha-id)) true)))

(define-public (drop-alpha (alpha-id uint))
  (begin
    (asserts! (is-eq tx-sender contract-owner) error-not-authorised)
    (asserts! (is-eq (has-claimed-alpha alpha-id) false) error-already-claimed)
    (try! (transfer alpha-amount (unwrap-panic (unwrap-panic (contract-call? .megapont-ape-club-nft get-owner alpha-id)))))
    (map-set alpha-claims alpha-id true)
    (ok true)))

(define-read-only (has-claimed-beta (beta-id uint))
    (not (is-eq (is-none (map-get? beta-claims beta-id)) true)))

(define-public (drop-beta (beta-id uint))
  (begin
    (asserts! (is-eq tx-sender contract-owner) error-not-authorised)
    (asserts! (is-eq (has-claimed-beta beta-id) false) error-already-claimed)
    (if (<= beta-id (var-get v1-robot-last-id))
        (try! (transfer beta-amount (unwrap-panic (unwrap-panic (contract-call? .megapont-robot-nft get-owner beta-id)))))
        (try! (transfer beta-amount (unwrap-panic (unwrap-panic (contract-call? .megapont-robot-expansion-nft get-owner beta-id)))))
    )
    (map-set beta-claims beta-id true)
    (ok true)))

(define-read-only (has-claimed-delta (delta-id uint))
    (not (is-eq (is-none (map-get? delta-claims delta-id)) true)))

(define-public (drop-delta (delta-id uint))
  (begin
    (asserts! (is-eq tx-sender contract-owner) error-not-authorised)
    (asserts! (is-eq (has-claimed-delta delta-id) false) error-already-claimed)
    (try! (transfer delta-amount (unwrap-panic (unwrap-panic (contract-call? .megapont-exquisite-robot-nft get-owner delta-id)))))
    (map-set delta-claims delta-id true)
    (ok true)))

(define-read-only (has-claimed-gamma (gamma-id uint))
    (not (is-eq (is-none (map-get? gamma-claims gamma-id)) true)))

(define-public (drop-gamma (gamma-id uint))
  (begin
    (asserts! (is-eq tx-sender contract-owner) error-not-authorised)
    (asserts! (is-eq (has-claimed-gamma gamma-id) false) error-already-claimed)
    (try! (transfer gamma-amount (unwrap-panic (unwrap-panic (contract-call? 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.steady-lads get-owner gamma-id)))))
    (map-set gamma-claims gamma-id true)
    (ok true)))

(let ((last-minted-v1-robot-id (unwrap! (contract-call? .megapont-robot-nft get-last-token-id) error-interacting)))
  (var-set v1-robot-last-id last-minted-v1-robot-id))
