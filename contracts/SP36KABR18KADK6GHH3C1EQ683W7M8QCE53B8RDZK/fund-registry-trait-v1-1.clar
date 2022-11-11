(define-trait fund-registry-trait
  (
    (get-fund-count () (response uint uint))

    (get-fund-id-by-address ((buff 33)) (response (optional uint) uint))

    (get-fund-address-by-id (uint) (response (optional (buff 33)) uint))

    (is-fund-registered ((buff 33)) (response bool uint))
  )
)
