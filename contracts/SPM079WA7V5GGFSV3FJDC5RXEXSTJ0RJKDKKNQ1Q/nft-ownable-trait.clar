(define-trait nft-ownable-trait
  (
    ;;SIP-009: Last token ID, limited to uint range
    (get-last-token-id () (response uint uint))

    ;;SIP-009: URI for metadata associated with the token
    (get-token-uri (uint) (response (optional (string-ascii 256)) uint))

    ;;SIP-009: Owner of a given token identifier
    (get-owner (uint) (response (optional principal) uint))

    ;;SIP-009: Transfer from the sender to a new principal
    (transfer (uint principal principal) (response bool uint))

    ;;Set Owner of contract
    (set-contract-owner (principal) (response bool uint))

    ;;Get Owner of contract
    (get-contract-owner () (response principal uint))
    
    ;;Mint Token
    (mint (uint principal) (response bool uint))
  )
)