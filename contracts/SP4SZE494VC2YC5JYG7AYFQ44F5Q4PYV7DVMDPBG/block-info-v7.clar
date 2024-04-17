
(define-read-only (get-user-velar (account principal) (block uint))
  (let (
    (block-hash (unwrap! (get-block-info? id-header-hash block) (err u666)))
  )
    (if (< block u143650)
      (ok u0)
      (ok (at-block block-hash (get-user-velar-helper account)))
    )
  )
)

(define-read-only (get-user-velar-helper (account principal))
  (let (
    (total-lp-supply (unwrap-panic (contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.ststx-aeusdc get-total-supply)))
    (user-lp-supply (unwrap-panic (contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.ststx-aeusdc get-balance account)))

    (pool-info (contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-core do-get-pool u8))
  )

    (/ (* user-lp-supply (get reserve0 pool-info)) total-lp-supply)
  )
)
