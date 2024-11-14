---
title: "Trait migration-airdrop-atb"
draft: true
---
```
;; Error for the contract
(define-constant ERR-NOT-AUTH (err u200))
;; Error to match format of .bns
(define-constant ERR-NOT-AUTHORIZED (err 200))
;; Define the const for authorized caller
(define-constant AIRDROP-PRINCIPAL tx-sender)

(define-public (mng-airdrop-atb
    (atb (buff 48))
    (atbspace (buff 20))
    (imported-at (optional uint)) 
    (registered-at (optional uint)) 
    (revoked-at bool) 
    (zonefile-hash (optional (buff 20)))
    (renewal-height uint)
    (owner principal)
)
    (begin
        ;; We check for tx-sender which will deploy the contracts
        (asserts! (is-eq tx-sender AIRDROP-PRINCIPAL) ERR-NOT-AUTH)
        (contract-call? .atb atb-airdrop 
            atb 
            atbspace 
            imported-at 
            registered-at 
            revoked-at 
            zonefile-hash 
            renewal-height 
            owner
        )
    )
)

(define-public (mng-airdrop-atbspace (atbspace (buff 20)) (manager-address (optional principal)) (manager-transfers bool) (manager-frozen bool))
    (let 
        (
            (atbspace-props-call (try! (contract-call? 'SP000000000000000000002Q6VF78.bns get-namespace-properties atbspace)))
            (atbspace-props-v1 (get properties atbspace-props-call))
        )
        ;; We check for tx-sender which will deploy the contracts
        (asserts! (is-eq tx-sender AIRDROP-PRINCIPAL) ERR-NOT-AUTHORIZED)
        (ok 
            (contract-call? .atb atbspace-airdrop 
                atbspace 
                (get price-function atbspace-props-v1) 
                (get lifetime atbspace-props-v1) 
                (get namespace-import atbspace-props-v1) 
                ;; Manager address
                manager-address 
                (get can-update-price-function atbspace-props-v1) 
                ;; Manager transfers
                manager-transfers
                ;; Manager frozen
                manager-frozen 
                (get revealed-at atbspace-props-v1)
                (get launched-at atbspace-props-v1)
            )
        )
    )
)
```
