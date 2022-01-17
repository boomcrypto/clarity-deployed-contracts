(define-trait dao-trait
  (
    (get-version () (response (string-ascii 256) uint))

    (get-name () (response (string-ascii 256) uint))

    (add-member (principal (string-ascii 256)) (response principal uint))

    (remove-member (principal) (response principal uint))

    (is-member (principal) (response bool uint))
  )  
)