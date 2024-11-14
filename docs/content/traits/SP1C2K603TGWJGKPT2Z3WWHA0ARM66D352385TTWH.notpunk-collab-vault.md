---
title: "Trait notpunk-collab-vault"
draft: true
---
```
;;NOT Punk Collab Vault

(define-constant ERR-NOT-AUTHORIZED u404)
(define-constant ERR-INVALID-PERCENTAGE u405)
(define-data-var collab-address-1 principal 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH)
(define-data-var collab-address-2 principal 'SM776ZBWZXXJRH8GV0PPRMSM550D553B334A1VKN)
(define-data-var perc-address-1 uint u50)
(define-data-var perc-address-2 uint u50)
(define-data-var new-percentage-approval (tuple (perc-1 uint) (perc-2 uint) (caller principal)) {perc-1: u0, perc-2: u0, caller: tx-sender})

(define-read-only (get-balance) (stx-get-balance (as-contract tx-sender)))

(define-public (withdraw) 
    (let (
        (address-1 (var-get collab-address-1))
        (address-2 (var-get collab-address-2))
        (perc-1 (var-get perc-address-1))
        (perc-2 (var-get perc-address-2))
        (balance (get-balance))
        (amount-1 (/ (* balance (* perc-1 u100)) u10000))
        (amount-2 (/ (* balance (* perc-2 u100)) u10000))
        ) 
        (asserts! (or (is-eq tx-sender address-1) (is-eq tx-sender address-2)) (err ERR-NOT-AUTHORIZED))
        (try! (as-contract (stx-transfer? amount-1 (as-contract tx-sender) address-1)))
        (try! (as-contract (stx-transfer? amount-2 (as-contract tx-sender) address-2)))
        (ok true)))

(define-public (change-address-1 (new-address principal)) 
    (begin  
        (asserts! (is-eq tx-sender (var-get collab-address-1)) (err ERR-NOT-AUTHORIZED))
        (var-set new-percentage-approval {perc-1: u0, perc-2: u0, caller: tx-sender});;reset new percentage approvals
        (ok (var-set collab-address-1 new-address))))

(define-public (change-address-2 (new-address principal)) 
    (begin
        (asserts! (is-eq tx-sender (var-get collab-address-2)) (err ERR-NOT-AUTHORIZED))
        (var-set new-percentage-approval {perc-1: u0, perc-2: u0, caller: tx-sender});;reset new percentage approvals
        (ok (var-set collab-address-2 new-address))))

(define-public (change-percentages (new-perc-1 uint) (new-perc-2 uint)) 
    (begin 
        (asserts! (or (is-eq tx-sender (var-get collab-address-1)) (is-eq tx-sender (var-get collab-address-2))) (err ERR-NOT-AUTHORIZED))
        (asserts! (is-eq (+ new-perc-1 new-perc-2) u100) (err ERR-INVALID-PERCENTAGE))
        (if (and 
                (is-eq (get perc-1 (var-get new-percentage-approval)) new-perc-1) 
                (is-eq (get perc-2 (var-get new-percentage-approval)) new-perc-2)
                (not (is-eq (get caller (var-get new-percentage-approval)) tx-sender))
                )
            (begin 
                (var-set perc-address-1 new-perc-1)
                (var-set perc-address-2 new-perc-2)
                (ok true))
            (begin 
                (var-set new-percentage-approval {perc-1: new-perc-1, perc-2: new-perc-2, caller: tx-sender})
                (ok true)))))
```
