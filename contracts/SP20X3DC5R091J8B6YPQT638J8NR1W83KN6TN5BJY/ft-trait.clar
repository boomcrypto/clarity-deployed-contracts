;;; Add mint, set-owner to SIP010 trait.

(define-trait ft-trait
  ((mint (uint principal) (response bool uint))
  (set-owner (principal) (response bool uint))
  (get-max-supply () (response uint uint))
 
  ;;; SIP010 trait.
  (transfer (uint principal principal (optional (buff 34))) (response bool uint))
  (get-name () (response (string-ascii 32) uint))
  (get-symbol () (response (string-ascii 32) uint))
  (get-decimals () (response uint uint))
  (get-balance (principal) (response uint uint))
  (get-total-supply () (response uint uint))
  (get-token-uri () (response (optional (string-utf8 256)) uint)) ))
