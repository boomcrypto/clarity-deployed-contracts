;; Title: BME08 Resolution Coordinator (label-based)
;; Resolvers signal a label; once any label's count reaches the threshold
;; we call the market contract with that label.

(impl-trait 'SP3JP0N1ZXGASRJ0F7QAHWFPGTVK9T2XNXDB908Z.extension-trait.extension-trait)

;; --- Errors
(define-constant err-unauthorised               (err u6100))
(define-constant err-not-resolution-team-member (err u6101))
(define-constant err-already-executed           (err u6102))

;; --- State
(define-map resolution-team principal bool)

;; Per-market: has this resolver already signalled (regardless of label)?
(define-map resolution-action-signals {market-id: uint, team-member: principal} bool)

;; Per (market,label): how many signals?
(define-map resolution-label-counts {market-id: uint, label: (string-ascii 64)} uint)

;; Per (market,resolver): metadata hash (e.g., prompt/model/evidence hash)
(define-map resolution-metadata {market-id: uint, resolver: principal} (buff 32))

;; Threshold
(define-data-var resolution-signals-required uint u1)

;; --- Auth
(define-public (is-dao-or-extension)
	(ok (asserts! (or (is-eq tx-sender .bigmarket-dao) (contract-call? .bigmarket-dao is-extension contract-caller)) err-unauthorised))
)

;; --- Admin
(define-public (set-resolution-team-member (who principal) (member bool))
  (begin
    (try! (is-dao-or-extension))
    (ok (map-set resolution-team who member))
  )
)

(define-public (set-signals-required (new-requirement uint))
  (begin
    (try! (is-dao-or-extension))
    (ok (var-set resolution-signals-required new-requirement))
  )
)

;; --- Views
(define-read-only (is-resolution-team-member (who principal))
  (default-to false (map-get? resolution-team who))
)

(define-read-only (has-signalled (market-id uint) (who principal))
  (default-to false (map-get? resolution-action-signals {market-id: market-id, team-member: who}))
)

(define-read-only (get-label-count (market-id uint) (label (string-ascii 64)))
  (default-to u0 (map-get? resolution-label-counts {market-id: market-id, label: label}))
)

(define-read-only (get-signals-required)
  (var-get resolution-signals-required)
)

(define-read-only (get-resolution-metadata (market-id uint) (resolver principal))
  (map-get? resolution-metadata {market-id: market-id, resolver: resolver})
)

;; --- Private helpers
(define-private (increment-label-count (market-id uint) (label (string-ascii 64)))
  (let
    (
      (current (get-label-count market-id label))
      (next    (+ current u1))
    )
    (map-set resolution-label-counts {market-id: market-id, label: label} next)
    next
  )
)

;; --- Main
(define-public (signal-resolution (market-id uint) (label (string-ascii 64)) (metadata (buff 32)))
  (let
    (
      (required (var-get resolution-signals-required))
    )
    ;; must be an approved resolver
    (asserts! (is-resolution-team-member tx-sender) err-not-resolution-team-member)
    ;; prevent double-voting for this market (regardless of label)
    (asserts! (not (has-signalled market-id tx-sender)) err-already-executed)

    ;; record resolver metadata & signal
    (map-set resolution-metadata       {market-id: market-id, resolver: tx-sender} metadata)
    (map-set resolution-action-signals {market-id: market-id, team-member: tx-sender} true)

    ;; bump this label's count and check threshold
    (let ((count (increment-label-count market-id label)))
      (if (>= count required)
        ;; quorum for this label reached resolve with the LABEL (string)
        (begin
          (try! (as-contract (contract-call? .bme024-0-market-predicting resolve-market market-id label)))
          (ok {status: "resolved", label: label, count: count})
        )
        ;; not yet at threshold
        (ok {status: "pending", label: label, count: count})
      )
    )
  )
)

;; Trait
(define-public (callback (sender principal) (memo (buff 34)))
  (ok true)
)
