;; hello 1011 
(define-public (name-renewal)
  (begin
    (let
        (
        (nameinfo (unwrap-panic (contract-call? 'SP000000000000000000002Q6VF78.bns resolve-principal tx-sender)))
        (nameprice (unwrap-panic (contract-call? 'SP000000000000000000002Q6VF78.bns get-name-price (get namespace nameinfo) (get name nameinfo))))
        )
        (print nameinfo)
        (ok true)
    )
  )
)