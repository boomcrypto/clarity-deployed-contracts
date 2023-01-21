(impl-trait .proposal-trait.proposal-trait)
(define-constant ONE_8 (pow u10 u8))
(define-constant validators
	(list 
		{validator: 'SP1A6F9ABHQMVP92GH7T9ZBF029T1WG3SHPNMKT0D, pubkey: 0x03117a1df7d27fa8bceb2f45602f303b57c334a1b6418d2b5555fd770d2b3e9c13}
	)
)
(define-constant whitelist 
	(list 
		{user: 'SP1AJA50BJ395R622N59B0VHWR25XPQH8WEPJ2VZV, whitelisted: true}
	)
)
(define-private (check-err (result (response bool uint)) (prior (response bool uint)))
    (match prior 
        ok-value result
        err-value (err err-value)
    )
)
(define-private (add-validator-from-tuple (validator { validator: principal, pubkey: (buff 33)}))
  (begin
  	(try! (contract-call? .bridge-endpoint add-validator (get pubkey validator) (get validator validator)))
	(ok true)
  )
)
(define-private (add-validator-many (validated (list 100 { validator: principal, pubkey: (buff 33)})))
  (fold check-err (map add-validator-from-tuple validated) (ok true))
)
(define-private (whitelist-from-tuple (whitelisted { user: principal, whitelisted: bool}))
  (contract-call? .bridge-endpoint whitelist (get user whitelisted) (get whitelisted whitelisted))
)
(define-private (whitelist-many (whitelisted (list 100 { user: principal, whitelisted: bool})))
  (fold check-err (map whitelist-from-tuple whitelisted) (ok true))
)
(define-public (execute (sender principal))
	(begin
		(try! (contract-call? .amm-swap-pool set-max-in-ratio u50000000))
		(try! (add-validator-many validators))
		(try! (whitelist-many whitelist))
		(ok true)
	)
)