
;; SPDX-License-Identifier: BUSL-1.1

(impl-trait .proxy-trait.proxy-trait)

(define-constant err-invalid-payload (err u4000))

(define-public (proxy-call (payload (buff 2048)))
	(let ((decoded (unwrap! (from-consensus-buff? { ustx: uint, recipient: principal } payload) err-invalid-payload)))
		(stx-transfer? (get ustx decoded) tx-sender (get recipient decoded))
	)
)
