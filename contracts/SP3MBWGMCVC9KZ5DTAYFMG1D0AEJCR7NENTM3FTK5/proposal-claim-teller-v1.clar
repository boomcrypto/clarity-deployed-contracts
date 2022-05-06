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
  (let (
    (claim-amount (unwrap-panic (contract-call? .staked-lydian-token get-claim-rebase .bond-teller-v1-1)))
  )
    (asserts! (is-eq contract-caller .lydian-dao) (err  ERR-NOT-AUTHORIZED))

    (try! (contract-call? .staked-lydian-token burn .staked-lydian-token claim-amount))
    (try! (contract-call? .staked-lydian-token mint .bond-teller-v1-1 claim-amount))

    (ok true)
  )
)