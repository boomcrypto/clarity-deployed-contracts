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

    ;; Add LP as treasury token
    (try! (contract-call? .treasury-v1-1 enable-reserve-token 
      .wrapped-stacks-token
      false 
      .value-calculator-v1-1
    ))

    ;; Add LP token to value calculator
    (try! (contract-call? .value-calculator-v1-1 add-token 
      .wrapped-stacks-token
      false 
      .wrapped-stacks-token
      .wrapped-stacks-token
    ))

    (ok true)
  )
)

