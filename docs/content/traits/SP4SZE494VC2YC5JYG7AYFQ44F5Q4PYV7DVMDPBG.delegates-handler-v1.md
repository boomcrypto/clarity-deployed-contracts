---
title: "Trait delegates-handler-v1"
draft: true
---
```
;; @contract Stacking Delegates
;; @version 1
;;
;; Delegate contracts in the protocol are difficult to replace as they are activily delegating/stacking. 
;; So we want to keep the delegate contract itself as simple as possible.
;; This contract adds some extra logic for the delegates.
;;
;; There are 4 important functions: delegate, revoke, handle-excess and handle-rewards.

(use-trait reserve-trait .reserve-trait-v1.reserve-trait)
(use-trait stacking-delegate-trait .stacking-delegate-trait-v1.stacking-delegate-trait)
(use-trait rewards-trait .rewards-trait-v1.rewards-trait)

;;-------------------------------------
;; Constants 
;;-------------------------------------

(define-constant ERR_DELEGATE_AMOUNT_LOCKED u201001)

;;-------------------------------------
;; Maps
;;-------------------------------------

;; Delegate to last selected pool
(define-map last-selected-pool principal principal)

;; Delegate to target locked amount
(define-map target-locked-amount principal uint)

;; Delegate to last updated locked amount
(define-map last-locked-amount principal uint)

;; Delegate to last updated unlocked amount
(define-map last-unlocked-amount principal uint)

;;-------------------------------------
;; Getters
;;-------------------------------------


(define-read-only (get-last-selected-pool (delegate principal))
  (default-to
    .stacking-pool-v1
    (map-get? last-selected-pool delegate)
  )
)

(define-read-only (get-target-locked-amount (delegate principal))
  (default-to
    u0
    (map-get? target-locked-amount delegate)
  )
)

(define-read-only (get-last-locked-amount (delegate principal))
  (default-to
    u0
    (map-get? last-locked-amount delegate)
  )
)

(define-read-only (get-last-unlocked-amount (delegate principal))
  (default-to
    u0
    (map-get? last-unlocked-amount delegate)
  )
)

;;-------------------------------------
;; PoX Helpers 
;;-------------------------------------

(define-read-only (get-stx-account (account principal))
  (stx-account account)
)

;;-------------------------------------
;; Reserve Wrappers
;;-------------------------------------

(define-private (request-stx-to-stack (delegate <stacking-delegate-trait>) (reserve <reserve-trait>) (amount uint))
  (begin
    (try! (as-contract (contract-call? delegate request-stx-to-stack reserve amount)))

    (map-set last-locked-amount (contract-of delegate) (get locked (get-stx-account (contract-of delegate))))
    ;; Need to add and not set to current amount, as rewards must still be calculated correctly
    (map-set last-unlocked-amount (contract-of delegate) (+ (get-last-unlocked-amount (contract-of delegate)) amount))

    (print { action: "request-stx-to-stack", data: { delegate: (contract-of delegate), amount: amount, block-height: block-height } })
    (ok true)
  )
)

(define-private (return-stx-from-stacking (delegate  <stacking-delegate-trait>) (reserve <reserve-trait>) (amount uint))
  (begin
    (try! (as-contract (contract-call? delegate return-stx-from-stacking reserve amount)))

    (map-set last-locked-amount (contract-of delegate) (get locked (get-stx-account (contract-of delegate))))
    ;; Need to subtract and not set to current amount, as rewards must still be calculated correctly
    (map-set last-unlocked-amount (contract-of delegate) (- (get-last-unlocked-amount (contract-of delegate)) amount))

    (print { action: "return-stx-from-stacking", data: { delegate: (contract-of delegate), amount: amount, block-height: block-height } })
    (ok true)
  )
)


;;-------------------------------------
;; Handle rewards
;;-------------------------------------

(define-read-only (calculate-rewards (delegate principal)) 
  (let (
    (last-locked (get-last-locked-amount delegate))
    (last-unlocked (get-last-unlocked-amount delegate))

    (locked-amount (get locked (get-stx-account delegate)))
    (unlocked-amount (get unlocked (get-stx-account delegate)))

    ;; Extra STX must be rewards
    (rewards (if (> (+ locked-amount unlocked-amount) (+ last-locked last-unlocked))
      (- (+ locked-amount unlocked-amount) (+ last-locked last-unlocked))
      u0
    ))
  )
    rewards
  )
)

;; If extra STX in (contract + locked) it means rewards were added
(define-public (handle-rewards (delegate <stacking-delegate-trait>) (reserve <reserve-trait>) (rewards-contract <rewards-trait>))
  (let (
    (rewards (calculate-rewards (contract-of delegate)))
  )
    (try! (contract-call? .dao check-is-protocol (contract-of delegate)))
    (try! (contract-call? .dao check-is-protocol (contract-of reserve)))
    (try! (contract-call? .dao check-is-protocol (contract-of rewards-contract)))

    (try! (as-contract (contract-call? delegate handle-rewards (get-last-selected-pool (contract-of delegate)) rewards rewards-contract)))

    (print { action: "handle-excess", data: { delegate: (contract-of delegate), rewards: rewards, block-height: block-height } })
    (ok rewards)
  )
)

;;-------------------------------------
;; Handle excess amount
;;-------------------------------------

(define-read-only (calculate-excess (delegate principal)) 
  (let (
    (locked-amount (get locked (get-stx-account delegate)))
    (unlocked-amount (get unlocked (get-stx-account delegate)))
    (rewards-amount (calculate-rewards delegate))

    (target-amount (get-target-locked-amount delegate))
    (total-amount (if (> (+ locked-amount unlocked-amount) rewards-amount)
      (- (+ locked-amount unlocked-amount) rewards-amount)
      u0
    ))
    (excess-amount (if (> total-amount target-amount)
      (- total-amount target-amount)
      u0
    ))
  )
    (if (> excess-amount u0)
      (if (> unlocked-amount excess-amount)
        excess-amount
        unlocked-amount
      )
      u0
    )
  )
)

;; If target amount is lower than (contract + locked)
;; we can return the STX held by the contract
(define-public (handle-excess (delegate <stacking-delegate-trait>) (reserve <reserve-trait>))
  (let (
    (excess (calculate-excess (contract-of delegate)))
  )
    (try! (contract-call? .dao check-is-protocol (contract-of delegate)))
    (try! (contract-call? .dao check-is-protocol (contract-of reserve)))

    ;; Not needed STX to reserve
    (if (> excess u0)
      (try! (as-contract (return-stx-from-stacking delegate reserve excess)))
      true
    )

    (print { action: "handle-excess", data: { delegate: (contract-of delegate), excess: excess, block-height: block-height } })
    (ok excess)
  )
)


;;-------------------------------------
;; Delegation 
;;-------------------------------------

(define-public (revoke (delegate <stacking-delegate-trait>) (reserve <reserve-trait>) (rewards-contract <rewards-trait>))
  (begin 
    ;; Need to be done first
    (try! (handle-rewards delegate reserve rewards-contract))

    (try! (contract-call? .dao check-is-protocol contract-caller))
    (try! (contract-call? .dao check-is-protocol (contract-of delegate)))
    (try! (contract-call? .dao check-is-protocol (contract-of reserve)))
    (try! (contract-call? .dao check-is-protocol (contract-of rewards-contract)))

    (let (
      (unlocked-amount (get unlocked (get-stx-account (contract-of delegate))))
    )
      ;; Revoke
      (try! (contract-call? delegate revoke-delegate-stx))

      ;; Return STX
      (if (> unlocked-amount u0)
        (try! (as-contract (return-stx-from-stacking delegate reserve unlocked-amount)))
        true
      )

      ;; Set target
      (map-set target-locked-amount (contract-of delegate) u0)

      (print { action: "revoke", data: { delegate: (contract-of delegate), block-height: block-height } })
      (ok true)
    )
  )
)

(define-public (revoke-and-delegate (delegate <stacking-delegate-trait>) (reserve <reserve-trait>) (rewards-contract <rewards-trait>) (amount-ustx uint) (delegate-to principal) (until-burn-ht uint))
  (begin
    ;; Need to be done first
    (try! (handle-rewards delegate reserve rewards-contract))

    ;; Revoke
    (try! (contract-call? delegate revoke-delegate-stx))

    (try! (contract-call? .dao check-is-protocol contract-caller))
    (try! (contract-call? .dao check-is-protocol (contract-of delegate)))
    (try! (contract-call? .dao check-is-protocol (contract-of reserve)))
    (try! (contract-call? .dao check-is-protocol (contract-of rewards-contract)))

    (let (
      (locked-amount (get locked (get-stx-account (contract-of delegate))))
      (unlocked-amount (get unlocked (get-stx-account (contract-of delegate))))
    )
      (asserts! (>= amount-ustx locked-amount) (err ERR_DELEGATE_AMOUNT_LOCKED))

      ;; Request STX from reserve if needed
      (if (> amount-ustx (+ unlocked-amount locked-amount))
        (try! (as-contract (request-stx-to-stack delegate reserve (- amount-ustx (+ unlocked-amount locked-amount)))))
        true
      )

      ;; Delegate STX
      (try! (contract-call? delegate delegate-stx amount-ustx delegate-to (some until-burn-ht)))

      ;; Set target
      (map-set target-locked-amount (contract-of delegate) amount-ustx)
      (map-set last-selected-pool (contract-of delegate) delegate-to)

      ;; Handle excess
      (try! (handle-excess delegate reserve))

      (print { action: "revoke-and-delegate", data: { delegate: (contract-of delegate), amount: amount-ustx, delegate-to: delegate-to, until-burn-ht: until-burn-ht, block-height: block-height } })
      (ok true)
    )
  )
)

;;-------------------------------------
;; Admin
;;-------------------------------------

;; In case something goes wrong
(define-public (update-amounts (delegate principal) (target-locked uint) (last-locked uint) (last-unlocked uint))
  (begin
    (try! (contract-call? .dao check-is-protocol contract-caller))

    (map-set target-locked-amount delegate target-locked)
    (map-set last-locked-amount delegate last-locked)
    (map-set last-unlocked-amount delegate last-unlocked)
    (ok true)
  )
)

```
