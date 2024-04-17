(define-public (claim-cycle-rewards (cycles-list (list 120 uint)))
  (let (
    (pool (claim-cycle-rewards-pool))
    (diko (map claim-cycle-rewards-diko cycles-list))
  )
    (ok {pool: pool, diko: diko})
  )
)

(define-private (claim-cycle-rewards-pool)
  (let (
    (call (try! (contract-call?
          'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.earn-usda-aeusdc-v-1-2 claim-all-staking-rewards
          'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token
          'SP3Y2ZSH8P7D50B0VBTSX11S7XSG24M1VB9YFQA4K.token-aeusdc
          'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.usda-aeusdc-lp-token-v-1-2)))
  )
    (ok call)
  )
)

(define-private (claim-cycle-rewards-diko (cycle uint))
  (let (
    (call (try! (contract-call?
          'SPQC38PW542EQJ5M11CR25P7BS1CA6QT4TBXGB3M.diko-emissions-usda-aeusdc-v-1-2 claim-cycle-rewards
          cycle)))
  )
    (ok call)
  )
)