(define-read-only (zest-ststx (account principal))
  (let (
    (user-index (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.pool-reserve-data get-user-index-read account .ststx-token))
  )
    (if (is-some user-index)
      (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.pool-read-supply get-supplied-balance-user-ststx account)
      u0
    )
  )
)
