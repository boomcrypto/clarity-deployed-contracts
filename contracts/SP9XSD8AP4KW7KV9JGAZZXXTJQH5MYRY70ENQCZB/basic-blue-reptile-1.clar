(define-public (calculate-cumulated (account principal))
  (let (
    (previous-balance (unwrap-panic
      (contract-call?
        'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.zsusdt-v2-0
        get-principal-balance
        account))
    )
    ;; (balance-increase
    ;;   (-
    ;;     (unwrap-panic (contract-call?
    ;;       'SP2VCQJGH7PHP2DJK7Z0V48AGBHQAW3R3ZW1QF4N.zsusdt-v2-0
    ;;       get-balance account)
    ;;     )
    ;;     previous-balance))
    )

    ;; (ok (print {
    ;;   previous-user-balance: previous-balance,
    ;;   current-balance: (+ previous-balance balance-increase),
    ;;   balance-increase: balance-increase,
    ;;   index: new-user-index,
    ;; })
    (ok true)
  )
)