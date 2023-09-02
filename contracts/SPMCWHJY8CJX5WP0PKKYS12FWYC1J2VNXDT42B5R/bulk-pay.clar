;; By https://xnft.fan/#/

(define-public (bulk-pay (bAny bool) (items (list 200 { addr: principal, amount: uint })))
  (let
    (
      (result (map t items))
    ) 
    (if (or bAny (is-none (index-of? result false)))
      (ok result) 
      (err result)
    )
  )
)

(define-private (t (item { addr: principal, amount: uint }))
  (is-ok (stx-transfer? (get amount item) tx-sender (get addr item)))
)
