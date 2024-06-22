---
title: "Trait xip006"
draft: true
---
```
(impl-trait .proposal-trait.proposal-trait)
(define-constant peg-in-address 0x0014630ca21dc8865bf5bfd1553b7d6eb9b719d4327f)
(define-constant ids (list u8 u10 u12 u14 u23 u30 u31 u37 u39 u38 u43 u48 u46 u55 u61 u66 u69 u76 u88 u87 u84 u92 u97))
(define-private (update-request (id uint))
	(let (
			(request (try! (contract-call? .btc-bridge-registry-v2-01 get-request-or-fail id)))
			(updated-request (merge request { fulfilled-by: peg-in-address })))
			(try! (contract-call? .btc-bridge-registry-v2-01 set-request id updated-request))
			(ok true)))
(define-private (check-err (result (response bool uint)) (prior (response bool uint)))
    (match prior ok-value result err-value (err err-value)))
(define-public (execute (sender principal))
	(begin		
		(try! (contract-call? .btc-bridge-registry-v2-01 approve-peg-in-address peg-in-address true))
		(fold check-err (map update-request ids) (ok true))))
```
