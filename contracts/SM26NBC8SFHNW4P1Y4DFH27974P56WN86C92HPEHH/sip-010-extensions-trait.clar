
;; SPDX-License-Identifier: BUSL-1.1

(define-trait sip-010-extensions-trait
  (
    (mint (uint principal) (response bool uint))
    (burn (uint principal) (response bool uint))
    (mint-fixed (uint principal) (response bool uint))
    (burn-fixed (uint principal) (response bool uint))  
    (transfer-fixed (uint principal principal (optional (buff 2048))) (response bool uint))
 )
)