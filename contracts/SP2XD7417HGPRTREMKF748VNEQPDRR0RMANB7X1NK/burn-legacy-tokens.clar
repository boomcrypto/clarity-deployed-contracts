(impl-trait 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.proposal-trait.proposal-trait)
(define-constant target 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.bridge-endpoint-v1-02)
(define-constant target2 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.meta-bridge-endpoint-v2-04)
(define-public (execute (sender principal))
	(let (
			(abtc-bal (unwrap-panic (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-abtc get-balance-fixed target)))
			(lunr-bal (unwrap-panic (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-slunr get-balance-fixed target)))
			(susdt-bal (unwrap-panic (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-susdt get-balance-fixed target)))
			(not-bal (unwrap-panic (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wnot get-balance-fixed target2))))
		(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-abtc burn-fixed abtc-bal target))
		(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-slunr burn-fixed lunr-bal target))
		(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-susdt burn-fixed susdt-bal target))
		(try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.meta-bridge-endpoint-v2-04 transfer-all-to .meta-bridge-endpoint-v2-01 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wnot))
		(ok true)))