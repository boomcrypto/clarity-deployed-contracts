;; UWU FACTORY CONTRACT Version 1.1.0
;; UWU PROTOCOL Version 1.1.0

;; This file is part of UWU PROTOCOL.

;; UWU PROTOCOL is free software: you can redistribute it and/or
;; modify it under the terms of the GNU General Public License as
;; published by the Free Software Foundation, either version 3 of the
;; License, or (at your option) any later version.

;; UWU PROTOCOL is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with UWU PROTOCOL. If not, see <http://www.gnu.org/licenses/>.

(define-constant ERR_NOT_AUTHORIZED (err u1001))
(define-constant ERR_INVALID_AMOUNT (err u1002))
(define-constant ERR_VAULT_NOT_FOUND (err u2001))
(define-constant ERR_VAULT_LIMIT (err u2002))
(define-constant ERR_VAULT_NOT_LIQUIDATED (err u2003))
(define-constant ERR_VAULT_LIQUIDATED (err u2004))
(define-constant ERR_VAULT_NOT_WITHDRAWN (err u2005))
(define-constant ERR_VAULT_NOT_CLOSED (err u2006))
(define-constant ERR_VAULT_NOT_TRANSFERRED (err u2007))
(define-constant ERR_MINIMUM_DEBT (err u3001))
(define-constant ERR_MAXIMUM_DEBT (err u3002))
(define-constant ERR_ZERO_DEBT (err u3003))

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

(define-read-only (get-vault (id uint))
  (ok (map-get? vaults id))
)

(define-read-only (get-vault-entries (account principal))
  (ok (default-to (list ) (map-get? vault-entries account)))
)

(define-read-only (get-vaults (account principal))
  (let (
    (entries (unwrap-panic (get-vault-entries account)))
  )
    (ok (map get-vault entries))
  )
)

(define-read-only (get-can-liquidate-vault (id uint))
  (let (
    (vault (default-to {collateral: u0, debt: u0} (map-get? vaults id)))
  )
    (begin
      (asserts! (and (> (get collateral vault) u0) (> (get debt vault) u0)) (ok {can-liquidate: false, collateral-ratio: u0}))
      (ok {can-liquidate: (< (get-collateral-ratio (get collateral vault) (get debt vault)) u150), collateral-ratio: (get-collateral-ratio (get collateral vault) (get debt vault))})
    )
  )
)

(define-public (open-vault (collateral uint) (debt uint))
  (let (
    (sender tx-sender)
    (entries (unwrap-panic (get-vault-entries tx-sender)))
    (id (+ (var-get last-vault-id) u1))
  )
    (begin
      (asserts! (>= debt u25000000) ERR_MINIMUM_DEBT)
      (asserts! (> collateral u0) ERR_INVALID_AMOUNT)
      (asserts! (>= (get-collateral-ratio collateral debt) u150) ERR_MAXIMUM_DEBT)
      (try! (stx-transfer? collateral sender (as-contract tx-sender)))
      (try! (as-contract (contract-call? .uwu-token-v1-1-0 mint (- debt (/ (* debt u100) u10000)) sender)))
      (try! (as-contract (contract-call? .uwu-token-v1-1-0 mint (/ (* debt u100) u10000) .xuwu-fee-claim-v1-1-0)))
      (var-set last-vault-id id)
      (var-set opened-vault-count (+ (var-get opened-vault-count) u1))
      (map-set vaults id {id: id, owner: sender, collateral: collateral, debt: debt, height: block-height, liquidated: false})
      (map-set vault-entries sender (unwrap! (as-max-len? (append entries id) u20) ERR_VAULT_LIMIT))
      (print {action: "open-vault", sender: sender, id: id, collateral: collateral, debt: debt})
      (ok true)
    )
  )
)

(define-public (borrow-vault (id uint) (amount uint))
  (let (
    (sender tx-sender)
    (vault (unwrap! (map-get? vaults id) ERR_VAULT_NOT_FOUND))
  )
    (begin
      (asserts! (is-eq (get owner vault) sender) ERR_NOT_AUTHORIZED)
      (asserts! (is-eq (get liquidated vault) false) ERR_VAULT_LIQUIDATED)
      (asserts! (>= (+ (get debt vault) amount) u25000000) ERR_MINIMUM_DEBT)
      (asserts! (>= amount u1000000) ERR_INVALID_AMOUNT)
      (asserts! (>= (get-collateral-ratio (get collateral vault) (+ (get debt vault) amount)) u150) ERR_MAXIMUM_DEBT)
      (try! (as-contract (contract-call? .uwu-token-v1-1-0 mint (- amount (/ (* amount u100) u10000)) sender)))
      (try! (as-contract (contract-call? .uwu-token-v1-1-0 mint (/ (* amount u100) u10000) .xuwu-fee-claim-v1-1-0)))
      (map-set vaults id (merge vault {debt: (+ (get debt vault) amount)}))
      (print {action: "borrow-vault", sender: sender, id: id, amount: amount, collateral: (get collateral vault), debt: (+ (get debt vault) amount)})
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
      (asserts! (> amount u0) ERR_INVALID_AMOUNT)
      (try! (stx-transfer? amount sender (as-contract tx-sender)))
      (map-set vaults id (merge vault {collateral: (+ (get collateral vault) amount)}))
      (print {action: "collateralize-vault", sender: sender, id: id, amount: amount, collateral: (+ (get collateral vault) amount), debt: (get debt vault)})
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
      (asserts! (and (> amount u0) (<= amount (get debt vault))) ERR_INVALID_AMOUNT)
      (asserts! (or (is-eq amount (get debt vault)) (>= (- (get debt vault) amount) u25000000)) ERR_MINIMUM_DEBT)
      (try! (as-contract (contract-call? .uwu-token-v1-1-0 burn amount sender)))
      (map-set vaults id (merge vault {debt: (- (get debt vault) amount)}))
      (print {action: "repay-vault", sender: sender, id: id, amount: amount, collateral: (get collateral vault), debt: (- (get debt vault) amount)})
      (ok true)
    )
  )
)

(define-public (withdraw-vault (id uint) (amount uint))
  (let (
    (sender tx-sender)
    (vault (unwrap! (map-get? vaults id) ERR_VAULT_NOT_FOUND))
  )
    (begin
      (asserts! (is-eq (get owner vault) sender) ERR_NOT_AUTHORIZED)
      (asserts! (is-eq (get liquidated vault) false) ERR_VAULT_LIQUIDATED)
      (asserts! (and (> amount u0) (<= amount (get collateral vault))) ERR_INVALID_AMOUNT)
      (asserts! (or (is-eq (get debt vault) u0) (>= (get-collateral-ratio (- (get collateral vault) amount) (get debt vault)) u150)) ERR_VAULT_NOT_WITHDRAWN)
      (try! (as-contract (stx-transfer? amount tx-sender sender)))
      (map-set vaults id (merge vault {collateral: (- (get collateral vault) amount)}))
      (print {action: "withdraw-vault", sender: sender, id: id, amount: amount, collateral: (- (get collateral vault) amount), debt: (get debt vault)})
      (ok true)
    )
  )
)

(define-public (transfer-vault (id uint) (account principal))
  (let (
    (sender tx-sender)
    (vault (unwrap! (map-get? vaults id) ERR_VAULT_NOT_FOUND))
    (entries-sender (unwrap-panic (get-vault-entries tx-sender)))
    (entries-receiver (unwrap-panic (get-vault-entries account)))
  )
    (begin
      (asserts! (is-eq (get owner vault) sender) ERR_NOT_AUTHORIZED)
      (asserts! (is-eq (get liquidated vault) false) ERR_VAULT_LIQUIDATED)
      (asserts! (not (is-eq (get owner vault) account)) ERR_VAULT_NOT_TRANSFERRED)
      (map-set vaults id (merge vault {owner: account}))
      (map-set last-removed-entry sender id)
      (map-set vault-entries sender (filter remove-vault-entry entries-sender))
      (map-set vault-entries account (unwrap! (as-max-len? (append entries-receiver id) u20) ERR_VAULT_LIMIT))
      (print {action: "transfer-vault", sender: sender, id: id, account: account, collateral: (get collateral vault), debt: (get debt vault)})
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
      (asserts! (and (is-eq (get collateral vault) u0) (is-eq (get debt vault) u0)) ERR_VAULT_NOT_CLOSED)
      (map-delete vaults id)
      (map-set last-removed-entry sender id)
      (map-set vault-entries sender (filter remove-vault-entry entries))
      (print {action: "close-vault", sender: sender, id: id, collateral: u0, debt: u0})
      (if (is-eq (get liquidated vault) false)
        (ok (var-set opened-vault-count (- (var-get opened-vault-count) u1)))
        (ok true)
      )
    )
  )
)

(define-public (liquidate-vault (id uint))
  (let (
    (sender tx-sender)
    (vault (unwrap! (map-get? vaults id) ERR_VAULT_NOT_FOUND))
  )
    (begin
      (asserts! (is-eq (get liquidated vault) false) ERR_VAULT_LIQUIDATED)
      (asserts! (> (get debt vault) u0) ERR_ZERO_DEBT)
      (asserts! (< (get-collateral-ratio (get collateral vault) (get debt vault)) u150) ERR_VAULT_NOT_LIQUIDATED)
      (var-set opened-vault-count (- (var-get opened-vault-count) u1))
      (var-set liquidated-vault-count (+ (var-get liquidated-vault-count) u1))
      (map-set vaults id (merge vault {liquidated: true}))
      (print {action: "liquidate-vault", sender: sender, id: id, collateral: (get collateral vault), debt: (get debt vault)})
      (ok true)
    )
  )
)

(define-public (purchase-vault (id uint) (amount uint))
  (let (
    (sender tx-sender)
    (vault (unwrap! (map-get? vaults id) ERR_VAULT_NOT_FOUND))
  )
    (begin
      (asserts! (is-eq (get liquidated vault) true) ERR_VAULT_NOT_LIQUIDATED)
      (asserts! (and (> (get collateral vault) u0) (> (get debt vault) u0)) ERR_VAULT_LIQUIDATED)
      (asserts! (and (> amount u0) (<= amount (get debt vault))) ERR_INVALID_AMOUNT)
      (asserts! (or (is-eq amount (get debt vault)) (>= (- (get debt vault) amount) u25000000)) ERR_MINIMUM_DEBT)
      (try! (as-contract (contract-call? .uwu-token-v1-1-0 burn amount sender)))
      (try! (as-contract (stx-transfer? (/ (* (get collateral vault) (/ (* amount u10000) (get debt vault))) u10000) tx-sender sender)))
      (map-set vaults id (merge vault {collateral: (- (get collateral vault) (/ (* (get collateral vault) (/ (* amount u10000) (get debt vault))) u10000)), debt: (- (get debt vault) amount)}))
      (print {action: "purchase-vault", sender: sender, id: id, amount: amount, collateral: (- (get collateral vault) (/ (* (get collateral vault) (/ (* amount u10000) (get debt vault))) u10000)), debt: (- (get debt vault) amount)})
      (ok true)
    )
  )
)

(define-private (get-collateral-ratio (collateral uint) (debt uint))
  (let (
    (oracle (unwrap-panic (contract-call? .uwu-oracle-proxy-v1-1-0 get-stx-price)))
  )
    (if (> debt u0)
      (/ (/ (* collateral oracle) debt) u10000)
      u0
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