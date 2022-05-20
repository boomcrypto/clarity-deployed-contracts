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


    (try! (contract-call? .bond-depository-v2-1 update-bond-rate
      u6

      u1                          ;; Max bp above market price
      u500                        ;; Max bp below market price
      u1                          ;; Start price
      block-height                ;; Last price block
      u1                         ;; Increase bond price per LDN out
      u50                       ;; Decrease bond price per block
    ))
    
    (ok true)
  )
)
