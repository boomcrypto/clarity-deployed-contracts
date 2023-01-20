(impl-trait .proposal-trait.proposal-trait)
(define-constant ONE_8 (pow u10 u8))
(define-constant required-validators u3)
(define-constant xusd-fee u100000)
(define-constant xusd-min u0)
(define-constant xusd-max u10000000000000)
(define-constant ethereum-min ONE_8)
(define-constant relayer 'SP1TRZ5CNQJF1Q7NHAPQHVS13M8TV1K0BTQHCQHQ9)
(define-constant receiver 'SP3Y72B4DZ7VGDRKBR8YDX08SJGCMN6K5JKF2F13V)
(define-constant validators
	(list 
		{validator: 'SP3BQ65DRM8DMTYDD5HWMN60EYC0JFS5NC2V5CWW7, pubkey: 0x034c41bb5da0625d4f825766b2a492510433a420e241b5b1fe915d61d06e63ba59}
		{validator: 'SP20F5HAX0W3AEG8M5C9J2880132CQTP6TYHSP04M, pubkey: 0x039db65524b3f1591344840a8817482cd8341d9b6d7471420f85eb508828c90b38}
		{validator: 'SP2C746EXD0702XY2CK0PSBF66GE8K9GYMNK7P6BZ, pubkey: 0x039be988f26e59e2c1e5b41903fb69573edbf8354870524a0c1f096588cb6192ec}
	)
)
(define-constant whitelist 
	(list 
		{user: 'SP3BQ65DRM8DMTYDD5HWMN60EYC0JFS5NC2V5CWW7, whitelisted: true}
		{user: 'SP20F5HAX0W3AEG8M5C9J2880132CQTP6TYHSP04M, whitelisted: true}
		{user: 'SP2C746EXD0702XY2CK0PSBF66GE8K9GYMNK7P6BZ, whitelisted: true}
		{user: 'SP1TXQK4S7NWFN534P2R8ZDFWSV16VEK7854C64BP, whitelisted: true}
		{user: 'SP2WKMX7RVFFJYAYA57MHRNG45MEC8JNWQJAKD0K8, whitelisted: true}
		{user: 'SP3XVAKTAAZH4VSF4QKBBB8X1TNV2B4M4TMFEMAHB, whitelisted: true}
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
		(try! (contract-call? .bridge-endpoint apply-whitelist true))
		(try! (contract-call? .bridge-endpoint set-approved-token .token-wxusd true xusd-fee xusd-min xusd-max))
		(try! (contract-call? .bridge-endpoint set-required-validators required-validators))
		(try! (add-validator-many validators))
		(try! (whitelist-many whitelist))
		(try! (contract-call? .bridge-endpoint set-approved-recipient receiver true))
		(try! (contract-call? .bridge-endpoint approve-relayer relayer true))
		(try! (contract-call? .bridge-endpoint set-approved-chain u0 { name: u"ethereum", min-fee: ethereum-min, buff-length: u64 }))
		(try! (contract-call? .bridge-endpoint set-paused false))		
		(ok true)
	)
)