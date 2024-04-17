;; title: trait-sip-010
;; description: A trait contains functions of SIP 010 standards

(define-trait sip-010-trait
  (
    ;; Transfer
    (transfer (uint principal principal (optional (buff 34))) (response bool uint))

    ;; Name
    (get-name () (response (string-ascii 32) uint))

    ;; Symbol
    (get-symbol () (response (string-ascii 32) uint))

    ;; Decimals
    (get-decimals () (response uint uint))

    ;; Balance
    (get-balance (principal) (response uint uint))

    ;; Total Supply
    (get-total-supply () (response uint uint))

    ;; Token Uri
    (get-token-uri () (response (optional (string-utf8 256)) uint))
  )
)