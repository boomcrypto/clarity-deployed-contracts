---
title: "Trait xip136"
draft: true
---
```

;; SPDX-License-Identifier: BUSL-1.1

(impl-trait 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.proposal-trait.proposal-trait)

(define-constant MAX_UINT u240282366920938463463374607431768211455)
(define-constant ONE_8 u100000000)

(define-public (execute (sender principal))
	(begin		
		(try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.executor-dao set-extensions (list
			{ extension: .btc-peg-in-v2-07e-agg, enabled: false }
			{ extension: .btc-peg-in-v2-07f-agg, enabled: true }
			
		)))
		(try! (contract-call? .btc-peg-in-v2-07e-agg pause-peg-in true))
		(try! (contract-call? .btc-peg-in-v2-07f-agg pause-peg-in false))

(try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.cross-bridge-registry-v2-01 set-approved-pair { token: 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.bsc-ghiblicz, chain-id: u2 } { approved: true, burnable: true, fee: u100000, min-fee: u12812299807, min-amount: u12812299807, max-amount: u12812299807815502 }))
(try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.cross-bridge-registry-v2-01 set-token-reserve { token: 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.bsc-ghiblicz, chain-id: u2 } MAX_UINT))		
		(ok true)
	)
)

```
