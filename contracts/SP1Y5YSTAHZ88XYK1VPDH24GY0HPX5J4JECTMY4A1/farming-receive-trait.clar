;;; Receive notification about token transfer.
(use-trait ft-trait 'SP2AKWJYC7BNY18W1XXKPGP0YVEK63QJG4793Z2D4.sip-010-trait-ft-standard.sip-010-trait)

;; token amt from -> true
(define-trait farming-receive-trait
  ((receive (<ft-trait> uint principal) (response bool uint))
))

;;; eof
