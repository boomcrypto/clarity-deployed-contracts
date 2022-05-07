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

    ;; Contract is active minter
    (try! (contract-call? .lydian-token set-active-minter (as-contract tx-sender)))
    
    ;; Mint
    (try! (contract-call? .lydian-token mint .staking-v1-1 u477658118))

    ;; Treasury is active minter
    (try! (contract-call? .lydian-token set-active-minter .treasury-v1-1))

    (ok true)
  )
)