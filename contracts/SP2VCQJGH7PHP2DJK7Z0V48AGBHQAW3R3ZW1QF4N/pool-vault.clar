(impl-trait .vault-trait.vault-trait)
(use-trait ft .ft-trait.ft-trait)

(define-public (transfer (amount uint) (recipient principal) (f-t <ft>))
  (begin
    (try! (is-approved-contract contract-caller))
    (print { type: "transfer-pool-vault", payload: { amount: amount, recipient: recipient, asset: f-t } })
    (as-contract (contract-call? f-t transfer amount tx-sender recipient none))))

;; -- ownable-trait --
(define-data-var contract-owner principal tx-sender)

(define-public (get-contract-owner)
  (ok (var-get contract-owner)))

(define-public (set-contract-owner (owner principal))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) ERR_UNAUTHORIZED)
    (print { type: "set-contract-owner-pool-vault", payload: owner })
    (ok (var-set contract-owner owner))))

(define-read-only (is-contract-owner (caller principal))
  (is-eq caller (var-get contract-owner)))

(define-map approved-contracts principal bool)

(define-read-only (is-approved-contract (contract principal))
  (if (default-to false (map-get? approved-contracts contract))
    (ok true)
    ERR_UNAUTHORIZED))

(map-set approved-contracts .pool-borrow true)
(map-set approved-contracts .liquidation-manager true)
(map-set approved-contracts .pool-0-reserve true)

;; ERROR START 7000
(define-constant ERR_UNAUTHORIZED (err u7000))