(define-public (set-many (lists (list 2000 { user: principal, amount: uint })))
  (ok (map set lists))
)

(define-public (set (l { user: principal, amount: uint }))
  (contract-call? .STX set (get amount l) (get user l))
)
