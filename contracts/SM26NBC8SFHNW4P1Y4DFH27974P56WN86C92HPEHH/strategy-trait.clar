
;; SPDX-License-Identifier: BUSL-1.1

(define-trait strategy-trait
	(
		(execute ((buff 2048)) (response uint uint))
		(refund ((buff 2048)) (response uint uint))
		(get-amount-in-strategy () (response uint uint))
	)
)

