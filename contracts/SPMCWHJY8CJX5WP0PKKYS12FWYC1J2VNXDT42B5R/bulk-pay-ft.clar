;; By https://xnft.fan/#/

(define-trait pay_ft_trait
  (
    (transfer (uint principal principal (optional (buff 34))) (response bool uint))
  )
)

(define-public (bulk-pay (bAny bool) (ft <pay_ft_trait>) (items (list 200 { addr: principal, amount: uint, memo: (optional (buff 34)) })))
  (let
    (
      (ud (fold t items { ft: ft, result: (list ) }))
      (result (get result ud))
    )
    (if (or bAny (is-none (index-of? result false)))
      (ok result)
      (err result)
    )
  )
)

(define-private (t (item { addr: principal, amount: uint, memo: (optional (buff 34)) }) (ud { ft: <pay_ft_trait>, result: (list 200 bool) }))
  (let
    (
      (ff (get ft ud))
    )
    {
      ft: ff,
      result: (default-to (list ) (as-max-len? (append (get result ud) (is-ok (contract-call? ff transfer (get amount item) tx-sender (get addr item) (get memo item)))) u200))
    }
  )
)
