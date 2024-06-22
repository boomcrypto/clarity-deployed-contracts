(impl-trait .extension-trait.extension-trait)
(define-constant err-unauthorised (err u1000))
(define-public (migrate)
	(let (
			(sender tx-sender)
			(abtc-bal (unwrap-panic (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-abtc get-balance-fixed sender)))
			(susdt-bal (unwrap-panic (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-susdt get-balance-fixed sender)))
			(slunr-bal (unwrap-panic (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-slunr get-balance-fixed sender)))
			(ssko-bal (unwrap-panic (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-ssko get-balance-fixed sender)))
		)
		(and (> abtc-bal u0)
			(begin
				(as-contract (try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-abtc burn-fixed abtc-bal sender)))
				(as-contract (try! (contract-call? .token-abtc mint-fixed abtc-bal sender)))))
		(and (> susdt-bal u0)
			(begin
				(as-contract (try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-susdt burn-fixed susdt-bal sender)))
				(as-contract (try! (contract-call? .token-susdt mint-fixed susdt-bal sender)))))
		(and (> slunr-bal u0)
			(begin
				(as-contract (try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-slunr burn-fixed slunr-bal sender)))
				(as-contract (try! (contract-call? .token-slunr mint-fixed slunr-bal sender)))))
		(and (> ssko-bal u0)
			(begin
				(as-contract (try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-ssko burn-fixed ssko-bal sender)))
				(as-contract (try! (contract-call? .token-ssko mint-fixed ssko-bal sender)))))
		(ok true)))
(define-public (callback (sender principal) (payload (buff 2048)))
	(ok true))