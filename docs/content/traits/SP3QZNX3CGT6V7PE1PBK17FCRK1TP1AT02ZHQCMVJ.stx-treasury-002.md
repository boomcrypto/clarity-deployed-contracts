---
title: "Trait stx-treasury-002"
draft: true
---
```
(define-constant ERR-PERMISSION-DENIED (err u3000))  
(define-constant ERR-PRECONDITION-FAILED (err u3001))  
(define-constant ERR-CONTRACT-NOT-FOUND (err u3002))  
(define-constant ERR-CONTRACT-LOCKED (err u3999))   
(define-data-var external-treasury uint u242858890000)
(define-read-only (get-external-treasury)
    (var-get external-treasury))
(define-read-only (get-total-treasury)
    (+ (as-contract (stx-get-balance tx-sender)) 
       (var-get external-treasury)))
(define-public (set-external-treasury (new-value uint))
    (begin
        (asserts! (as-contract (contract-call? .btf-protocol-cpc-001 is-contract-unlocked tx-sender)) ERR-CONTRACT-LOCKED)
        (asserts! (contract-call? .btf-protocol-cpc-001 has-permission contract-caller u10) ERR-PERMISSION-DENIED)
        (ok (var-set external-treasury new-value))))
(define-public (deposit-stx (amount uint))
    (begin 
        (asserts! (> amount u0) ERR-PRECONDITION-FAILED)  
        (stx-transfer? amount tx-sender (as-contract tx-sender))  
    ))
(define-public (withdraw-stx (amount uint) (recipient principal))
    (begin
        (asserts! (as-contract (contract-call? .btf-protocol-cpc-001 is-contract-unlocked tx-sender)) ERR-CONTRACT-LOCKED)
        (asserts! (contract-call? .btf-protocol-cpc-001 has-permission contract-caller u1) ERR-PERMISSION-DENIED)  
        (asserts! (> amount u0) ERR-PRECONDITION-FAILED)  
        (as-contract (stx-transfer? amount tx-sender recipient))  
    ))
(define-public (move-to-external-treasury (amount uint) (recipient principal))
    (begin
        (asserts! (as-contract (contract-call? .btf-protocol-cpc-001 is-contract-unlocked tx-sender)) ERR-CONTRACT-LOCKED)
        (asserts! (contract-call? .btf-protocol-cpc-001 has-permission contract-caller u1) ERR-PERMISSION-DENIED)
        (asserts! (> amount u0) ERR-PRECONDITION-FAILED)
        (try! (as-contract (stx-transfer? amount tx-sender recipient)))  
        (var-set external-treasury (+ (var-get external-treasury) amount))  
        (ok true)
    ))
(define-public (move-from-external-treasury (amount uint))
    (begin
        (asserts! (as-contract (contract-call? .btf-protocol-cpc-001 is-contract-unlocked tx-sender)) ERR-CONTRACT-LOCKED)
        (asserts! (contract-call? .btf-protocol-cpc-001 has-permission contract-caller u1) ERR-PERMISSION-DENIED)
        (asserts! (> amount u0) ERR-PRECONDITION-FAILED)
        (asserts! (>= (var-get external-treasury) amount) ERR-PRECONDITION-FAILED)
        (var-set external-treasury (- (var-get external-treasury) amount))
        (stx-transfer? amount tx-sender (as-contract tx-sender))  
    ))

```
