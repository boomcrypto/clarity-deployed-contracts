(define-trait ft-trait
  (
    ;; Transfer from the caller to a new principal
    (transfer (uint principal principal (optional (buff 34))) (response bool uint))

    ;; human readable name of the token
    (get-name () (response (string-ascii 32) uint))

    ;; ticker symbol or empty if none
    (get-symbol () (response (string-ascii 32) uint))

    ;; number of decimals used
    (get-decimals () (response uint uint))

    ;; balance of the passed principal
    (get-balance (principal) (response uint uint))

    ;; current total supply
    (get-total-supply () (response uint uint))

    ;; optional URI that represents metadata of this token
    (get-token-uri () (response (optional (string-utf8 256)) uint))
  )
)