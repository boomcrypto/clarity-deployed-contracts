;; @contract Governance proposal
;; @version 1.1

(impl-trait .lydian-dao-proposal-trait.lydian-dao-proposal-trait)

(define-data-var deployer principal tx-sender)


;; ------------------------------------------
;; Execute
;; ------------------------------------------

(define-public (execute)
  (let (
    (balance-miami (unwrap-panic (contract-call? 'SP1H1733V5MZ3SZ9XRW9FKYGEZT0JDGEB8Y634C7R.miamicoin-token-v2 get-balance .treasury-v1-1)))
    (balance-usda (unwrap-panic (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token get-balance .treasury-v1-1)))
    (balance-diko (unwrap-panic (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token get-balance .treasury-v1-1)))
    (balance-xbtc (unwrap-panic (contract-call? 'SP3DX3H4FEYZJZ586MFBS25ZW3HZDMEW92260R2PR.Wrapped-Bitcoin get-balance .treasury-v1-1)))
    (balance-alex (unwrap-panic (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.auto-alex-v2 get-balance .treasury-v1-1)))
    (balance-brc (unwrap-panic (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-db20 get-balance .treasury-v1-1)))
    (balance-stx (unwrap-panic (contract-call? 'SP3MBWGMCVC9KZ5DTAYFMG1D0AEJCR7NENTM3FTK5.wrapped-stacks-token get-balance .treasury-v1-1)))
    (balance-nyc (unwrap-panic (contract-call? 'SPSCWDV3RKV5ZRN1FQD84YE1NQFEDJ9R1F4DYQ11.newyorkcitycoin-token-v2 get-balance .treasury-v1-1)))
  )
    (try! (contract-call? .treasury-v1-1 transfer-tokens 
      'SP1H1733V5MZ3SZ9XRW9FKYGEZT0JDGEB8Y634C7R.miamicoin-token-v2 
      balance-miami
      (var-get deployer)
      .value-calculator-v1-1
    ))

    (try! (contract-call? .treasury-v1-1 transfer-tokens 
      'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token 
      balance-usda
      (var-get deployer)
      .value-calculator-v1-1
    ))

    (try! (contract-call? .treasury-v1-1 transfer-tokens 
      'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token 
      balance-diko
      (var-get deployer)
      .value-calculator-v1-1
    ))

    (try! (contract-call? .treasury-v1-1 transfer-tokens 
      'SP3DX3H4FEYZJZ586MFBS25ZW3HZDMEW92260R2PR.Wrapped-Bitcoin 
      balance-xbtc
      (var-get deployer)
      .value-calculator-v1-1
    ))

    (try! (contract-call? .treasury-v1-1 transfer-tokens 
      'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.auto-alex-v2 
      balance-alex
      (var-get deployer)
      .value-calculator-v1-1
    ))

    (try! (contract-call? .treasury-v1-1 transfer-tokens 
      'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-db20 
      balance-brc
      (var-get deployer)
      .value-calculator-v1-1
    ))

    (try! (contract-call? .treasury-v1-1 transfer-tokens 
      'SP3MBWGMCVC9KZ5DTAYFMG1D0AEJCR7NENTM3FTK5.wrapped-stacks-token 
      balance-stx
      (var-get deployer)
      .value-calculator-v1-1
    ))

    (try! (contract-call? .treasury-v1-1 transfer-tokens 
      'SPSCWDV3RKV5ZRN1FQD84YE1NQFEDJ9R1F4DYQ11.newyorkcitycoin-token-v2 
      balance-nyc
      (var-get deployer)
      .value-calculator-v1-1
    ))

    (ok true)
  )
)
