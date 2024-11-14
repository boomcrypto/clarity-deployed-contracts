---
title: "Trait keeper-1-008c0vts5-v-1-1"
draft: true
---
```
;; keeper-1-008c0vts5-v-1-1

;; Use all required traits
(use-trait keeper-ft-trait 'SP2AKWJYC7BNY18W1XXKPGP0YVEK63QJG4793Z2D4.sip-010-trait-ft-standard.sip-010-trait)

;; Error constants
(define-constant ERR_NOT_AUTHORIZED (err u8001))
(define-constant ERR_INVALID_AMOUNT (err u8002))
(define-constant ERR_INVALID_PRINCIPAL (err u8003))
(define-constant ERR_MINIMUM_RECEIVED (err u8004))

;; Address of the owner authorized to interact with contract
(define-data-var owner-address principal 'SP228WEAEMYX21RW0TT5T38THPNDYPPGGVW2RP570)

;; Address of the keeper authorized to interact with contract
(define-data-var keeper-address principal 'SP16BPKS1DN5AYQ5MDHFEYXTSP352QG6JS2E0N8YP)

;; Data var used to enable or disable keeper authorization
(define-data-var keeper-authorized bool true)

;; Get owner address
(define-read-only (get-owner-address)
  (ok (var-get owner-address))
)

;; Get keeper address
(define-read-only (get-keeper-address)
  (ok (var-get keeper-address))
)

;; Get keeper authorization status
(define-read-only (get-keeper-authorized)
  (ok (var-get keeper-authorized))
)

;; Swap psBTC to STX and then transfer STX tokens to owner
(define-public (keeper-action-a (amount uint) (min-received uint))
  (let (
    ;; Assert that tx-sender is owner or keeper and keeper is authorized
    (authorization-check (asserts! (is-owner-or-keeper) ERR_NOT_AUTHORIZED))

    ;; Assert that amount is greater than 0
    (amount-check (asserts! (> amount u0) ERR_INVALID_AMOUNT))

    ;; Perform psBTC to STX swap via XYK
    (swap-a (try! (as-contract (contract-call?
                               'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-core-v-1-2 swap-x-for-y
                               'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-pool-psbtc-stx-v-1-1
                               'SP14NS8MVBRHXMM96BQY0727AJ59SWPV7RMHC0NCG.pontis-bridge-psBTC
                               'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.token-stx-v-1-2
                               amount u1))))
    (caller tx-sender)
  )
    (begin
      ;; Assert that swap-a is greater than or equal to min-received
      (asserts! (>= swap-a min-received) ERR_MINIMUM_RECEIVED)

      ;; Transfer STX tokens from the contract to the owner
      (try! (as-contract (stx-transfer? swap-a tx-sender (var-get owner-address))))

      ;; Print action data and return true
      (print {
        action: "keeper-action-a",
        caller: caller,
        data: {
          amount: amount,
          min-received: min-received,
          xyk-data: {
            xyk-tokens: {
              a: 'SP14NS8MVBRHXMM96BQY0727AJ59SWPV7RMHC0NCG.pontis-bridge-psBTC,
              b: 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.token-stx-v-1-2
            },
            xyk-pools: {
              a: 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-pool-psbtc-stx-v-1-1
            },
            xyk-swaps: {
              a: swap-a
            }
          }
        }
      })
      (ok true)
    )
  )
)

;; Withdraw tokens from the keeper contract
(define-public (withdraw-tokens (token-trait <keeper-ft-trait>) (amount uint) (recipient principal))
  (let (
    (token-contract (contract-of token-trait))
    (caller tx-sender)
  )
    (begin
      ;; Assert caller is owner
      (asserts! (is-eq caller (var-get owner-address)) ERR_NOT_AUTHORIZED)

      ;; Assert that amount is greater than 0
      (asserts! (> amount u0) ERR_INVALID_AMOUNT)

      ;; Assert that addresses are standard principals
      (asserts! (is-standard token-contract) ERR_INVALID_PRINCIPAL)
      (asserts! (is-standard recipient) ERR_INVALID_PRINCIPAL)

      ;; Transfer tokens from the contract to the recipient
      (try! (as-contract (contract-call? token-trait transfer amount tx-sender recipient none)))

      ;; Print withdraw data and return true
      (print {
        action: "withdraw-tokens",
        caller: caller,
        data: {
          token-contract: token-contract,
          amount: amount,
          recipient: recipient
        }
      })
      (ok true)
    )
  )
)

;; Set owner address authorized to interact with contract
(define-public (set-owner-address (address principal))
  (let (
    (caller tx-sender)
  )
    ;; Assert caller is owner
    (asserts! (is-eq caller (var-get owner-address)) ERR_NOT_AUTHORIZED)

    ;; Assert that address is standard principal
    (asserts! (is-standard address) ERR_INVALID_PRINCIPAL)

    ;; Set owner-address to address
    (var-set owner-address address)

    ;; Print function data and return true
    (print {action: "set-owner-address", caller: caller, data: {address: address}})
    (ok true)
  )
)

;; Set keeper address authorized to interact with contract
(define-public (set-keeper-address (address principal))
  (let (
    (caller tx-sender)
  )
    (begin
      ;; Assert caller is owner or keeper
      (asserts! (is-owner-or-keeper) ERR_NOT_AUTHORIZED)

      ;; Assert that address is standard principal
      (asserts! (is-standard address) ERR_INVALID_PRINCIPAL)

      ;; Set keeper-address to address
      (var-set keeper-address address)

      ;; Print function data and return true
      (print {action: "set-keeper-address", caller: caller, data: {address: address}})
      (ok true)
    )
  )
)

;; Enable or disable keeper authorization
(define-public (set-keeper-authorized (authorized bool))
  (let (
    (caller tx-sender)
  )
    ;; Assert caller is owner
    (asserts! (is-eq caller (var-get owner-address)) ERR_NOT_AUTHORIZED)

    ;; Update keeper authorization status
    (var-set keeper-authorized authorized)

    ;; Print function data and return true
    (print {action: "set-keeper-authorized", caller: caller, data: {authorized: authorized}})
    (ok true)
  )
)

;; Check if tx-sender is owner or keeper and if keeper is authorized
(define-private (is-owner-or-keeper)
  (or
    (is-eq tx-sender (var-get owner-address))
    (and (is-eq tx-sender (var-get keeper-address)) (var-get keeper-authorized))
  )
)
```
