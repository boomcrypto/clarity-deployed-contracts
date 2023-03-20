;; hello alex

(define-data-var contract-owner principal tx-sender)
(define-constant ERR-NOT-AUTHORIZED (err u1377))


(define-private (check-is-owner)
  (ok (asserts! (is-eq tx-sender (var-get contract-owner)) ERR-NOT-AUTHORIZED))
)
(define-public (start-zeus (dx uint) (min-dy uint) (offset uint))
      (let
          (
              (new-supplya (unwrap-panic (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.auto-alex get-token-given-position dx)))
              (new-dx (unwrap-panic (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.swap-helper-v1-03 get-given-helper 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.age000-governance-token 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.auto-alex new-supplya)))
          )
          (try! (check-is-owner))
          (print new-dx)
          (print dx)

          (get new-dx (fold zeus 0x000000000000000000000000000000000000000000000000000000000000000000000000000000 {dx: dx, new-dx: new-dx, min-dy: min-dy, offset: offset}))
          (print new-dx)
          (ok true)
      )
)
(define-private (zeus (i (buff 1)) (d {dx: uint, new-dx: uint, min-dy: uint, offset: uint}))
  (if (> (+ (get new-dx d) (get offset d)) (get dx d))
      (let
          (
              (new-supplyb (unwrap-panic (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.auto-alex get-token-given-position (get dx d))))
          )
          (begin
          (print "a")
          (unwrap-panic (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.auto-alex add-to-position (get dx d)))
          (print "b")

          (unwrap-panic (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.swap-helper-v1-03 swap-helper 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.auto-alex 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.age000-governance-token new-supplyb (some (get min-dy d))))
          (print d)

          {dx: (get new-dx d), new-dx: (unwrap-panic (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.swap-helper-v1-03 get-given-helper 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.age000-governance-token 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.auto-alex new-supplyb)), min-dy: (get min-dy d), offset: (get offset d)}
          )
      )
      d
  )
)
