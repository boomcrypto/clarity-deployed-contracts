;;; 0x0

(use-trait ft-trait 'SP2AKWJYC7BNY18W1XXKPGP0YVEK63QJG4793Z2D4.sip-010-trait-ft-standard.sip-010-trait)

(define-public
 (burn
  (token <ft-trait>)
  (amt   uint))
 (let ((from tx-sender)
       (to   (as-contract tx-sender))) ;; this
   (contract-call? token transfer amt from to (some 0x6275726e))))

;;; eof
