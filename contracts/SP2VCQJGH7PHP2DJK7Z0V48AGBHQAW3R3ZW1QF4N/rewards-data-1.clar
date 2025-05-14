(define-constant ERR_UNAUTHORIZED (err u7003))

;; asset -> isolation-mode-total-debt
(define-map vault-rewards { user: principal, collateral-asset: principal, borrowed-asset: principal } uint)
(define-public (set-vault-rewards
  (user principal)
  (collateral-asset principal)
  (borrowed-asset principal)
  (new-vault-rewards uint))
  (begin
    (try! (is-approved-contract contract-caller))
    (print { type: "set-vault-rewards", payload: { key: { user: user, collateral-asset: collateral-asset, borrowed-asset: borrowed-asset }, data: new-vault-rewards } })
    (ok (map-set vault-rewards { user: user, collateral-asset: collateral-asset, borrowed-asset: borrowed-asset } new-vault-rewards))))
(define-public (get-vault-rewards
  (user principal)
  (collateral-asset principal)
  (borrowed-asset principal))
  (ok (map-get? vault-rewards { user: user, collateral-asset: collateral-asset, borrowed-asset: borrowed-asset })))
(define-read-only (get-vault-rewards-read
  (user principal)
  (collateral-asset principal)
  (borrowed-asset principal))
  (map-get? vault-rewards { user: user, collateral-asset: collateral-asset, borrowed-asset: borrowed-asset }))

;; -- ownable-trait --
(define-data-var contract-owner principal tx-sender)
(define-public (set-contract-owner (owner principal))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) ERR_UNAUTHORIZED)
    (print { type: "set-contract-owner-pool-reserve-data-5", payload: owner })
    (ok (var-set contract-owner owner))))

(define-public (get-contract-owner)
  (ok (var-get contract-owner)))
(define-read-only (get-contract-owner-read)
  (var-get contract-owner))

(define-read-only (is-contract-owner (caller principal))
  (is-eq caller (var-get contract-owner)))

;; -- permissions
(define-map approved-contracts principal bool)

(define-public (set-approved-contract (contract principal) (enabled bool))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) ERR_UNAUTHORIZED)
    (ok (map-set approved-contracts contract enabled))))

(define-public (delete-approved-contract (contract principal))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) ERR_UNAUTHORIZED)
    (ok (map-delete approved-contracts contract))))

(define-read-only (is-approved-contract (contract principal))
  (if (default-to false (map-get? approved-contracts contract))
    (ok true)
    ERR_UNAUTHORIZED))
