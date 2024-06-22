(define-read-only (get-user-zest (account principal) (block uint))
  (let (
    (block-hash (unwrap! (get-block-info? id-header-hash block) (err u666)))
  )

    (if (< block u143345)
      (ok u0)
      (if (< block u149389)
        (ok (at-block block-hash (get-user-zest-helper-1 account)))
        (ok (at-block block-hash (get-user-zest-helper-2 account)))
      )
    )
  )
)

(define-read-only (get-user-zest-helper-1 (account principal))
  (let (
    (user-wallet (unwrap-panic (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.zststx-v1-0 get-balance account)))
  )
    user-wallet
  )
)

(define-read-only (get-user-zest-helper-2 (account principal))
  (let (
    (user-wallet (unwrap-panic (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.zststx-v1-2 get-balance account)))
  )
    user-wallet
  )
)

