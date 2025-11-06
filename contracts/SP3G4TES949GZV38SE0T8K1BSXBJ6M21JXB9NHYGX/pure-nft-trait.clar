(define-trait pure-nft-trait
  (
    ;; Last token ID, limited to uint range
    (get-last-token-id () (response uint uint))

    ;; URI for metadata associated with the token. It's recommended to use on-chain data instead.
    (get-token-uri (uint) (response (optional (string-ascii 256)) uint))

     ;; Owner of a given token identifier
    (get-owner (uint) (response (optional principal) uint))

    ;; Transfer from the sender to a new principal
    (transfer (uint principal principal) (response bool uint))

    ;; Collection attribute(none or json format)
    (get-collection-attribute () (response (optional (string-utf8 131072)) uint))

    ;; Collection icon data
    (get-collection-icon-data () (response (optional (buff 1022976)) uint))

    ;; Collection icon imei type
    (get-collection-icon-mime-type () (response (optional (string-utf8 256)) uint))

    ;; Data of a given token identifier
    (get-token-data (uint) (response (optional (buff 1022976)) uint))

    ;; MIME type of a given token identifier
    (get-token-data-mime-type (uint) (response (optional (string-utf8 256)) uint))

    ;; Attribute of a given token identifier(none or json format)
    (get-token-attribute (uint) (response (optional (string-utf8 16384)) uint))
  )
)
