---
title: "Trait xip026"
draft: true
---
```
(impl-trait .proposal-trait.proposal-trait)
(define-constant MAX_UINT u240282366920938463463374607431768211455)
(define-public (execute (sender principal))
	(begin
(try! (contract-call? .btc-peg-in-endpoint-v2-02 set-peg-in-fee u250000))
(try! (contract-call? .btc-peg-in-endpoint-v2-02 set-peg-in-min-fee u5000))
(try! (contract-call? .btc-peg-out-endpoint-v2-01 set-peg-out-fee u250000))
(try! (contract-call? .btc-peg-out-endpoint-v2-01 set-peg-out-min-fee u5000))
(ok true)))
```
