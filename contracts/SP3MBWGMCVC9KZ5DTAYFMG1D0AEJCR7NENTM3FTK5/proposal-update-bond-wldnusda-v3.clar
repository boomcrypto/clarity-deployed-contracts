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

    ;; Add new bond
    (unwrap-panic (contract-call? .bond-depository-v1-1 update-bond

      u1                               ;; bond id

      'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-token-wldn-usda     ;; token to accept as payment
      u5000000000                      ;; capacity (5000 LDN)
      true                             ;; capacity limit for payout

      u1348110128                      ;; total-debt
      u54021                           ;; last-decay

      u5                               ;; scaling variable for price
      false                            ;; fixed expiration
      u720                             ;; fixed-term - term in blocks
      u0                               ;; fixed-expiration - block number bond matures
      block-height                     ;; block number bond no longer offered
      u869                             ;; minimum-price (vs principal value)
      u5000                            ;; max-payout in thousandths of a %. i.e. 500 = 0.5%
      u0                               ;; max-debt - unused
    ))

    (ok true)
  )
)
