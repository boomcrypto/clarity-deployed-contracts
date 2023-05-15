;; UWU STABILITY MODULE CONTRACT Version 1.1.0
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

(use-trait ft-trait .sip-010-trait-ft-standard.sip-010-trait)

(define-constant ERR_NOT_AUTHORIZED (err u1001))
(define-constant ERR_INVALID_AMOUNT (err u1002))
(define-constant ERR_SWAP_STATUS (err u6001))

(define-constant CONTRACT_OWNER tx-sender)

(define-data-var swap-status bool false)
(define-data-var fee-address principal tx-sender)
(define-data-var fee-rate uint u50)

(define-read-only (get-stability-module)
  (ok 
    {
      swap-status: (var-get swap-status),
      fee-address: (var-get fee-address),
      fee-rate: (var-get fee-rate)
    }
  )
)

(define-public (swap-x-for-y (amount uint))
  (let (
    (sender tx-sender)
  )
    (begin
      (asserts! (>= amount u10000) ERR_INVALID_AMOUNT)
      (asserts! (is-eq (var-get swap-status) true) ERR_SWAP_STATUS)
      (try! (contract-call? .uwu-token-v1-1-0 transfer (- amount (/ (* amount (var-get fee-rate)) u10000)) sender (as-contract tx-sender) none))
      (try! (contract-call? .uwu-token-v1-1-0 transfer (/ (* amount (var-get fee-rate)) u10000) sender (var-get fee-address) none))
      (as-contract (try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-susdt transfer (* (- amount (/ (* amount (var-get fee-rate)) u10000)) u100) tx-sender sender none)))
      (ok {action: "swap-x-for-y", sender: sender, amount: amount, fee-rate: (var-get fee-rate)})
    )
  )
)

(define-public (swap-y-for-x (amount uint))
  (let (
    (sender tx-sender)
  )
    (begin
      (asserts! (>= amount u1000000) ERR_INVALID_AMOUNT)
      (asserts! (is-eq (var-get swap-status) true) ERR_SWAP_STATUS)
      (try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-susdt transfer amount sender (as-contract tx-sender) none))
      (as-contract (try! (contract-call? .uwu-token-v1-1-0 transfer (/ amount u100) tx-sender sender none)))
      (ok {action: "swap-y-for-x", sender: sender, amount: amount, fee-rate: u0})
    )
  )
)

(define-public (withdraw-reserve (token <ft-trait>) (amount uint))
  (let (
    (sender tx-sender)
  )
    (begin
      (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_NOT_AUTHORIZED)
      (asserts! (> amount u0) ERR_INVALID_AMOUNT)
      (as-contract (try! (contract-call? token transfer amount tx-sender sender none)))
      (ok {action: "withdraw-reserve", sender: sender, token: token, amount: amount})
    )
  )
)

(define-public (set-swap-status (status bool))
  (begin
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_NOT_AUTHORIZED)
    (ok (var-set swap-status status))
  )
)

(define-public (set-fee-address (address principal))
  (begin
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_NOT_AUTHORIZED)
    (ok (var-set fee-address address))
  )
)

(define-public (set-fee-rate (fee uint))
  (begin
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_NOT_AUTHORIZED)
    (asserts! (and (> fee u0) (<= fee u1000)) ERR_INVALID_AMOUNT)
    (ok (var-set fee-rate fee))
  )
)