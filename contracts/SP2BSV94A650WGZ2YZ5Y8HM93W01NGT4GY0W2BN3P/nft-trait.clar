(define-trait nft-trait
  (
    ;; sip9 ;; return the last token id
    (get-last-token-id () (response uint uint)) 
    
    ;; sip9 ;; return the URI representing the metadata associated to the NFT
    (get-token-uri (uint) (response (optional (string-ascii 256)) uint))
    
    ;; sip9 ;; return the owner of the given token id
    (get-owner (uint) (response (optional principal) uint))
    
    ;; sip9 ;; transfer given token id from the sender to a new principal
    (transfer (uint principal principal) (response bool uint))

    ;; mint nft
    (mint (principal) (response uint uint))

    ;; set the dao as minting address
    (set-dao-address () (response principal uint))
  )  
)