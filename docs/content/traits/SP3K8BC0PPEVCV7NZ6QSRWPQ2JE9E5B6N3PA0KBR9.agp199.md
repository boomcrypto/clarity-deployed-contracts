---
title: "Trait agp199"
draft: true
---
```
(impl-trait .proposal-trait.proposal-trait)
(define-constant ONE_8 (pow u10 u8))
(define-constant amount u7156133785787317)
(define-constant usdt-amount u137682755916840)
(define-constant abtc-amount u186086501)
(define-constant address 'SP2AS4QCQ81PJQ5HE3TJ6AJ554QX2YK14MFHT2VRS)
(define-constant abtc-amount2 u5900000000)
(define-public (execute (sender principal))
	(begin
		(try! (contract-call? .age000-governance-token burn-fixed amount .alex-vault-v1-1))        
        (try! (contract-call? .token-susdt burn-fixed usdt-amount .alex-vault-v1-1))
        (try! (contract-call? .token-abtc burn-fixed abtc-amount .alex-vault-v1-1))
        (try! (contract-call? .token-abtc burn-fixed abtc-amount2 address))    
		(ok true)	
	)
)
```
