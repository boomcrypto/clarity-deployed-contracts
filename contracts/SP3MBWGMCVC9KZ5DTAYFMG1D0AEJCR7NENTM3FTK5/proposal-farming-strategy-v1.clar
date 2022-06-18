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

    ;;  Deposit 95k USDA in the Liquidation Pool
    ;;  Swap 200k STX to USDA if USDA < $0.8 and deposit it in the Liquidation Pool
    ;;  Use 398 STX and 0.2296 xBTC to add to STX/xBTC on Alex 

    (ok true)
  )
)
