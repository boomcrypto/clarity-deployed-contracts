---
title: "Trait keeper-1-q6qcaz3x1-v-1-1"
draft: true
---
```

      ;; keeper-1-q6qcaz3x1-v-1-1

      (define-constant ERR_NOT_AUTHORIZED (err u8001))
      (define-constant ERR_INVALID_AMOUNT (err u8002))
      (define-constant ERR_MINIMUM_RECEIVED (err u8003))
      (define-constant ERR_TOKEN_TRANSFER_FAILED (err u8004))

      (define-data-var owner-address principal 'SP228WEAEMYX21RW0TT5T38THPNDYPPGGVW2RP570)
      (define-data-var keeper-address principal 'SP16BPKS1DN5AYQ5MDHFEYXTSP352QG6JS2E0N8YP)

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

      (define-public (keeper-swap-a (amount uint) (min-received uint))
        (let (
          (authorization-check (asserts! (is-owner-or-keeper) ERR_NOT_AUTHORIZED))
          (amount-check (asserts! (> amount u0) ERR_INVALID_AMOUNT))
          (swap-a (try! (as-contract (contract-call?
                                    'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-core-v-1-1 swap-y-for-x
                                    'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.xyk-pool-stx-aeusdc-v-1-1
                                    'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.token-stx-v-1-1
                                    'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc
                                    amount u1))))
          (caller tx-sender)
        )
          (begin
            (asserts! (>= swap-a min-received) ERR_MINIMUM_RECEIVED)
            (try! (as-contract (transfer-receiving-token swap-a tx-sender (var-get owner-address))))
            (print {
              action: "keeper-swap-a",
              caller: caller,
              data: {
                amount: amount,
                min-received: min-received,
                swap-a: swap-a
              }
            })
            (ok true)
          )
        )
      )

      (define-public (withdraw-tokens (amount uint) (recipient principal))
        (let (
          (caller tx-sender)
        )
          (begin
            (asserts! (is-eq caller (var-get owner-address)) ERR_NOT_AUTHORIZED)
            (asserts! (> amount u0) ERR_INVALID_AMOUNT)
            (try! (as-contract (transfer-swap-token amount tx-sender recipient)))
            (print {
              action: "withdraw-tokens",
              caller: caller,
              data: {
                amount: amount,
                recipient: recipient
              }
            })
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

      (define-private (transfer-swap-token (amount uint) (sender principal) (recipient principal))
        (let (
          (call-a (unwrap! (contract-call?
                          'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc transfer
                          amount sender recipient none) ERR_TOKEN_TRANSFER_FAILED))
        )
          (ok call-a)
        )
      )

      (define-private (transfer-receiving-token (amount uint) (sender principal) (recipient principal))
        (let (
          (call-a (unwrap! (contract-call?
                          'SM1793C4R5PZ4NS4VQ4WMP7SKKYVH8JZEWSZ9HCCR.token-stx-v-1-1 transfer
                          amount sender recipient none) ERR_TOKEN_TRANSFER_FAILED))
        )
          (ok call-a)
        )
      )

      (define-private (is-owner-or-keeper)
        (or 
          (is-eq tx-sender (var-get owner-address)) 
          (and (is-eq tx-sender (var-get keeper-address)) (var-get keeper-authorized))
        )
      )
    
```
