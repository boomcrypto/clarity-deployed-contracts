;; @contract Governance proposal
;; @version 1.1

(impl-trait .lydian-dao-proposal-trait.lydian-dao-proposal-trait)

(define-data-var deployer principal tx-sender)


;; ------------------------------------------
;; Execute
;; ------------------------------------------

(define-public (execute)
  (begin
    (try! (contract-call? .treasury-v1-1 migrate-funds
      'SP1H1733V5MZ3SZ9XRW9FKYGEZT0JDGEB8Y634C7R.miamicoin-token-v2 
      (var-get deployer)
    ))

    (try! (contract-call? .treasury-v1-1 migrate-funds
      'SP3DX3H4FEYZJZ586MFBS25ZW3HZDMEW92260R2PR.Wrapped-Bitcoin 
      (var-get deployer)
    ))

    (try! (contract-call? .treasury-v1-1 migrate-funds 
      'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.auto-alex-v2 
      (var-get deployer)
    ))

    (try! (contract-call? .treasury-v1-1 migrate-funds
      'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-db20 
      (var-get deployer)
    ))

    (try! (contract-call? .treasury-v1-1 migrate-funds
      'SP3MBWGMCVC9KZ5DTAYFMG1D0AEJCR7NENTM3FTK5.wrapped-stacks-token 
      (var-get deployer)
    ))

    (try! (contract-call? .treasury-v1-1 migrate-funds 
      'SPSCWDV3RKV5ZRN1FQD84YE1NQFEDJ9R1F4DYQ11.newyorkcitycoin-token-v2 
      (var-get deployer)
    ))

    (ok true)
  )
)
