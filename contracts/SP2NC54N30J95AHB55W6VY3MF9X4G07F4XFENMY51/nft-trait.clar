
;; nft-trait
;; standard nft trait
(define-trait nft-trait
  (
    ;; Last token ID created by the contract, limited to uint range
    (get-last-token-id () (response uint uint))

    ;; URI (link)  for metadata associated with the token ID
    (get-token-uri (uint) (response (optional (string-ascii 256)) uint))

     ;; returns the owner of a given token ID
    (get-owner (uint) (response (optional principal) uint))

    ;; Transfer ownership from the sender to a new principal
    (transfer (uint principal principal) (response bool uint))
  )
)
