(define-trait nft-approvable-trait
  (
    ;; Last token ID, limited to uint range
    (get-last-token-id () (response uint uint))

    ;; URI for metadata associated with the token
    (get-token-uri (uint) (response (optional (string-ascii 256)) uint))

     ;; Owner of a given token identifier
    (get-owner (uint) (response (optional principal) uint))

     ;; Sets or unsets a user or contract principal who is allowed to call transfer
    (set-approval-for (uint principal) (response bool uint))

    ;; Transfer from the sender to a new principal - must be called by the
    ;; nft owner or by an approved address
    (transfer (uint principal principal) (response bool uint))
  )
)
