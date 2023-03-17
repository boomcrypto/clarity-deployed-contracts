;; Hello alex
(define-data-var contract-owner principal tx-sender)

(define-public (hello-alex (dx uint) (min-dy uint))
  (let
    (
      (new-supply (try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.auto-alex get-token-given-position dx)))
    )
    (if (is-eq tx-sender (var-get contract-owner) )
      (begin
      (try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.auto-alex add-to-position dx))
      (try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.swap-helper-v1-03 swap-helper 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.auto-alex 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.age000-governance-token new-supply (some min-dy)))
        (ok true)
      )
      (ok true)
    )
  )
)