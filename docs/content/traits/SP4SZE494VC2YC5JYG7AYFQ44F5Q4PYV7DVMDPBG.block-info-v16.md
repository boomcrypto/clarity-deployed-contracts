---
title: "Trait block-info-v16"
draft: true
---
```
(define-read-only (get-user-velar (account principal) (block uint))
  (let (
    (block-hash (unwrap! (get-block-info? id-header-hash block) (err u666)))
  )
    (if (< block u143600)
      (ok u0)
      (ok (at-block block-hash (get-user-velar-helper account block)))
    )
  )
)

(define-read-only (get-user-velar-helper (account principal) (block uint))
  (let (
    (total-lp-supply (unwrap-panic (contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.ststx-aeusdc get-total-supply)))
    (user-wallet (unwrap-panic (contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.ststx-aeusdc get-balance account)))
    (user-staked (if (< block u143607)
      u0
      (get end (contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.farming-ststx-aeusdc-core get-user-staked account))
    ))
    (user-total (+ user-wallet user-staked))

    (pool-info (contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-core do-get-pool u8))
  )

    (/ (* user-total (get reserve0 pool-info)) total-lp-supply)
  )
)
```
