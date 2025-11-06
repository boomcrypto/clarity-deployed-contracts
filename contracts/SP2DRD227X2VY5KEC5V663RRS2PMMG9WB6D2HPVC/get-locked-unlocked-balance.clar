(define-read-only (get-stx-balances (user principal))
  (let
    (
      (acct (stx-account user))
      (locked (get locked acct))
      (unlocked (get unlocked acct))
      (unlock-height (get unlock-height acct))
      (total (stx-get-balance user))
    )
    (ok
      (tuple
        (locked locked)
        (unlocked unlocked)
        (unlock-height unlock-height)
        (total total)
      )
    )
  )
)
