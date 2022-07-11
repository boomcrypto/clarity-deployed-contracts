(use-trait ft-trait .sip010-ft-trait.sip010-ft-trait)

(define-private (transfer-stx (recipient { to: principal, amount: uint }))
  (stx-transfer? (get amount recipient) tx-sender (get to recipient)))

(define-private (check-err (result (response bool uint)) (prior (response bool uint)))
  (match prior ok-value result
               err-value (err err-value)))
			   
(define-public (transfer-stx-many (recipients (list 400 { to: principal, amount: uint })))
  (fold check-err
    (map transfer-stx recipients)
    (ok true)))

(define-private (transfer-ft-many-core (recipient {amount: uint, sender: principal, to: principal}) (token-contract <ft-trait>))
	(begin
		(unwrap-panic (contract-call? token-contract transfer (get amount recipient) (get sender recipient) (get to recipient) none))
		token-contract
	)
)

(define-public (transfer-ft-many (recipients (list 400 {amount: uint, sender: principal, to: principal})) (token-contract <ft-trait>))
	(begin
		(fold transfer-ft-many-core recipients token-contract)
		(ok true)
	)
)
