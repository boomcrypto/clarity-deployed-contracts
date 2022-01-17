(define-trait trait
  (
    ;; Transfer from the caller to a new principal
    (transfer (uint principal principal (optional (buff 34))) (response bool uint))

    ;; The human readable name of the token
    (get-name () (response (string-ascii 32) uint))

    ;; The ticker symbol, or empty if none
    (get-symbol () (response (string-ascii 32) uint))

    ;; The number of decimals used, e.g. 6 would mean 1_000_000 represents 1 token
    (get-decimals () (response uint uint))

    ;; The balance of the passed principal
    (get-balance (principal) (response uint uint))

    ;; The current total supply (which does not need to be a constant)
    (get-total-supply () (response uint uint))

    ;; An optional URI that represents metadata of this token
    (get-token-uri () (response (optional (string-utf8 256)) uint))
  )
)