---
title: "Trait xip121"
draft: true
---
```

;; SPDX-License-Identifier: BUSL-1.1

(impl-trait 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.proposal-trait.proposal-trait)

(define-public (execute (sender principal))
	(begin		
(try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.cross-bridge-registry-v2-01 set-approved-pair { token: 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.token-wbtc, chain-id: u1 } { approved: true, burnable: true, fee: u100000, min-fee: u1074, min-amount: u1074, max-amount: u1074829639 }))
(try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.cross-bridge-registry-v2-01 set-approved-pair { token: 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.token-wbtc, chain-id: u2 } { approved: true, burnable: true, fee: u100000, min-fee: u1074, min-amount: u1074, max-amount: u1074829639 }))
(try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.cross-bridge-registry-v2-01 set-approved-pair { token: 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.token-wbtc, chain-id: u16 } { approved: true, burnable: true, fee: u100000, min-fee: u1074, min-amount: u1074, max-amount: u1074829639 }))
(try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.cross-bridge-registry-v2-01 set-approved-pair { token: 'SP673Z4BPB4R73359K9HE55F2X91V5BJTN5SXZ5T.token-wbtc, chain-id: u12 } { approved: true, burnable: true, fee: u100000, min-fee: u1074, min-amount: u1074, max-amount: u1074829639 }))
		(ok true)
	)
)

```
