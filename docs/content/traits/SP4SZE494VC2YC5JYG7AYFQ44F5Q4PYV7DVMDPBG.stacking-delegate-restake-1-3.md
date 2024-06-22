---
title: "Trait stacking-delegate-restake-1-3"
draft: true
---
```
;; @contract Stacking Delegate
;; @version 1
;;
;; The protocol will be delegating STX to different pools. Delegates can not be reused across
;; different pools. Multiple delegates are needed per pool, as the PoX stacking mechanism does
;; not allow to simply decrease the amount stacked. It's only possible to stop stacking completely.
;; That's why we need to divide the STX to stack across multiple delegation contracts, so that if there
;; is an outflow, we can stop 1 delegate while all others continue to stack.
;;
;; This contract is kept as simple as possible as it will be activily delegating/stacking.

(impl-trait .stacking-delegate-trait-v1.stacking-delegate-trait)
(use-trait reserve-trait .reserve-trait-v1.reserve-trait)
(use-trait rewards-trait .rewards-trait-v1.rewards-trait)

;;-------------------------------------
;; Pox Wrappers 
;;-------------------------------------

(define-public (delegate-stx (amount-ustx uint) (delegate-to principal) (until-burn-ht (optional uint)))
  (begin
    (try! (contract-call? .dao check-is-protocol contract-caller))
    (print { action: "delegate-stx", data: { amount: amount-ustx, delegate-to: delegate-to, until-burn-ht: until-burn-ht, block-height: block-height } })

    (match (as-contract (contract-call? 'SP000000000000000000002Q6VF78.pox-4 delegate-stx amount-ustx delegate-to until-burn-ht none))
      result (ok result)
      error (err (to-uint error))
    )
  )
)

(define-public (revoke-delegate-stx)
  (begin
    (try! (contract-call? .dao check-is-protocol contract-caller))
    (print { action: "revoke-delegate-stx", data: { block-height: block-height } })

    (match (as-contract (contract-call? 'SP000000000000000000002Q6VF78.pox-4 revoke-delegate-stx))
      result (ok true)
      error (if (is-eq error 34) (ok true) (err (to-uint error)))
    )
  )
)

;;-------------------------------------
;; Reserve 
;;-------------------------------------

(define-public (request-stx-to-stack (reserve <reserve-trait>) (amount uint))
  (begin
    (try! (contract-call? .dao check-is-protocol contract-caller))
    (try! (contract-call? .dao check-is-protocol (contract-of reserve)))

    (print { action: "request-stx-to-stack", data: { amount: amount, block-height: block-height } })
    (as-contract (contract-call? reserve request-stx-to-stack amount))
  )
)

(define-public (return-stx-from-stacking (reserve <reserve-trait>) (amount uint))
  (begin
    (try! (contract-call? .dao check-is-protocol contract-caller))
    (try! (contract-call? .dao check-is-protocol (contract-of reserve)))

    (print { action: "return-stx-from-stacking", data: { amount: amount, block-height: block-height } })
    (as-contract (contract-call? reserve return-stx-from-stacking amount))
  )
)

;;-------------------------------------
;; Rewards 
;;-------------------------------------

(define-public (handle-rewards (pool principal) (rewards uint) (rewards-contract <rewards-trait>))
  (begin
    (try! (contract-call? .dao check-is-protocol contract-caller))
    (try! (contract-call? .dao check-is-protocol (contract-of rewards-contract)))

    (if (> rewards u0)
      (try! (as-contract (contract-call? rewards-contract add-rewards pool rewards)))
      true
    )

    (print { action: "handle-rewards", data: { pool: pool, rewards: rewards, block-height: block-height } })
    (ok rewards)
  )
)

;;-------------------------------------
;; PoX Helpers 
;;-------------------------------------

(define-read-only (get-stx-account (account principal))
  (stx-account account)
)

;;-------------------------------------
;; Admin
;;-------------------------------------

;; Return all STX to the reserve
(define-public (return-stx (reserve <reserve-trait>))
  (let (
    (return-amount (get unlocked (get-stx-account (as-contract tx-sender))))
  )
    (try! (contract-call? .dao check-is-protocol contract-caller))
    (try! (contract-call? .dao check-is-protocol (contract-of reserve)))

    (if (> return-amount u0)
      (try! (as-contract (contract-call? reserve return-stx-from-stacking return-amount)))
      u0
    )
    (ok return-amount)
  )
)

(define-public (get-stx (requested-stx uint) (receiver principal))
  (begin
    (try! (contract-call? .dao check-is-protocol contract-caller))

    (try! (as-contract (stx-transfer? requested-stx tx-sender receiver)))
    (ok requested-stx)
  )
)

```
