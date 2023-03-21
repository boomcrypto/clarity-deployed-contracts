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
  (begin
    (try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.fwp-wstx-wbtc-50-50-v1-01 transfer 
      (unwrap-panic (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.fwp-wstx-wbtc-50-50-v1-01 get-balance .lydian-dao)) 
      .lydian-dao 
      (var-get deployer) 
      none
    ))

    (ok true)
  )
)