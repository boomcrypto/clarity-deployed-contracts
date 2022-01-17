(define-trait ft-trait
  (
    ;; Transfer from the caller to a new principal
    (transfer (uint principal principal (optional (buff 34))) (response bool uint))

    ;; Human readable name of the token
    (get-name () (response (string-ascii 32) uint))

    ;; Ticker symbol, or empty if none
    (get-symbol () (response (string-ascii 32) uint))

    ;; Number of decimals used, e.g. 6 would mean 1_000_000 represents 1 token
    (get-decimals () (response uint uint))

    ;; Balance of the passed principal
    (get-balance (principal) (response uint uint))

    ;; Current total supply (which does not need to be a constant)
    (get-total-supply () (response uint uint))

    ;; Optional URI that represents metadata of this token
    (get-token-uri () (response (optional (string-utf8 256)) uint))
  )
)