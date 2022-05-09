;; @contract Governance proposal
;; @version 1.1

(impl-trait .lydian-dao-proposal-trait.lydian-dao-proposal-trait)

;; ------------------------------------------
;; Constants
;; ------------------------------------------

(define-constant  ERR-NOT-AUTHORIZED u1001)

(define-data-var wallet principal tx-sender)

;; ------------------------------------------
;; Execute
;; ------------------------------------------

(define-public (execute)
  (begin
    (asserts! (is-eq contract-caller .lydian-dao) (err  ERR-NOT-AUTHORIZED))

    ;; Contract is active minter
    (try! (contract-call? .lydian-token set-active-minter (as-contract tx-sender)))
    
    ;; Disable 
    (try! (contract-call? .bond-teller-v1-2 set-contract-is-enabled false))

    ;; Burn
    (try! (contract-call? .staked-lydian-token burn .bond-teller-v1-2 u980655453))
    (try! (contract-call? .lydian-token burn .staking-v1-1 u980655453))

    ;; Mint
    (try! (contract-call? .lydian-token mint (var-get wallet) u10000000))

    ;; Treasury is active minter
    (try! (contract-call? .lydian-token set-active-minter .treasury-v1-1))


    (ok true)
  )
)