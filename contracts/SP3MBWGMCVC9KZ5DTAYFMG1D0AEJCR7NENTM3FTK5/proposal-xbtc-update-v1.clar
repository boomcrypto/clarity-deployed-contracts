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

    (try! (contract-call? .bond-depository-v2-1 set-active-bond-teller .bond-teller-v1-3))
    (try! (contract-call? .treasury-v1-1 set-active-minter-info .bond-teller-v1-3 true))

    (try! (contract-call? .bond-depository-v2-1 update-bond-type
      u6

      'SP3DX3H4FEYZJZ586MFBS25ZW3HZDMEW92260R2PR.Wrapped-Bitcoin       ;; Payment token
      .bond-values-v3-1           ;; Bond values to use
      u7000000000                 ;; Max capacity
      u7000000000                 ;; Max capacity
      true                        ;; Capacity in LDN
      u58815                      ;; Start block    
    ))

    (try! (contract-call? .bond-depository-v2-1 update-bond-terms
      u6

      ;; Terms 
      false                       ;; Fixed term
      u1008                       ;; Vesting blocks (if fixed term false)
      u0                          ;; Expiration (used for fixed term only)
      (+ block-height u2016)      ;; End of bond
      u500000000                  ;; Max payout in LDN
    ))

    (ok true)
  )
)