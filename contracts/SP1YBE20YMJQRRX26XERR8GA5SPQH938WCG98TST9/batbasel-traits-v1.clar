;; batbasel traits
;; contractType: public

(define-trait sip009-nft-trait
  (
    ;; Last token ID, limited to uint range
    (get-last-token-id () (response uint uint))

    ;; URI for metadata associated with the token
    (get-token-uri (uint) (response (optional (string-ascii 256)) uint))

    ;; Owner of a given token identifier
    (get-owner (uint) (response (optional principal) uint))

    ;; Transfer from the sender to a new principal
    (transfer (uint principal principal) (response bool uint))
  )
)

;; This trait is a subset of the functions of sip-009 trait for NFTs.
(define-trait tradables-trait
  (
    ;; Owner of a given token identifier
    (get-owner (uint) (response (optional principal) uint))

    ;; Transfer from the sender to a new principal
    (transfer (uint principal principal) (response bool uint))
  )
)

(define-trait commission-trait
  (
    ;; Pay a commission
    (pay (uint uint) (response bool uint))
  )
)
