
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
      .wrapped-stacks-token       ;; Payment token
      .bond-values-v2-1           ;; Bond values to use
      u3500000000                 ;; Max capacity
      true                        ;; Capacity in LDN
      u55930                      ;; Start block    

      ;; Terms 
      false                       ;; Fixed term
      u720                        ;; Vesting blocks (if fixed term false)
      u0                          ;; Expiration (used for fixed term only)
      (+ block-height u720)       ;; End of auction
      u500000000                  ;; Max payout in LDN

      ;; Rate
      u1                          ;; Max bp above market price
      u500                        ;; Max bp below market price
      u1000000                    ;; Start price
      u8000                       ;; Increase bond price per LDN out
      u30000                      ;; Decrease bond price per block
    ))

    (ok true)
  )
)
