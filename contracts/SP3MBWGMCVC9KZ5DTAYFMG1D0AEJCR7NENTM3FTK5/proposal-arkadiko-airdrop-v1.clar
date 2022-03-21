;; @contract Governance proposal
;; @version 1.1

(impl-trait .lydian-dao-proposal-trait.lydian-dao-proposal-trait)

;; ------------------------------------------
;; Constants
;; ------------------------------------------

(define-constant  ERR-NOT-AUTHORIZED u1001)

;; ------------------------------------------
;; Variables
;; ------------------------------------------

(define-data-var wallet principal tx-sender)

;; ------------------------------------------
;; Execute
;; ------------------------------------------

(define-public (execute)
  (begin
    (asserts! (is-eq contract-caller .lydian-dao) (err  ERR-NOT-AUTHORIZED))

    ;; Contract is active minter
    (try! (contract-call? .wrapped-lydian-token set-active-minter (as-contract tx-sender)))

    ;; Burn LDN in wrong contract
    (try! (contract-call? .wrapped-lydian-token burn 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.lydan-airdrop-v1-2 u1538500000))

    ;; Mint LDN for airdrop
    (try! (contract-call? .wrapped-lydian-token mint 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.lydian-airdrop-v1-2 u1538500000))

    ;; Treasury is active minter
    (try! (contract-call? .wrapped-lydian-token set-active-minter .treasury-v1-1))

    (ok true)
  )
)

