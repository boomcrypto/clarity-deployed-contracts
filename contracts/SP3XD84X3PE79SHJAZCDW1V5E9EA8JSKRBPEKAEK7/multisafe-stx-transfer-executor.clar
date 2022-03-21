;; Title: Multi-Safe stx transfer executor
;; Author: Talha Bugra Bulut & Trust Machiness

(impl-trait 'SP3XD84X3PE79SHJAZCDW1V5E9EA8JSKRBPEKAEK7.multisafe-traits.executor-trait)
(use-trait safe-trait 'SP3XD84X3PE79SHJAZCDW1V5E9EA8JSKRBPEKAEK7.multisafe-traits.safe-trait)

(define-public (execute (safe <safe-trait>) (arg-p principal) (arg-u uint))
		(stx-transfer? arg-u (contract-of safe) arg-p)
)