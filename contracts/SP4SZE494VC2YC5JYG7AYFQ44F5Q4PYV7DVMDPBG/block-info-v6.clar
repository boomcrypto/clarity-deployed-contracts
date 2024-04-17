
(define-read-only (get-user-arkadiko (account principal) (block uint))
  (let (
    (block-hash (unwrap! (get-block-info? id-header-hash block) (err u666)))
  )
    (if (< block u142425)
      (ok u0)
      (ok (at-block block-hash (get-user-arkadiko-helper account)))
    )
  )
)

(define-read-only (get-user-arkadiko-helper (account principal))
  (let (
    (vault-info (unwrap-panic (contract-call? 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-vaults-data-v1-1 get-vault account .ststx-token)))
  )
    (get collateral vault-info)
  )
)
