
;; swap-helper-caller
;; test project to call the swap-helper public function from AlexGo.
;; let's try to exchange some ALEX for STX

(use-trait ft-trait .sip010-ft-trait-v3.sip010-ft-trait)
(use-trait swap-helper-trait .swap-helper-trait-v3.swap-helper-trait)

;; constants
;;

(define-constant contract-owner tx-sender)

(define-constant err-not-contract-owner (err u100))
(define-constant err-can-only-be-called-once (err u104))

;; data maps and vars
;;

;; private functions
;;
(define-private (transfer-ft (token-contract <ft-trait>) (amount uint) (sender principal) (recipient principal))
    (contract-call? token-contract transfer amount sender recipient none)
)

;; public functions
;;

;; Send all STX back to the owner
(define-public (withdraw-stx (amount uint)) 
    (begin
      (asserts! (is-eq tx-sender contract-owner) err-not-contract-owner)
      (let (
          (recipient tx-sender)
      )
          (as-contract (stx-transfer? amount tx-sender recipient))
      )
    )
)

;; Send all of a SIP010 token back to the owner
(define-public (withdraw-sip010 (token-trait <ft-trait>) (amount uint))
    (begin
        (asserts! (is-eq tx-sender contract-owner) err-not-contract-owner)
        (let (
            (recipient tx-sender)
        )
            (as-contract (transfer-ft token-trait amount tx-sender recipient))
        )
    )
)

;; Call the swap-helper public function based on the traits passed.
(define-public (do-the-swap (swap-trait <swap-helper-trait>) (token-x-trait <ft-trait>) (token-y-trait <ft-trait>) (amount uint) (min-dy (optional uint)))
    (begin
        (asserts! (is-eq tx-sender contract-owner) err-not-contract-owner)
        (contract-call? swap-trait swap-helper
            token-x-trait
            token-y-trait
            amount
            min-dy)
    )
)
