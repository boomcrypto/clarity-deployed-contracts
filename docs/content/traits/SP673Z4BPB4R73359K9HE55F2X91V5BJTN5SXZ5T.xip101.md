---
title: "Trait xip101"
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
{ extension: .btc-peg-in-endpoint-v2-05, enabled: false }
{ extension: .btc-peg-in-v2-07a, enabled: true }
{ extension: .btc-peg-in-v2-07-swap, enabled: false }
{ extension: .btc-peg-in-v2-07a-swap, enabled: true })))

(try! (contract-call? .btc-peg-in-endpoint-v2-05 pause-peg-in true))
(try! (contract-call? .btc-peg-in-v2-07a pause-peg-in false))
(try! (contract-call? .btc-peg-in-v2-07-swap pause-peg-in true))
(try! (contract-call? .btc-peg-in-v2-07a-swap pause-peg-in false))

(ok true)))

```
