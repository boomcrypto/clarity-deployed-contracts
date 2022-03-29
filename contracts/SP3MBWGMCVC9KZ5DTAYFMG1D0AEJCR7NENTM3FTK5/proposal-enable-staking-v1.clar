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

    ;; Add staking as recipient
    (try! (contract-call? .staking-distributor-v1-1 add-recipient .staking-v1-1 u3297))

    ;; Set epoch info
    (try! (contract-call? .staking-v1-1 set-epoch-info u48 block-height))

    (ok true)
  )
)