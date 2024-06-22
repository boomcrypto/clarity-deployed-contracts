;; usda-aeusdc-cycle-rewards-helper-v-1-4

(define-public (claim-cycle-rewards (cycles-list (list 120 uint)))
  (let (
    (pool (claim-rewards-pool))
    (diko (map claim-rewards-diko cycles-list))
  )
    (ok {pool: pool, diko: diko})
  )
)

(define-private (claim-rewards-pool)
  (let (
    (claim-a (try! (contract-call?
                   'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.earn-usda-aeusdc-v-1-5 claim-all-staking-rewards
                   'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token
                   'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc
                   'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.usda-aeusdc-lp-token-v-1-4)))
  )
    (ok claim-a)
  )
)

(define-private (claim-rewards-diko (cycle uint))
  (let (
    (claim-a (try! (contract-call?
                   'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.diko-emissions-usda-aeusdc-v-1-4 claim-cycle-rewards
                   cycle)))
  )
    (ok claim-a)
  )
)