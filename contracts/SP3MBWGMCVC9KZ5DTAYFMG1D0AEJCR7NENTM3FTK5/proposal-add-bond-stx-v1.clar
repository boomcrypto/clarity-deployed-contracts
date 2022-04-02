;; @contract Governance proposal
;; @version 1.1

(impl-trait .lydian-dao-proposal-trait.lydian-dao-proposal-trait)

;; ------------------------------------------
;; Constants
;; ------------------------------------------

(define-constant  ERR-NOT-AUTHORIZED u1001)
(define-constant  ERR-NOT-ENABLED u1002)

;; ------------------------------------------
;; Variables
;; ------------------------------------------

(define-data-var owner principal tx-sender)

;; ------------------------------------------
;; Execute
;; ------------------------------------------

(define-public (execute)
  (begin
    (asserts! (is-eq contract-caller .lydian-dao) (err ERR-NOT-AUTHORIZED))

    ;; Add new bond
    (unwrap-panic (contract-call? .bond-depository-v1-1 add-bond
      .wrapped-stacks-token            ;; token to accept as payment
      u4000000000                      ;; capacity (4000 LDN)
      true                             ;; capacity limit for payout
      u5                               ;; scaling variable for price
      false                            ;; fixed expiration
      u720                             ;; fixed-term - term in blocks
      u0                               ;; fixed-expiration - block number bond matures
      (+ block-height u720)            ;; block number bond no longer offered
      u4710                            ;; minimum-price (vs principal value)
      u5000                            ;; max-payout in thousandths of a %. i.e. 500 = 0.5%
      u0                               ;; max-debt - unused
    ))

    (ok true)
  )
)
