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

    (try! (contract-call? .bond-depository-v2-1 update-bond-terms
      u6

      ;; Terms 
      false                       ;; Fixed term
      u1008                       ;; Vesting blocks (if fixed term false)
      u0                          ;; Expiration (used for fixed term only)
      block-height                ;; End of auction
      u5                          ;; Max payout in LDN
    ))
    
    (ok true)
  )
)
