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

    ;; 1) Redeem 211,881 xSTX to STX
    ;; 2) Swap half to xBTC
    ;; 3) Farm STX/xBTC on Alex

    (ok true)
  )
)