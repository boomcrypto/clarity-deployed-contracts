;;; Add mint and burn to SIP010 trait.

(define-trait ft-plus-trait
  ((mint (uint principal) (response bool uint))
   (burn (uint principal) (response bool uint))

   ;; sip-010-trait
   (transfer (uint principal principal (optional (buff 34)))
             (response bool uint))
   (get-name         ()          (response (string-ascii 32) uint))
   (get-symbol       ()          (response (string-ascii 32) uint))
   (get-decimals     ()          (response uint uint))
   (get-balance      (principal) (response uint uint))
   (get-total-supply ()          (response uint uint))
   (get-token-uri    ()          (response (optional (string-utf8 256)) uint))
  ))

;;; eof
