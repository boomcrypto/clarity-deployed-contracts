---
title: "Trait migrate-legacy"
draft: true
---
```
(impl-trait .extension-trait.extension-trait)
(define-constant err-unauthorised (err u1000))
(define-public (migrate)
    (let (
            (sender tx-sender)
            (bal (unwrap-panic (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.age000-governance-token get-balance-fixed sender))))
        (and (> bal u0)
            (begin
                (as-contract (try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.age000-governance-token burn-fixed bal sender)))
                (as-contract (try! (contract-call? .token-alex mint-fixed bal sender)))))         
        (ok true)))
        
(define-public (callback (sender principal) (payload (buff 2048)))
	(ok true))
```
