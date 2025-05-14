---
title: "Trait xip096"
draft: true
---
```
;; SPDX-License-Identifier: BUSL-1.1

(impl-trait 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.proposal-trait.proposal-trait)
(use-trait ft-trait 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.trait-sip-010.sip-010-trait)

(define-constant err-token-mismatch (err u1001))

(define-constant MAX_UINT u240282366920938463463374607431768211455)
(define-constant ONE_8 u100000000)

(define-public (execute (sender principal))
	(begin

(try! (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.executor-dao set-extensions (list
{ extension: .btc-peg-in-v2-05-launchpad, enabled: false }
{ extension: .cross-peg-in-v2-04-launchpad, enabled: false }
{ extension: .btc-peg-in-v2-05-launchpad-3a, enabled: true }
{ extension: .cross-peg-in-v2-04-launchpad-3a, enabled: true })))
	
(try! (contract-call? .btc-peg-in-v2-05-launchpad-3a set-fee-to-address 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.executor-dao))
(try! (contract-call? .btc-peg-in-v2-05-launchpad-3a set-peg-in-fee u0))
(try! (contract-call? .btc-peg-in-v2-05-launchpad-3a set-peg-in-min-fee u0))
(try! (contract-call? .btc-peg-in-v2-05-launchpad-3a pause-peg-in false))

(try! (contract-call? .cross-peg-in-v2-04-launchpad-3a set-paused false))

(ok true)))

```
