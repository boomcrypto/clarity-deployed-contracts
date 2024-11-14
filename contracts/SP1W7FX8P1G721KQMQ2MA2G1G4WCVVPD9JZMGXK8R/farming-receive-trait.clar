;;; Receive notification about token transfer.
(use-trait ft-trait 'SP1W7FX8P1G721KQMQ2MA2G1G4WCVVPD9JZMGXK8R.sip-010-trait-ft-standard.sip-010-trait)

;; token amt from -> true
(define-trait farming-receive-trait
  ((receive (<ft-trait> uint principal) (response bool uint))
))

;;; eof