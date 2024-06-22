
(define-read-only (get-user-hermetica (account principal) (block uint))
  (let (
    (block-hash (unwrap! (get-block-info? id-header-hash block) (err u666)))
  )
    (if (< block u146526)
      (ok u0)
      (ok (at-block block-hash (get-user-hermetica-helper account)))
    )
  )
)

(define-read-only (get-user-hermetica-helper (account principal))
  (let (
    (token-balance (unwrap-panic (contract-call? 'SPZA22A4D15RKH5G8XDGQ7BPC20Q5JNMH0VQKSR6.token-ststx-earn-v1 get-balance account)))
    (ratio (contract-call? 'SPZA22A4D15RKH5G8XDGQ7BPC20Q5JNMH0VQKSR6.vault-ststx-earn-v1 get-underlying-per-token))
  )
    (/ (* token-balance ratio) u1000000)
  )
)
