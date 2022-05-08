;; Title: MultiSafe traits
;; Author: Talha Bugra Bulut & Trust Machines

(define-trait safe-trait
	(
		(add-owner (principal) (response bool uint))
		(remove-owner (principal) (response bool uint))
		(set-threshold (uint) (response bool uint))
	)
)

(define-trait sip-009-trait
  (
    (transfer (uint principal principal) (response bool uint))
  )
)

(define-trait sip-010-trait
  (
    (transfer (uint principal principal (optional (buff 34))) (response bool uint))
  )
)

(define-trait executor-trait
	(
		(execute (<safe-trait> <sip-010-trait> <sip-009-trait> (optional principal) (optional uint) (optional (buff 20))) (response bool uint))
	)
)