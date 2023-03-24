;; hello alex

(define-data-var contract-owner principal tx-sender)
(define-constant ERR-NOT-AUTHORIZED (err u1377))


(define-private (check-is-owner)
  (ok (asserts! (is-eq tx-sender (var-get contract-owner)) ERR-NOT-AUTHORIZED))
)
(define-public (start-zeus (stx-amount uint) (min-dy uint) (offset uint))
      (let
          (
              (dxa (unwrap-panic (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.swap-helper-v1-03 swap-helper 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wstx 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.age000-governance-token stx-amount none)))
              (dxb (unwrap-panic (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.age000-governance-token get-balance tx-sender)))
          )
          (try! (check-is-owner))
          (print dxa)
          (print "aa")
          (print dxb)
          (ok true)
      )
)

