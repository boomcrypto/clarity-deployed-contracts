;; By https://xnft.fan/#/

(define-public (bulk-pay (bAny bool) (items (list 200 { addr: principal, amount: uint, memo: (optional (buff 34)) })))
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

(define-private (t (item { addr: principal, amount: uint, memo: (optional (buff 34)) }))
  (is-ok (stx-transfer-memo? (get amount item) tx-sender (get addr item) (default-to 0x (get memo item))))
)
