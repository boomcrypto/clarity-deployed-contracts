---
title: "Trait agp299"
draft: true
---
```
(impl-trait .proposal-trait.proposal-trait)
(define-public (execute (sender principal))
	(let (
			(bal-listx u1066850609700)
			(bal-alex u477682298591693)
			(bal-abtc u3182047176)
			(bal-slunr u1408618105259)
			(bal-ssko u301417454675)
			(bal-susdt u5883889562684)			
			(fee-listx (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.cross-bridge-registry-v2-01 get-accrued-fee-or-default 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wvlqstx))
			(fee-alex (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.cross-bridge-registry-v2-01 get-accrued-fee-or-default 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.age000-governance-token))
			(fee-abtc (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.cross-bridge-registry-v2-01 get-accrued-fee-or-default 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-abtc))
			(fee-slunr (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.cross-bridge-registry-v2-01 get-accrued-fee-or-default 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-slunr))
			(fee-ssko (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.cross-bridge-registry-v2-01 get-accrued-fee-or-default 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-ssko))
			(fee-susdt (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.cross-bridge-registry-v2-01 get-accrued-fee-or-default 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-susdt)))
			(and (> fee-listx u0) (try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wvlqstx transfer-fixed fee-listx tx-sender 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.executor-dao none)))
			(and (> (- bal-listx fee-listx) u0) (try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wvlqstx transfer-fixed (- bal-listx fee-listx) tx-sender 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.cross-bridge-registry-v2-01 none)))
			(try! (contract-call? .migrate-legacy-v2-wl migrate))
			(try! (contract-call? .migrate-legacy-v2-wl finalise-migrate tx-sender))
			(and (> fee-alex u0) (try! (contract-call? .token-alex transfer-fixed fee-alex tx-sender 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.executor-dao none)))
			(and (> (- bal-alex fee-alex) u0) (try! (contract-call? .token-alex transfer-fixed (- bal-alex fee-alex) tx-sender 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.cross-bridge-registry-v2-01 none)))
			(try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.migrate-legacy migrate))
			(and (> fee-abtc u0) (try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-abtc transfer-fixed fee-abtc tx-sender 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.executor-dao none)))		
			(and (> (- bal-abtc fee-abtc) u0) (try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-abtc transfer-fixed (- bal-abtc fee-abtc) tx-sender 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.cross-bridge-registry-v2-01 none)))
			(and (> fee-slunr u0) (try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-slunr transfer-fixed fee-slunr tx-sender 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.executor-dao none)))		
			(and (> (- bal-slunr fee-slunr) u0) (try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-slunr transfer-fixed (- bal-slunr fee-slunr) tx-sender 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.cross-bridge-registry-v2-01 none)))
			(and (> fee-ssko u0) (try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-ssko transfer-fixed fee-ssko tx-sender 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.executor-dao none)))		
			(and (> (- bal-ssko fee-ssko) u0) (try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-ssko transfer-fixed (- bal-ssko fee-ssko) tx-sender 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.cross-bridge-registry-v2-01 none)))
			(and (> fee-susdt u0) (try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-susdt transfer-fixed fee-susdt tx-sender 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.executor-dao none)))		
			(and (> (- bal-susdt fee-susdt) u0) (try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-susdt transfer-fixed (- bal-susdt fee-susdt) tx-sender 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.cross-bridge-registry-v2-01 none)))			
			(ok true)))
```
