;; @contract Staking
;; @version 0
;;
;; Placeholder for a potential staking contract
;;

(impl-trait .staking-trait-v1.staking-trait)

;;-------------------------------------
;; Rewards - Add
;;-------------------------------------

;; Used by the commission contract to add STX
(define-public (add-rewards (amount uint) (end-block uint))
  (begin
    (try! (contract-call? .dao check-is-protocol contract-caller))

    (ok u0)
  )
)
