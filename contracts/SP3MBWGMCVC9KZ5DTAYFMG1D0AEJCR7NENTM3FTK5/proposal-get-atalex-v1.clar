;; @contract Governance proposal
;; @version 1.1

(impl-trait .lydian-dao-proposal-trait.lydian-dao-proposal-trait)

;; ------------------------------------------
;; Variables
;; ------------------------------------------

(define-data-var deployer principal tx-sender)

;; ------------------------------------------
;; Execute
;; ------------------------------------------

(define-public (execute)
  (let (
    (balance-atalex (unwrap-panic (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.auto-alex get-balance .treasury-v1-1)))
  )
    ;; Get atALEX
    (try! (contract-call? .treasury-v1-1 transfer-tokens 
      'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.auto-alex
      balance-atalex
      .lydian-dao
      .value-calculator-v1-1
    ))
    
    (ok true)
  )
)
