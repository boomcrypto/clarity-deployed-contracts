(define-public (claim-cycle-rewards-multi (cycles-list (list 120 uint)))
  (let (
    (earn (claim-cycle-rewards-earn))
    (emissions (map claim-cycle-rewards-emissions cycles-list))
  )
    (ok {earn: earn, emissions: emissions})
  )
)

(define-private (claim-cycle-rewards-earn)
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

(define-private (claim-cycle-rewards-emissions (cycle uint))
  (let (
    (call (try! (contract-call?
          'SPEXN2X0M0CJ55K8GAJZEEH3A0JP64ZE7XD9XMKY.colorful-olive-krill claim-cycle-rewards
          cycle)))
  )
    (ok call)
  )
)