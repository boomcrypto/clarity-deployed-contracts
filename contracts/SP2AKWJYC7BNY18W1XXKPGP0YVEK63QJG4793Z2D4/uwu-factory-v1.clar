;; UWU FACTORY CONTRACT V1
;; UWU Protocol Version 1.0.0

;; This file is part of UWU Protocol.

;; UWU Protocol is free software: you can redistribute it and/or
;; modify it under the terms of the GNU General Public License as
;; published by the Free Software Foundation, either version 3 of the
;; License, or (at your option) any later version.

;; UWU Protocol is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with UWU Protocol. If not, see <http://www.gnu.org/licenses/>.

(define-constant ERR_NOT_AUTHORIZED (err u1001))
(define-constant ERR_INVALID_AMOUNT (err u1002))
(define-constant ERR_VAULT_NOT_FOUND (err u2001))
(define-constant ERR_VAULT_LIMIT (err u2002))
(define-constant ERR_VAULT_NOT_LIQUIDATED (err u2003))
(define-constant ERR_VAULT_LIQUIDATED (err u2004))
(define-constant ERR_MINIMUM_DEBT (err u3001))
(define-constant ERR_MAXIMUM_DEBT (err u3002))
(define-constant ERR_NONZERO_DEBT (err u3003))
(define-constant ERR_ZERO_DEBT (err u3004))

(define-data-var last-vault-id uint u0)
(define-data-var opened-vault-count uint u0)
(define-data-var liquidated-vault-count uint u0)

(define-map vaults uint {id: uint, owner: principal, collateral: uint, debt: uint, height: uint, liquidated: bool})
(define-map vault-entries principal (list 20 uint))
(define-map last-removed-entry principal uint)

(define-read-only (get-last-vault-id)
  (ok (var-get last-vault-id))
)

(define-read-only (get-opened-vault-count)
  (ok (var-get opened-vault-count))
)

(define-read-only (get-liquidated-vault-count)
  (ok (var-get liquidated-vault-count))
)

(define-read-only (get-vault-by-id (id uint))
  (ok (map-get? vaults id))
)

(define-read-only (get-vault-entries (account principal))
  (ok (default-to (list ) (map-get? vault-entries account)))
)

(define-read-only (get-vaults (account principal))
  (let (
    (entries (unwrap-panic (get-vault-entries account)))
  )
    (ok (map get-vault-by-id entries))
  )
)

(define-read-only (get-can-liquidate-vault (id uint))
  (let (
    (vault (default-to {collateral: u0, debt: u0} (map-get? vaults id)))
    (oracle (unwrap-panic (get-stx-price)))
  )
    (begin
      (asserts! (and (> (get collateral vault) u0) (> (get debt vault) u0)) (ok {can-liquidate: false, collateral-ratio: u0}))
      (ok {can-liquidate: (< (/ (/ (* (get collateral vault) oracle) (get debt vault)) u10000) u150), collateral-ratio: (/ (/ (* (get collateral vault) oracle) (get debt vault)) u10000)})
    )
  )
)

(define-public (get-stx-price)
  (ok (unwrap-panic (contract-call? .uwu-oracle-proxy-v1 get-stx-price)))
)

(define-public (open-vault (amount uint) (debt uint))
  (let (
    (sender tx-sender)
    (entries (unwrap-panic (get-vault-entries tx-sender)))
    (id (+ (var-get last-vault-id) u1))
    (oracle (unwrap-panic (get-stx-price)))
  )
    (begin
      (asserts! (>= debt u25000000) ERR_MINIMUM_DEBT)
      (asserts! (>= (/ (/ (* amount oracle) debt) u10000) u150) ERR_MAXIMUM_DEBT)
      (try! (stx-transfer? amount sender (as-contract tx-sender)))
      (try! (as-contract (contract-call? .uwu-token-v1 mint (- debt (/ (* debt u200) u10000)) sender)))
      (try! (as-contract (contract-call? .uwu-token-v1 mint (/ (* debt u200) u10000) .xuwu-fee-claim-v1)))
      (var-set last-vault-id id)
      (var-set opened-vault-count (+ (var-get opened-vault-count) u1))
      (map-set vaults id {id: id, owner: sender, collateral: amount, debt: debt, height: block-height, liquidated: false})
      (map-set vault-entries sender (unwrap! (as-max-len? (append entries id) u20) ERR_VAULT_LIMIT))
      (print {action: "open-vault", sender: sender, id: id, owner: sender, collateral: amount, debt: debt})
      (ok true)
    )
  )
)

(define-public (borrow-vault (id uint) (amount uint))
  (let (
    (sender tx-sender)
    (vault (unwrap! (map-get? vaults id) ERR_VAULT_NOT_FOUND))
    (oracle (unwrap-panic (get-stx-price)))
  )
    (begin
      (asserts! (is-eq (get owner vault) sender) ERR_NOT_AUTHORIZED)
      (asserts! (is-eq (get liquidated vault) false) ERR_VAULT_LIQUIDATED)
      (asserts! (>= (+ (get debt vault) amount) u25000000) ERR_MINIMUM_DEBT)
      (asserts! (>= (/ (/ (* (get collateral vault) oracle) (+ (get debt vault) amount)) u10000) u150) ERR_MAXIMUM_DEBT)
      (try! (as-contract (contract-call? .uwu-token-v1 mint amount sender)))
      (map-set vaults id (merge vault {debt: (+ (get debt vault) amount)}))
      (print {action: "borrow-vault", sender: sender, id: id, owner: (get owner vault), amount: amount, collateral: (get collateral vault), debt: (get debt vault)})
      (ok true)
    )
  )
)

(define-public (collateralize-vault (id uint) (amount uint))
  (let (
    (sender tx-sender)
    (vault (unwrap! (map-get? vaults id) ERR_VAULT_NOT_FOUND))
  )
    (begin
      (asserts! (is-eq (get owner vault) sender) ERR_NOT_AUTHORIZED)
      (asserts! (is-eq (get liquidated vault) false) ERR_VAULT_LIQUIDATED)
      (try! (stx-transfer? amount sender (as-contract tx-sender)))
      (map-set vaults id (merge vault {collateral: (+ (get collateral vault) amount)}))
      (print {action: "collateralize-vault", sender: sender, id: id, owner: (get owner vault), amount: amount, collateral: (get collateral vault), debt: (get debt vault)})
      (ok true)
    )
  )
)

(define-public (repay-vault (id uint) (amount uint))
  (let (
    (sender tx-sender)
    (vault (unwrap! (map-get? vaults id) ERR_VAULT_NOT_FOUND))
  )
    (begin
      (asserts! (is-eq (get owner vault) sender) ERR_NOT_AUTHORIZED)
      (asserts! (is-eq (get liquidated vault) false) ERR_VAULT_LIQUIDATED)
      (asserts! (> (get debt vault) u0) ERR_ZERO_DEBT)
      (asserts! (<= amount (get debt vault)) ERR_INVALID_AMOUNT)
      (asserts! (or (is-eq amount (get debt vault)) (>= (- (get debt vault) amount) u25000000)) ERR_MINIMUM_DEBT)
      (try! (as-contract (contract-call? .uwu-token-v1 burn amount sender)))
      (map-set vaults id (merge vault {debt: (- (get debt vault) amount)}))
      (print {action: "repay-vault", sender: sender, id: id, owner: (get owner vault), amount: amount, collateral: (get collateral vault), debt: (get debt vault)})
      (ok true)
    )
  )
)

(define-public (close-vault (id uint))
  (let (
    (sender tx-sender)
    (vault (unwrap! (map-get? vaults id) ERR_VAULT_NOT_FOUND))
    (entries (unwrap-panic (get-vault-entries tx-sender)))
  )
    (begin
      (asserts! (is-eq (get owner vault) sender) ERR_NOT_AUTHORIZED)
      (asserts! (is-eq (get liquidated vault) false) ERR_VAULT_LIQUIDATED)
      (asserts! (is-eq (get debt vault) u0) ERR_NONZERO_DEBT)
      (try! (as-contract (stx-transfer? (get collateral vault) tx-sender sender)))
      (var-set opened-vault-count (- (var-get opened-vault-count) u1))
      (map-delete vaults id)
      (map-set last-removed-entry sender id)
      (map-set vault-entries sender (filter remove-vault-entry entries))
      (print {action: "close-vault", sender: sender, id: id, owner: (get owner vault), collateral: (get collateral vault), debt: (get debt vault)})
      (ok true)
    )
  )
)

(define-public (init-liquidate-vault (id uint))
  (let (
    (sender tx-sender)
    (vault (unwrap! (map-get? vaults id) ERR_VAULT_NOT_FOUND))
    (oracle (unwrap-panic (get-stx-price)))
  )
    (begin
      (asserts! (is-eq (get liquidated vault) false) ERR_VAULT_LIQUIDATED)
      (asserts! (> (get debt vault) u0) ERR_ZERO_DEBT)
      (asserts! (< (/ (/ (* (get collateral vault) oracle) (get debt vault)) u10000) u150) ERR_VAULT_NOT_LIQUIDATED)
      (var-set opened-vault-count (- (var-get opened-vault-count) u1))
      (var-set liquidated-vault-count (+ (var-get liquidated-vault-count) u1))
      (map-set vaults id (merge vault {liquidated: true}))
      (print {action: "init-liquidate-vault", sender: sender, id: id, owner: (get owner vault), collateral: (get collateral vault), debt: (get debt vault)})
      (ok true)
    )
  )
)

(define-public (liquidate-vault (id uint) (amount uint))
  (let (
    (sender tx-sender)
    (vault (unwrap! (map-get? vaults id) ERR_VAULT_NOT_FOUND))
  )
    (begin
      (asserts! (is-eq (get liquidated vault) true) ERR_VAULT_NOT_LIQUIDATED)
      (asserts! (and (> (get collateral vault) u0) (> (get debt vault) u0)) ERR_VAULT_LIQUIDATED)
      (asserts! (<= amount (get debt vault)) ERR_INVALID_AMOUNT)
      (asserts! (or (is-eq amount (get debt vault)) (>= (- (get debt vault) amount) u25000000)) ERR_MINIMUM_DEBT)
      (try! (as-contract (contract-call? .uwu-token-v1 burn amount sender)))
      (try! (as-contract (stx-transfer? (/ (* (get collateral vault) (/ (* amount u10000) (get debt vault))) u10000) tx-sender sender)))
      (map-set vaults id (merge vault {collateral: (- (get collateral vault) (/ (* (get collateral vault) (/ (* amount u10000) (get debt vault))) u10000)), debt: (- (get debt vault) amount)}))
      (print {action: "liquidate-vault", sender: sender, id: id, owner: (get owner vault), collateral: (get collateral vault), debt: (get debt vault)})
      (ok true)
    )
  )
)

(define-private (remove-vault-entry (id uint))
  (let (
    (entry (unwrap-panic (map-get? last-removed-entry tx-sender)))
  )
    (if (is-eq id entry)
      false
      true
    )
  )
)