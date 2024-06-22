---
title: "Trait send-many"
draft: true
---
```
(use-trait ft-trait .trait-sip-010.sip-010-trait)
(define-private (check-err (result (response bool uint)) (prior (response bool uint)))
  (match prior ok-value result err-value (err err-value)))
(define-private (transfer-from-tuple (token-trait <ft-trait>) (recipient { to: principal, amount: uint }))
  (ok (try! (contract-call? token-trait transfer-fixed (get amount recipient) tx-sender (get to recipient) none))))
(define-public (send-many (token-trait <ft-trait>) (recipients (list 200 { to: principal, amount: uint})))
  (fold check-err (map transfer-from-tuple 
		(list 
			token-trait	token-trait	token-trait	token-trait	token-trait	token-trait	token-trait	token-trait	token-trait	token-trait	token-trait	token-trait	token-trait	token-trait	token-trait	token-trait	token-trait	token-trait	token-trait	token-trait
			token-trait	token-trait	token-trait	token-trait	token-trait	token-trait	token-trait	token-trait	token-trait	token-trait	token-trait	token-trait	token-trait	token-trait	token-trait	token-trait	token-trait	token-trait	token-trait	token-trait
			token-trait	token-trait	token-trait	token-trait	token-trait	token-trait	token-trait	token-trait	token-trait	token-trait	token-trait	token-trait	token-trait	token-trait	token-trait	token-trait	token-trait	token-trait	token-trait	token-trait
			token-trait	token-trait	token-trait	token-trait	token-trait	token-trait	token-trait	token-trait	token-trait	token-trait	token-trait	token-trait	token-trait	token-trait	token-trait	token-trait	token-trait	token-trait	token-trait	token-trait
			token-trait	token-trait	token-trait	token-trait	token-trait	token-trait	token-trait	token-trait	token-trait	token-trait	token-trait	token-trait	token-trait	token-trait	token-trait	token-trait	token-trait	token-trait	token-trait	token-trait
			token-trait	token-trait	token-trait	token-trait	token-trait	token-trait	token-trait	token-trait	token-trait	token-trait	token-trait	token-trait	token-trait	token-trait	token-trait	token-trait	token-trait	token-trait	token-trait	token-trait
			token-trait	token-trait	token-trait	token-trait	token-trait	token-trait	token-trait	token-trait	token-trait	token-trait	token-trait	token-trait	token-trait	token-trait	token-trait	token-trait	token-trait	token-trait	token-trait	token-trait
			token-trait	token-trait	token-trait	token-trait	token-trait	token-trait	token-trait	token-trait	token-trait	token-trait	token-trait	token-trait	token-trait	token-trait	token-trait	token-trait	token-trait	token-trait	token-trait	token-trait
			token-trait	token-trait	token-trait	token-trait	token-trait	token-trait	token-trait	token-trait	token-trait	token-trait	token-trait	token-trait	token-trait	token-trait	token-trait	token-trait	token-trait	token-trait	token-trait	token-trait
			token-trait	token-trait	token-trait	token-trait	token-trait	token-trait	token-trait	token-trait	token-trait	token-trait	token-trait	token-trait	token-trait	token-trait	token-trait	token-trait	token-trait	token-trait	token-trait	token-trait		
		)
		recipients) (ok true)))
```
