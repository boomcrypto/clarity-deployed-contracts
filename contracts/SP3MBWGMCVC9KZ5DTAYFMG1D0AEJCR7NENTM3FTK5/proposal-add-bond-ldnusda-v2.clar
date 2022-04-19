;; @contract Governance proposal
;; @version 2.1

(impl-trait .lydian-dao-proposal-trait.lydian-dao-proposal-trait)

;; ------------------------------------------
;; Constants
;; ------------------------------------------

(define-constant ERR-NOT-AUTHORIZED u1001)

;; ------------------------------------------
;; Execute
;; ------------------------------------------

(define-public (execute)
  (begin
    (asserts! (is-eq contract-caller .lydian-dao) (err ERR-NOT-AUTHORIZED))

    ;; Add new bond
    (unwrap-panic (contract-call? .bond-depository-v2-1 add-bond

      ;; Type
      'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-token-ldn-usda       ;; Payment token
      .bond-values-v2-1           ;; Bond values to use
      u10000000000                ;; Max capacity
      true                        ;; Capacity in LDN
      u56580                      ;; Start block    

      ;; Terms 
      false                       ;; Fixed term
      u432                        ;; Vesting blocks (if fixed term false)
      u0                          ;; Expiration (used for fixed term only)
      (+ u56580 u4032)            ;; End of bond
      u500000000                  ;; Max payout in LDN

      ;; Rate
      u1                          ;; Max bp above market price
      u500                        ;; Max bp below market price
      u1000000                    ;; Start price
      u600                        ;; Increase bond price per LDN out
      u2000                       ;; Decrease bond price per block
    ))

    (ok true)
  )
)
