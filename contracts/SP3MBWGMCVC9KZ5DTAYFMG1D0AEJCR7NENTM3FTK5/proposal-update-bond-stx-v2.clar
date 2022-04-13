;; @contract Governance proposal
;; @version 1.1

(impl-trait .lydian-dao-proposal-trait.lydian-dao-proposal-trait)

;; ------------------------------------------
;; Constants
;; ------------------------------------------

(define-constant  ERR-NOT-AUTHORIZED u1001)

;; ------------------------------------------
;; Execute
;; ------------------------------------------

(define-public (execute)
  (begin
    (asserts! (is-eq contract-caller .lydian-dao) (err  ERR-NOT-AUTHORIZED))

    (try! (contract-call? .bond-depository-v2-1 update-bond-type
      u4

      ;; Type
      .wrapped-stacks-token       ;; Payment token
      .bond-values-v2-1           ;; Bond values to use
      u3500000000                 ;; Start capacity
      u3500000000                 ;; Max capacity
      true                        ;; Capacity in LDN
      u55936                      ;; Start block    
    ))

    (try! (contract-call? .bond-depository-v2-1 update-bond-terms
      u4

      ;; Terms 
      false                       ;; Fixed term
      u720                        ;; Vesting blocks (if fixed term false)
      u0                          ;; Expiration (used for fixed term only)
      (+ u55936 u720)             ;; End of auction
      u500000000                  ;; Max payout in LDN
    ))

    (try! (contract-call? .bond-depository-v2-1 update-bond-rate
      u4

      u1                          ;; Max bp above market price
      u500                        ;; Max bp below market price
      u1000000                    ;; Start price
      block-height                ;; Last price block
      u8000                       ;; Increase bond price per LDN out
      u30000                      ;; Decrease bond price per block
    ))
    
    (ok true)
  )
)
