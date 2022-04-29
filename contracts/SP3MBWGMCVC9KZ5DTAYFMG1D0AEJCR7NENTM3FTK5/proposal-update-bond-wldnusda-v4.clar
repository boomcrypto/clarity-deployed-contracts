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
      u5

      ;; Type
      'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-token-ldn-usda       ;; Payment token
      .bond-values-v2-1           ;; Bond values to use
      u10000000000                ;; Start capacity
      u10000000000                ;; Max capacity
      true                        ;; Capacity in LDN
      u56580                      ;; Start block    
    ))

    (try! (contract-call? .bond-depository-v2-1 update-bond-terms
      u5

      ;; Terms 
      false                       ;; Fixed term
      u720                        ;; Vesting blocks (if fixed term false)
      u0                          ;; Expiration (used for fixed term only)
      (+ u56580 u4032)            ;; End of bond
      u500000000                  ;; Max payout in LDN
    ))

    (try! (contract-call? .bond-depository-v2-1 update-bond-rate
      u5

      u1                          ;; Max bp above market price
      u200                        ;; Max bp below market price
      u1000000                    ;; Start price
      block-height                ;; Last price block
      u600                        ;; Increase bond price per LDN out
      u2000                       ;; Decrease bond price per block
    ))
    
    (ok true)
  )
)
