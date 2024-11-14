---
title: "Trait treasury-grant-v3-claim-helper"
draft: true
---
```
(define-public (claim (token-id uint))
	(begin 
		(try! (contract-call? 'SP1E0XBN9T4B10E9QMR7XMFJPMA19D77WY3KP2QKC.treasury-grant-v3 claim-alex token-id))
		(contract-call? 'SP1E0XBN9T4B10E9QMR7XMFJPMA19D77WY3KP2QKC.treasury-grant-v3 claim-stx token-id)))

```
