(impl-trait .proposal-trait.proposal-trait)
(define-constant ONE_8 (pow u10 u8))
(define-constant validators
	(list 
		{validator: 'SP1TXQK4S7NWFN534P2R8ZDFWSV16VEK7854C64BP, pubkey: 0x02e10fe88c2b4a5ea7f8650a8fa63e93d93ec09207623d0de115f70427ca4654c1}
		{validator: 'SP2WKMX7RVFFJYAYA57MHRNG45MEC8JNWQJAKD0K8, pubkey: 0x025181b4afd3af8659bb47c0b79a681a20905889baa069bd0b8fbd79538eeb3775}
		{validator: 'SP3XVAKTAAZH4VSF4QKBBB8X1TNV2B4M4TMFEMAHB, pubkey: 0x02d1d3556a684c6a96d390892e866b7f48208f481a83cf2e80752485fb9e28fed3}
	)
)
(define-constant whitelist 
	(list 
		{user: 'SPKQ8HJ1ED0Y7YGGH72YJAVX9J73C0D0D6QVCJ8T, whitelisted: true}
		{user: 'SP9MANP57C4QHVMNHR9HEAX6D5BAA4JN9KC8N4J8, whitelisted: true}
		{user: 'SPY8YN3BJBF96FA3T916D5MFQQJ2GMKBNQ9X00PR, whitelisted: true}
		{user: 'SP22PCWZ9EJMHV4PHVS0C8H3B3E4Q079ZHY6CXDS1, whitelisted: true}
		{user: 'SP1NGMS9Z48PRXFAG2MKBSP0PWERF07C0KV9SPJ66, whitelisted: true}
		{user: 'SP31A0B5K60KHWM3S3JD0B47TG3R43PT1KRV7V53B, whitelisted: true}
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
		(try! (add-validator-many validators))
		(try! (whitelist-many whitelist))
		(ok true)
	)
)