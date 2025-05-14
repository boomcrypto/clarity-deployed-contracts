---
title: "Trait LNSwap"
draft: true
---
```
;; LNSwap - a Submarine Swap implementation in Clarity
;; source: https://github.com/LNSwap/lnstxbridge/blob/main/contracts/stxswap_v10.clar

;; constants
(define-constant ERR_SWAP_NOT_FOUND (err u1000))
(define-constant ERR_REFUND_BLOCKHEIGHT_NOT_REACHED (err u1001))
(define-constant ERR_INVALID_CLAIMER (err u1002))
(define-constant ERR_ZERO_AMOUNT (err u1004))
(define-constant ERR_HASH_ALREADY_EXISTS (err u1005))
(define-constant ERR_WRONG_AMOUNT (err u1006))

;; map that holds all swaps
(define-map swaps
  { hash: (buff 32) }
  { amount: uint, timelock: uint, initiator: principal, claimPrincipal: principal }
)

;; Locks stx for a swap in the contract
;; @notice The amount locked is the stx sent in the transaction and the refund address is the initiator of the transaction
;; @param preimageHash Preimage hash of the swap
;; @param amount Amount to be locked in the contract for the swap in mstx
;; @param timelock Block height after which the locked stx can be refunded
(define-public (lockStx
  (preimageHash (buff 32))
  (amount uint)
  (timelock uint)
  (claimPrincipal principal)
)
  (begin
    (asserts! (> amount u0) ERR_ZERO_AMOUNT)
    (asserts! (is-eq (map-get? swaps {hash: preimageHash}) none) ERR_HASH_ALREADY_EXISTS)
    (unwrap-panic (stx-transfer? amount tx-sender (as-contract tx-sender)))
    (map-set swaps
      { hash: preimageHash }
      { amount: amount, timelock: timelock, initiator: tx-sender, claimPrincipal: claimPrincipal }
    )
    (print "lock")
    (print preimageHash)
    (ok true)
  )
)

;; Claims stx locked in the contract
;; @param preimage Preimage of the swap
;; @param amount Amount to be claimed - included for transparency
(define-public (claimStx (preimage (buff 32)) (amount uint))
  (let (
    (claimer tx-sender)
    (preimageHash (sha256 preimage))
    (swap (unwrap! (map-get? swaps { hash: preimageHash }) ERR_SWAP_NOT_FOUND))
  )
    (asserts! (is-eq claimer (get claimPrincipal swap)) ERR_INVALID_CLAIMER)
    (asserts! (is-eq (get amount swap) amount) ERR_WRONG_AMOUNT)
    (asserts! (map-delete swaps { hash: preimageHash }) ERR_SWAP_NOT_FOUND)
    (try! (as-contract (stx-transfer? (get amount swap) tx-sender claimer)))
    (print "claim")
    (print preimageHash)
    (ok true)
  )
)

;; Refunds stx locked in the contract
;; @param preimageHash Preimage hash of the swap
(define-public (refundStx (preimageHash (buff 32)))
  (let (
    (claimer tx-sender)
    (swap (unwrap! (map-get? swaps { hash: preimageHash }) ERR_SWAP_NOT_FOUND))
  )
    (asserts! (> burn-block-height (get timelock swap)) ERR_REFUND_BLOCKHEIGHT_NOT_REACHED)
    (asserts! (is-eq claimer (get initiator swap)) ERR_INVALID_CLAIMER)
    (map-delete swaps { hash: preimageHash })
    (try! (as-contract (stx-transfer? (get amount swap) tx-sender claimer)))
    (print "refund")
    (print preimageHash)
    (ok true)
  )
)

(define-read-only (getSwap (preimageHash (buff 32)))
  (map-get? swaps { hash: preimageHash })
)


```
