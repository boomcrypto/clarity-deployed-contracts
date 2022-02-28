(define-trait claim-trait
  (
    (claim () (response uint uint))
  )
)

(use-trait ft-trait 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.trait-sip-010.sip-010-trait)

(define-public (ft-mint (nft <claim-trait>) (ft <ft-trait>) (ft-price uint) (min-dy uint))
  (begin
    (try! (contract-call?
      'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.fixed-weight-pool-v1-01
      swap-helper
      ft
      'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wstx
      u50000000
      u50000000
      ft-price
      (some min-dy)
    ))
    (ok (contract-call? nft claim))
  )
)
