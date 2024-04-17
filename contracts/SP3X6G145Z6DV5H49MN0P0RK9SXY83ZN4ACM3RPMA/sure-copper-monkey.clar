

(define-read-only (do-this (account principal))
  (contract-call? 'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.pool-read-supply get-supplied-balance-user-ststx account)
)
