(define-trait biddable-nft
    (
      ;; Last token ID, limited to uint range
      (get-last-token-id () (response uint uint))

      ;; URI for metadata associated with the token
      (get-token-uri (uint) (response (optional (string-ascii 256)) uint))

       ;; Owner of a given token identifier
      (get-owner (uint) (response (optional principal) uint))

      ;; Transfer from the sender to a new principal
      (transfer (uint principal principal) (response bool uint))

      ;; Get the royalty percentage for sales and bids
      (get-royalty-percent () (response uint uint))

      ;; Get the royalty/artist address for sales and bids
      (get-artist-address () (response principal uint))
    )
)