;; This trait is a subset of the functions of sip-009 trait for NFTs.
(define-trait tradables-trait
  (
     ;; Owner of a given token identifier
    (get-owner (uint) (response (optional principal) uint))
    ;; Transfer from the sender to a new principal
    (transfer (uint principal principal) (response bool uint))
  )
)