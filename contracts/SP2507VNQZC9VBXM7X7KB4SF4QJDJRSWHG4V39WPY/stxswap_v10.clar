;; LNSwap - a Submarine Swap implementation in Clarity 

;; constants
(define-constant err-swap-not-found u1000)
(define-constant err-refund-blockheight-not-reached u1001)
(define-constant err-invalid-claimer u1002)
(define-constant err-claim-blockheight-passed u1003)
(define-constant err-zero-amount u1004)
(define-constant err-hash-already-exists u1005)
(define-constant err-wrong-amount u1006)
(define-constant ok-success u1008)

;; map that holds all swaps
(define-map swaps {hash: (buff 32)} {amount: uint, timelock: uint, initiator: principal, claimPrincipal: principal})

;; Locks stx for a swap in the contract
;; @notice The amount locked is the stx sent in the transaction and the refund address is the initiator of the transaction
;; @param preimageHash Preimage hash of the swap
;; @param amount Amount to be locked in the contract for the swap in mstx
;; @param timelock Block height after which the locked stx can be refunded
(define-public (lockStx (preimageHash (buff 32)) (amount uint) (timelock uint) (claimPrincipal principal))
  (begin
    (asserts! (> amount u0) (err err-zero-amount))
    (asserts! (is-eq (map-get? swaps {hash: preimageHash}) none) (err err-hash-already-exists))
    (unwrap-panic (stx-transfer? amount tx-sender (as-contract tx-sender)))
    (map-set swaps {hash: preimageHash} {amount: amount, timelock: timelock, initiator: tx-sender, claimPrincipal: claimPrincipal})
    (print "lock")
    (print preimageHash)
    (ok ok-success)
  )
)

;; Claims stx locked in the contract
;; @param preimage Preimage of the swap
;; @param amount Amount to be claimed - included for transparency
(define-public (claimStx (preimage (buff 32)) (amount uint))
  (let (
    (claimer tx-sender)
    (preimageHash (sha256 preimage))
    (swap (unwrap! (map-get? swaps {hash: preimageHash}) (err err-swap-not-found)))
    )
  (begin
    (asserts! (is-eq claimer (get claimPrincipal swap)) (err err-invalid-claimer))
    (asserts! (is-eq (get amount swap) amount) (err err-wrong-amount))
    (asserts! (map-delete swaps {hash: preimageHash}) (err err-swap-not-found))
    (try! (as-contract (stx-transfer? (get amount swap) tx-sender claimer)))
    (print "claim")
    (print preimageHash)
    (ok ok-success)
  ))
)

;; Refunds stx locked in the contract
;; @param preimageHash Preimage hash of the swap
(define-public (refundStx (preimageHash (buff 32)))
  (let (
    (claimer tx-sender)
    (swap (unwrap! (map-get? swaps {hash: preimageHash}) (err err-swap-not-found)))
    )
  (begin
    (asserts! (> block-height (get timelock swap)) (err err-refund-blockheight-not-reached))
    (asserts! (is-eq claimer (get initiator swap)) (err err-invalid-claimer))
    (map-delete swaps {hash: preimageHash})
    (try! (as-contract (stx-transfer? (get amount swap) tx-sender claimer)))
    (print "refund")
    (print preimageHash)
    (ok ok-success)
  ))
)

(define-read-only (getSwap (preimageHash (buff 32)))
  (map-get? swaps {hash: preimageHash})
)
