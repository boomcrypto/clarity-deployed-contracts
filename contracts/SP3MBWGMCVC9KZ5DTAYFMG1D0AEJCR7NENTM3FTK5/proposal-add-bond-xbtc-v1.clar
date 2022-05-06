
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
      'SP3DX3H4FEYZJZ586MFBS25ZW3HZDMEW92260R2PR.Wrapped-Bitcoin       ;; Payment token
      .bond-values-v2-1           ;; Bond values to use
      u7000000000                 ;; Max capacity
      true                        ;; Capacity in LDN
      u58815                      ;; Start block    

      ;; Terms 
      false                       ;; Fixed term
      u1008                       ;; Vesting blocks (if fixed term false)
      u0                          ;; Expiration (used for fixed term only)
      (+ block-height u2016)      ;; End of bond
      u500000000                  ;; Max payout in LDN

      ;; Rate
      u1                          ;; Max bp above market price
      u500                        ;; Max bp below market price
      u1                          ;; Start price
      u1                          ;; Increase bond price per LDN out
      u8                          ;; Decrease bond price per block
    ))

    (ok true)
  )
)

