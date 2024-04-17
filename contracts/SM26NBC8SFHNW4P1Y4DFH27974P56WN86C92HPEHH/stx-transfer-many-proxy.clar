
;; SPDX-License-Identifier: BUSL-1.1

(impl-trait .proxy-trait.proxy-trait)

(define-constant err-invalid-payload (err u4000))

(define-private (transfer (entry { ustx: uint, recipient: principal}) (previous (response bool uint)))
	(if (is-ok previous)
		(stx-transfer? (get ustx entry) tx-sender (get recipient entry))
		previous
	)
)

(define-public (proxy-call (payload (buff 2048)))
	(let ((decoded (unwrap! (from-consensus-buff? (list 30 { ustx: uint, recipient: principal }) payload) err-invalid-payload)))
		(fold transfer decoded (ok true))
	)
)
