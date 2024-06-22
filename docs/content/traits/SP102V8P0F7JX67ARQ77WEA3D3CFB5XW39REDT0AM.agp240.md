---
title: "Trait agp240"
draft: true
---
```
(impl-trait .proposal-trait.proposal-trait)
(define-constant ONE_8 u100000000)
(define-constant MAX_UINT u340282366920938463463374607431768211455)
(define-public (execute (sender principal))
	(begin
			(try! (contract-call? .amm-registry-v2-01 set-start-block 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-susdt .token-wxusd u5000000 u0))
			(try! (contract-call? .amm-registry-v2-01 set-start-block 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-susdt 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-chax u100000000 u0))
			(try! (contract-call? .amm-registry-v2-01 set-start-block 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-abtc 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-ordg u100000000 u0))
			(try! (contract-call? .amm-registry-v2-01 set-start-block 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-abtc 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-ormm u100000000 u0))
			(try! (contract-call? .amm-registry-v2-01 set-start-block 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-abtc 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-ornj u100000000 u0))
			(try! (contract-call? .amm-registry-v2-01 set-start-block 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-abtc .token-wxbtc u5000000 u0))
			(try! (contract-call? .amm-registry-v2-01 set-start-block 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-abtc 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-db20 u100000000 u0))
			(try! (contract-call? .amm-registry-v2-01 set-start-block 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-abtc 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-ssko u100000000 u0))
			(try! (contract-call? .amm-registry-v2-01 set-start-block 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-abtc 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-tx20 u100000000 u0))
			(try! (contract-call? .amm-registry-v2-01 set-start-block 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-abtc 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.brc20-trio u100000000 u0))
			
			(ok true)
	)
)
(define-private (mul-down (a uint) (b uint))
	(/ (* a b) ONE_8))
```
