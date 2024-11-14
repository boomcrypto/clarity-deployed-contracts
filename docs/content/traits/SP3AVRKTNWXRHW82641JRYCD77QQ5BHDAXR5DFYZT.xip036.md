---
title: "Trait xip036"
draft: true
---
```
;; SPDX-License-Identifier: BUSL-1.1

(impl-trait 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.proposal-trait.proposal-trait)

(define-constant MAX_UINT u240282366920938463463374607431768211455)
(define-constant ONE_8 u100000000)

(define-public (execute (sender principal))
	(begin
			(try! (process-request u192))
			(try! (process-request u1611))
			(try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-abtc burn-fixed (* u568 ONE_8) 'SP1ESCTF9029MH550RKNE8R4D62G5HBY8PBBAF2N8))
			(ok true)))

(define-private (process-request (request-id uint))
	(let (
			(request (try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.btc-bridge-registry-v2-01 get-request-or-fail request-id))))
		(try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.token-abtc burn-fixed (+ (get amount-net request) (get fee request) (get gas-fee request)) 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.btc-peg-out-endpoint-v2-01))
		(contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.btc-bridge-registry-v2-01 set-request request-id (merge request { finalized: true }))))

```
