;; hello alex

(define-data-var OPa5F principal tx-sender)
(define-constant QFMGM (err u1377))


(define-private (check-is-owner)
  (ok (asserts! (is-eq tx-sender (var-get OPa5F)) QFMGM))
)
(define-public (start-zeus (jo3YP uint) (min-dy uint) (offset uint))
      (let
          (
              (OLEQt (unwrap-panic (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.swap-helper-v1-03 swap-helper 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wstx 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.age000-governance-token jo3YP none)))
              (willget-p4Ce1 (unwrap-panic (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.auto-alex get-token-given-position OLEQt)))
              (new-OLEQt (unwrap-panic (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.swap-helper-v1-03 get-given-helper 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.age000-governance-token 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.auto-alex willget-p4Ce1)))
          )
          (try! (check-is-owner))
          (let
          (
            (fS2sV (get new-dx (fold zeus 0x000000000000000000000000000000000000000000000000000000000000000000000000000000 {dx: OLEQt, new-dx: new-OLEQt, min-dy: min-dy, offset: offset})))
            (new-jo3YP (unwrap-panic (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.swap-helper-v1-03 swap-helper 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.age000-governance-token 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wstx fS2sV none)))
          )
          (ok true)
          )
      )
)
(define-private (zeus (i (buff 1)) (d {dx: uint, new-dx: uint, min-dy: uint, offset: uint}))
  (if (and (> (+ (get new-dx d) (get offset d)) (get dx d)) (> (get dx d) u5000000000))
      (let
          (
              (p4Ce1 (unwrap-panic (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.auto-alex get-token-given-position (get dx d))))
              (p2Jt3 (unwrap-panic (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.auto-alex add-to-position (get dx d))))
              (new-OLEQt (unwrap-panic (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.swap-helper-v1-03 swap-helper 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.auto-alex 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.age000-governance-token p4Ce1 none)))
          )
          (begin
          {dx: (get new-dx d), new-dx: new-OLEQt, min-dy: (get min-dy d), offset: (get offset d)}
          )
      )
      d
  )
)
