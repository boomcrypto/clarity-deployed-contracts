(define-trait nft-trait
  (
    (get-last-token-id () (response uint uint))
    (get-token-uri () (response (string-ascii 256) uint))
    (get-owner (uint) (response (optional principal) uint))
    (transfer (uint principal principal) (response bool uint))
  )
)