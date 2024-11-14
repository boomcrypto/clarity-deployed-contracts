---
title: "Trait hic-1"
draft: true
---
```
(use-trait extension-trait 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.extension-trait.extension-trait)
(impl-trait 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.extension-trait.extension-trait)

(define-public (callback (tg principal) (bp (buff 2048)))
	(begin
		(print tx-sender)
		(print (stx-get-balance tx-sender))
		(try! (contract-call? 'SP2E3DNHPVJH045SSMFYN1DW7ZWGKYZBZZQPG6V1P.vault-v1
				flash-loan 'SP2ZMZWP1771TS9DGRDVKZ9E8KNDR8D9V3FRJW8FH.swap-router-v7 .token-wstx u10000000 tg bp))
		(ok true)
	)
)
```
