;; sip10swap - a Submarine Swap implementation in Clarity to enable swaps SIP10 tokens <-> BTC on Lightning Network 
(use-trait ft-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)

;; constants
(define-constant err-swap-not-found u1000)
(define-constant err-refund-blockheight-not-reached u1001)
(define-constant err-invalid-claimer u1002)
(define-constant err-claim-blockheight-passed u1003)
(define-constant err-invalid-token u1004)
(define-constant err-zero-amount u1005)
(define-constant err-wrong-amount u1006)
(define-constant err-hash-already-exists u1007)
(define-constant ok-success u1008)

;; map that holds all swaps
(define-map swaps {hash: (buff 32)} {amount: uint, timelock: uint, initiator: principal, claimPrincipal: principal, tokenPrincipal: principal})

;; Locks sip10 for a swap in the contract
;; @notice The amount locked is the sip10 sent in the transaction and the refund address is the initiator of the transaction
;; @param preimageHash Preimage hash of the swap
;; @param timelock Block height after which the locked sip10 can be refunded
(define-public (lockToken (preimageHash (buff 32)) (amount uint) (timelock uint) (claimPrincipal principal) (tokenPrincipal <ft-trait>))
  (begin
    (asserts! (> amount u0) (err err-zero-amount))
    (asserts! (is-eq (map-get? swaps {hash: preimageHash}) none) (err err-hash-already-exists))
    (unwrap-panic (contract-call? tokenPrincipal transfer amount tx-sender (as-contract tx-sender) none))
    (map-set swaps {hash: preimageHash} {amount: amount, timelock: timelock,  initiator: tx-sender, claimPrincipal: claimPrincipal, tokenPrincipal: (contract-of tokenPrincipal)})
    (print "lock")
    (print preimageHash)
    (ok ok-success)
  )
)

;; Claims sip10 locked in the contract
;; @param preimage Preimage of the swap
;; @param amount Amount to be claimed - included for transparency
;; @param tokenPrincipal Token to be claimed - included for transparency
(define-public (claimToken (preimage (buff 32)) (amount uint) (tokenPrincipal <ft-trait>))
  (let (
    (claimer tx-sender)
    (preimageHash (sha256 preimage))
    (swap (unwrap! (map-get? swaps {hash: preimageHash}) (err err-swap-not-found)))
    )
  (begin
    (asserts! (is-eq claimer (get claimPrincipal swap)) (err err-invalid-claimer))
    (asserts! (is-eq (contract-of tokenPrincipal) (get tokenPrincipal swap)) (err err-invalid-token))
    (asserts! (is-eq (get amount swap) amount) (err err-wrong-amount))
    (map-delete swaps {hash: preimageHash})
    (unwrap-panic (as-contract (contract-call? tokenPrincipal transfer amount tx-sender claimer none)))
    (print "claim")
    (print preimageHash)
    (ok ok-success)
  ))
)

;; Refunds sip10 locked in the contract
;; @param preimageHash Preimage hash of the swap
;; @param amount Amount locked in the contract for the swap in msip10
;; @param timelock Block height after which the locked sip10 can be refunded
(define-public (refundToken (preimageHash (buff 32)) (tokenPrincipal <ft-trait>))
  (let (
    (claimer tx-sender)
    (swap (unwrap! (map-get? swaps {hash: preimageHash}) (err err-swap-not-found)))
    )
  (begin
    (asserts! (> block-height (get timelock swap)) (err err-refund-blockheight-not-reached))
    (asserts! (is-eq claimer (get initiator swap)) (err err-invalid-claimer))
    (asserts! (is-eq (contract-of tokenPrincipal) (get tokenPrincipal swap)) (err err-invalid-token))
    (map-delete swaps {hash: preimageHash})
    (unwrap-panic (as-contract (contract-call? tokenPrincipal transfer (get amount swap) tx-sender claimer none)))
    (print "refund")
    (print preimageHash)
    (ok ok-success)
  ))
)
