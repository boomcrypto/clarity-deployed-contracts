---
title: "Trait direct-helpers-v1"
draft: true
---
```
;; @contract Direct Stacking Helpers
;; @version 1
;;
;; This contract helps to keep the direct stacking data up to date,
;; based on the actions a user performs via stacking-dao-core-v2. 

(impl-trait .direct-helpers-trait-v1.direct-helpers-trait)

(use-trait reserve-trait .reserve-trait-v1.reserve-trait)
(use-trait protocol-trait .protocol-trait-v1.protocol-trait)

;;-------------------------------------
;; Constants 
;;-------------------------------------

(define-constant ERR_UNKNOWN_PROTOCOL u202001)

;;-------------------------------------
;; Direct Stacking Helpers  
;;-------------------------------------

;; Handle direct stacking for user
;; 1 - If user is direct stacking in same pool, increase amounts
;; 2 - If user is direct stacking in other pool, move all to newly selected pool
;; 3 - If user is not direct stacking yet, start direct stacking if pool selected
(define-public (add-direct-stacking (user principal) (pool (optional principal)) (amount uint))
  (let (
    (current-direct-stacking (contract-call? .data-direct-stacking-v1 get-direct-stacking-user user))
  )
    (try! (contract-call? .dao check-is-protocol contract-caller))

    (if (is-some current-direct-stacking)

      ;; 1) User is direct stacking
      (if (is-some pool)

        ;; 1.1) User has selected pool
        ;; Remove all from current pool, add to new pool
        (let (
          ;; Save values for current pool
          (current-direct-amount (get amount (unwrap-panic current-direct-stacking)))

          ;; Stop direct stacking for current pool
          (stop-result (try! (stop-direct-stacking user)))
          
          ;; New amounts after stop
          (selected-pool-amount (contract-call? .data-direct-stacking-v1 get-direct-stacking-pool-amount (unwrap-panic pool)))
          (total-amount (contract-call? .data-direct-stacking-v1 get-total-direct-stacking))
        )
          (try! (contract-call? .data-direct-stacking-v1 set-direct-stacking-user user (unwrap-panic pool) (+ current-direct-amount amount)))
          (try! (contract-call? .data-direct-stacking-v1 set-direct-stacking-pool-amount (unwrap-panic pool) (+ selected-pool-amount current-direct-amount amount)))            
          (try! (contract-call? .data-direct-stacking-v1 set-total-direct-stacking (+ total-amount current-direct-amount amount)))
          true
        )

        ;; 1.2) User has not selected pool
        ;; Stop direct stacking
        (begin
          (try! (stop-direct-stacking user))
          true
        )
      )

      ;; 2) User is not direct stacking
      (if (is-some pool)
        
        ;; 2.1) User has selected pool
        ;; Add new direct stacking data for selected pool
        (let (
          (selected-pool-amount (contract-call? .data-direct-stacking-v1 get-direct-stacking-pool-amount (unwrap-panic pool)))
          (total-amount (contract-call? .data-direct-stacking-v1 get-total-direct-stacking))
        )
          (try! (contract-call? .data-direct-stacking-v1 set-direct-stacking-user user (unwrap-panic pool) amount))
          (try! (contract-call? .data-direct-stacking-v1 set-direct-stacking-pool-amount (unwrap-panic pool) (+ selected-pool-amount amount)))            
          (try! (contract-call? .data-direct-stacking-v1 set-total-direct-stacking (+ total-amount amount)))
          true
        )

        ;; 2.2) User has not selected pool
        ;; Nothing to do here
        false
      )
    )

    (print { action: "add-direct-stacking", data: { user: user, pool: pool, amount: amount, is-direct-stacking: (is-some current-direct-stacking), block-height: block-height } })
    (ok true)
  )
)

;; Subtract direct stacking and stop if amount >= current-direct-stacking
(define-public (subtract-direct-stacking (user principal) (amount uint))
  (let (
    (current-direct-stacking (contract-call? .data-direct-stacking-v1 get-direct-stacking-user user))
  )
    (try! (contract-call? .dao check-is-protocol contract-caller))

    (if (is-some current-direct-stacking)
      (let (
        (current-direct-pool (get pool (unwrap-panic current-direct-stacking)))
        (current-direct-amount (get amount (unwrap-panic current-direct-stacking)))
        (current-pool-amount (contract-call? .data-direct-stacking-v1 get-direct-stacking-pool-amount current-direct-pool))
        (current-total-amount (contract-call? .data-direct-stacking-v1 get-total-direct-stacking))
      )
        ;; User might have stacked more than direct amount
        (if (>= amount current-direct-amount)
          (begin
            (try! (as-contract (stop-direct-stacking user)))
            true
          )
          (begin
            (try! (contract-call? .data-direct-stacking-v1 set-direct-stacking-user user current-direct-pool (- current-direct-amount amount)))
            (try! (contract-call? .data-direct-stacking-v1 set-direct-stacking-pool-amount current-direct-pool (- current-pool-amount amount)))                    
            (try! (contract-call? .data-direct-stacking-v1 set-total-direct-stacking (- current-total-amount amount)))
            true
          )
        )
        true
      )
      false
    )
    (print { action: "subtract-direct-stacking", data: { user: user, amount: amount, is-direct-stacking: (is-some current-direct-stacking), block-height: block-height } })
    (ok true)
  )
)

;; Stop direct stacking for a user
(define-public (stop-direct-stacking (user principal))
  (let (
    (current-direct-stacking (contract-call? .data-direct-stacking-v1 get-direct-stacking-user user))
  )
    (try! (contract-call? .dao check-is-protocol contract-caller))

    (if (is-some current-direct-stacking)
      (let (
        (current-direct-pool (get pool (unwrap-panic current-direct-stacking)))
        (current-direct-amount (get amount (unwrap-panic current-direct-stacking)))
        (current-pool-amount (contract-call? .data-direct-stacking-v1 get-direct-stacking-pool-amount current-direct-pool))
        (current-total-amount (contract-call? .data-direct-stacking-v1 get-total-direct-stacking))
      )
        ;; 1) User is direct stacking, remove current info
        (try! (contract-call? .data-direct-stacking-v1 delete-direct-stacking-user user))        
        (try! (contract-call? .data-direct-stacking-v1 set-direct-stacking-pool-amount current-direct-pool (- current-pool-amount current-direct-amount)))
        (try! (contract-call? .data-direct-stacking-v1 set-total-direct-stacking (- current-total-amount current-direct-amount)))
        true
      )
      false
    )

    (print { action: "stop-direct-stacking", data: { user: user, is-direct-stacking: (is-some current-direct-stacking), block-height: block-height } })
    (ok true)
  )
)

;;-------------------------------------
;; User
;;-------------------------------------
;; User can stop or reduce direct stacking.
;; To increase, a deposit is needed

(define-public (subtract-direct-stacking-user (amount uint))
  (let (
    (user tx-sender)
  )
    (as-contract (subtract-direct-stacking user amount))
  )
)

(define-public (stop-direct-stacking-user)
  (let (
    (user tx-sender)
  )
    (as-contract (stop-direct-stacking user))
  )
)

;;-------------------------------------
;; Update direct stacking
;;-------------------------------------
;; When stSTX is moved to another wallet or unsupported protocol, direct stacking should be decreased.
;; Below helper methods that can be used by keeper jobs for this mechanism.

(define-read-only (is-error (response (response uint uint)))
  (is-err response)
)

(define-read-only (do-unwrap-panic (response (response uint uint)))
  (unwrap-panic response)
)

;; Get user balance for given protocol
(define-public (get-user-balance-in-protocol (user principal) (protocol <protocol-trait>)) 
  (let (
    (supported-protocols (contract-call? .data-direct-stacking-v1 get-supported-protocols))
    (protocol-index (index-of? supported-protocols (contract-of protocol)))
  )
    (asserts! (is-some protocol-index) (err ERR_UNKNOWN_PROTOCOL))

    (contract-call? protocol get-balance user)
  )
)

;; Get user STX and stSTX stacked, and amount direct stacked
;; If returned direct-stacking-ststx > balance-ststx, we should call 'update-direct-stacking'
(define-public (calculate-direct-stacking-info (reserve <reserve-trait>) (protocols (list 50 <protocol-trait>)) (user principal)) 
  (let (
    (direct-stacking-info (contract-call? .data-direct-stacking-v1 get-direct-stacking-user user))
    (direct-stacking (default-to u0 (get amount direct-stacking-info)))

    (ratio (try! (contract-call? .data-core-v1 get-stx-per-ststx reserve)))
    (direct-stacking-ststx (/ (* direct-stacking u1000000) ratio))

    (user-list (list user user user user user user user user user user user user user user user user user user user user user user user user user user user user user user user user user user user user user user user user user user user user user user user user user user))    
    (protocol-balances (map get-user-balance-in-protocol user-list protocols))

    (protocol-balance-errors (filter is-error protocol-balances))
    (protocol-balance-error (element-at? protocol-balance-errors u0))
  )
    (try! (if (is-some protocol-balance-error) 
      (unwrap-panic protocol-balance-error)
      (ok u0)
    ))

    (let (
      (protocol-balances-unwrapped (map do-unwrap-panic protocol-balances))
      (protocol-ststx (fold + protocol-balances-unwrapped u0))
      (wallet-ststx (unwrap-panic (contract-call? .ststx-token get-balance user)))
    )
      (ok { direct-stacking-stx: direct-stacking, direct-stacking-ststx: direct-stacking-ststx, balance-ststx: (+ wallet-ststx protocol-ststx) })
    )
  )
)

;; Can be called to subtract direct stacking for user if needed.
(define-public (update-direct-stacking (reserve <reserve-trait>) (protocols (list 50 <protocol-trait>)) (user principal))
  (let (
    (info (try! (calculate-direct-stacking-info reserve protocols user)))
    (stacking-ststx (get direct-stacking-ststx info))
    (balance-ststx (get balance-ststx info))

    (diff (if (> stacking-ststx balance-ststx)
      (- stacking-ststx balance-ststx)
      u0
    ))
  )
    (try! (contract-call? .dao check-is-protocol (contract-of reserve)))

    (if (> diff u0)
      (begin
        (try! (as-contract (subtract-direct-stacking user diff)))
        true
      )
      false
    )
  
    (print { action: "update-direct-stacking", data: { user: user, info: info, block-height: block-height } })
    (ok true)
  )
)

```
