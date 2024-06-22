---
title: "Trait migrate-legacy-v2"
draft: true
---
```
(impl-trait .extension-trait.extension-trait)
(define-constant err-unauthorised (err u1000))
(define-constant err-already-requested (err u1001))
(define-constant err-unknown-sender (err u1002))
(define-constant err-cannot-delete (err u1003))
(define-data-var threshold uint u0)
(define-map request-map principal uint)
(define-read-only (is-dao-or-extension)
	(ok (asserts! (or (is-eq tx-sender .executor-dao) (contract-call? .executor-dao is-extension contract-caller)) err-unauthorised)))
(define-read-only (get-threshold)
    (var-get threshold))
(define-read-only (get-request-or-fail (sender principal))
    (ok (unwrap! (map-get? request-map sender) err-unknown-sender)))
(define-public (migrate)
    (let (
            (sender tx-sender)
            (bal (unwrap-panic (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.age000-governance-token get-balance-fixed sender))))
        (and (> bal u0) (as-contract (try! (contract-call? 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.age000-governance-token burn-fixed bal sender))))
        (if (>= bal (var-get threshold))
            (begin 
                (asserts! (map-insert request-map sender bal) err-already-requested)
                (print { action: "migrate", sender: sender, amount: bal, status: "requested" })
                (ok true))
            (begin
                (and (> bal u0) (as-contract (try! (contract-call? .token-alex mint-fixed bal sender))))
                (print { action: "migrate", sender: sender, amount: bal, status: "migrated" })
                (ok true)))))
(define-public (set-threshold (new-threshold uint))
    (begin 
        (try! (is-dao-or-extension))
        (ok (var-set threshold new-threshold))))
(define-public (finalise-migrate (sender principal))
    (let ( 
            (bal (try! (get-request-or-fail sender))))
        (try! (is-dao-or-extension))
        (and (> bal u0) (try! (contract-call? .token-alex mint-fixed bal sender)))
        (asserts! (map-delete request-map sender) err-cannot-delete)
        (print { action: "migrate", sender: sender, amount: bal, status: "migrated" })
        (ok true)))
        
(define-public (callback (sender principal) (payload (buff 2048)))
	(ok true))
```
