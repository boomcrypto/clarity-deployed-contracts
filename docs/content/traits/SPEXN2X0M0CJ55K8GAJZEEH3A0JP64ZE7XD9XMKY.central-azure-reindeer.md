---
title: "Trait central-azure-reindeer"
draft: true
---
```
;; bridge-adapter-aeusdc-stx-v-1-1

(use-trait x-pool-trait 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-pool-trait-v-1-1.xyk-pool-trait)
(use-trait x-ft-trait 'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.sip-010-trait-ft-standard-v-1-1.sip-010-trait)

(define-constant ERR_NOT_AUTHORIZED (err u1001))
(define-constant ERR_INVALID_AMOUNT (err u1002))
(define-constant ERR_MINIMUM_RECEIVED (err u4002))
(define-constant ERR_SWAP_A (err u5001))
(define-constant ERR_KEEPER_NOT_AUTHORIZED (err u8001))
(define-constant ERR_TOKEN_TRANSFER_FAILED (err u8002))

(define-data-var owner-address principal 'SPEXN2X0M0CJ55K8GAJZEEH3A0JP64ZE7XD9XMKY)
(define-data-var keeper-address principal 'SPEXN2X0M0CJ55K8GAJZEEH3A0JP64ZE7XD9XMKY)

(define-data-var keeper-authorized bool true)

(define-read-only (get-owner-address)
  (ok (var-get owner-address))
)

(define-read-only (get-keeper-address)
  (ok (var-get keeper-address))
)

(define-read-only (get-keeper-authorized)
  (ok (var-get keeper-authorized))
)

(define-public (swap-helper-a (amount uint) (min-received uint))
  (let (
    (swap-a (unwrap! (as-contract (xyk-sb
                                  amount
                                  'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-pool-stx-aeusdc-v-1-1
                                  'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.token-stx-v-1-1
                                  'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc)) ERR_SWAP_A))
    (transfer-a (try! (as-contract (transfer-stx swap-a tx-sender (var-get owner-address)))))
    (caller tx-sender)
  )
    (begin
      (asserts! (is-owner-or-keeper) ERR_NOT_AUTHORIZED)
      (asserts! (is-keeper-authorized) ERR_KEEPER_NOT_AUTHORIZED)
      (asserts! (> amount u0) ERR_INVALID_AMOUNT)
      (asserts! (>= swap-a min-received) ERR_MINIMUM_RECEIVED)
      (print {
        action: "swap-helper-a",
        caller: caller,
        data: {
          amount: amount,
          min-received: min-received,
          owner-address: (var-get owner-address),
          keeper-address: (var-get keeper-address),
          swap-a: swap-a,
          transfer-a: transfer-a
        }
      })
      (ok true)
    )
  )
)

(define-public (withdraw-token (amount uint) (recipient principal))
  (let (
    (caller tx-sender)
  )
    (begin
      (asserts! (is-eq caller (var-get owner-address)) ERR_NOT_AUTHORIZED)
      (try! (as-contract (transfer-aeusdc amount tx-sender recipient)))
      (print {action: "withdraw-token", caller: caller, data: {amount: amount, recipient: recipient}})
      (ok true)
    )
  )
)

(define-public (set-owner-address (owner principal))
  (let (
    (caller tx-sender)
  )
    (asserts! (is-eq caller (var-get owner-address)) ERR_NOT_AUTHORIZED)
    (var-set owner-address owner)
    (print {action: "set-owner-address", caller: caller, data: {owner: owner}})
    (ok true)
  )
)

(define-public (set-keeper-address (address principal))
  (let (
    (caller tx-sender)
  )
    (begin
      (asserts! (is-owner-or-keeper) ERR_NOT_AUTHORIZED)
      (var-set keeper-address address)
      (print {action: "set-keeper-address", caller: caller, data: {address: address}})
      (ok true)
    )
  )
)

(define-public (set-keeper-authorized (authorized bool))
  (let (
    (caller tx-sender)
  )
    (asserts! (is-eq caller (var-get owner-address)) ERR_NOT_AUTHORIZED)
    (var-set keeper-authorized authorized)
    (print {action: "set-keeper-authorized", caller: caller, data: {authorized: authorized}})
    (ok true)
  )
)

(define-private (xyk-sb
    (amount uint)
    (pool-trait <x-pool-trait>)
    (a-token <x-ft-trait>) (b-token <x-ft-trait>)
  )
  (let (
    (swap-a (try! (contract-call?
                  'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-core-v-1-1 swap-y-for-x
                  pool-trait
                  a-token b-token
                  amount u1)))
  )
    (ok swap-a)
  )
)

(define-private (transfer-aeusdc (amount uint) (sender principal) (recipient principal))
  (let (
    (call-a (unwrap! (contract-call?
                     'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc transfer
                     amount sender recipient none) ERR_TOKEN_TRANSFER_FAILED))
  )
    (ok call-a)
  )
)

(define-private (transfer-stx (amount uint) (sender principal) (recipient principal))
  (let (
    (call-a (unwrap! (contract-call?
                     'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.token-stx-v-1-1 transfer
                     amount sender recipient none) ERR_TOKEN_TRANSFER_FAILED))
  )
    (ok call-a)
  )
)

(define-private (is-owner-or-keeper)
  (or (is-eq tx-sender (var-get owner-address)) (is-eq tx-sender (var-get keeper-address)))
)

(define-private (is-keeper-authorized)
  (or (is-eq (var-get keeper-authorized) true) (is-eq tx-sender (var-get owner-address)))
)
```
