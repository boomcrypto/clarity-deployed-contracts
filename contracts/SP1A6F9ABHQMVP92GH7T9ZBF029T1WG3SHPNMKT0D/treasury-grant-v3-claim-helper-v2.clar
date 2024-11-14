(define-public (claim (token-id uint))
	(begin 
		(try! (contract-call? 'SP1E0XBN9T4B10E9QMR7XMFJPMA19D77WY3KP2QKC.treasury-grant-v3 claim-alex token-id))
		(let ((claim-details (try! (contract-call? 'SP1E0XBN9T4B10E9QMR7XMFJPMA19D77WY3KP2QKC.treasury-grant-v3 get-claim-details-or-fail token-id))))
			(if (> (get max-stx-claim claim-details) u0)
				(contract-call? 'SP1E0XBN9T4B10E9QMR7XMFJPMA19D77WY3KP2QKC.treasury-grant-v3 claim-stx token-id)
				(ok true)))))
