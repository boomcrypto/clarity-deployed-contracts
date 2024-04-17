
(define-read-only (get-user-zest (account principal) (block uint))
  (let (
    (block-hash (unwrap! (get-block-info? id-header-hash block) (err u666)))
  )
    (if (< block u140388)
      (ok u0)
      (ok (at-block block-hash (get-user-zest-helper account)))
    )
  )
)

(define-read-only (get-user-zest-helper (account principal))
  (let (
    (user-index (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.pool-reserve-data get-user-index-read account .ststx-token))
  )
    (if (is-some user-index)
      (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.pool-read-supply get-supplied-balance-user-ststx account)
      u0
    )
  )
)
