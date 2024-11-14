---
title: "Trait migration-aidrop"
draft: true
---
```
;; Error for the contract
(define-constant ERR-NOT-AUTH (err u200))
;; Define the const for authorized caller
(define-constant AIRDROP-PRINCIPAL tx-sender)

(define-public (mng-airdrop-name
    (name (buff 48))
    (namespace (buff 20))
    (imported-at (optional uint)) 
    (registered-at (optional uint)) 
    (renewal-height uint)
    (owner principal)
)
    (begin
        ;; We check for tx-sender which will deploy the contracts
        (asserts! (is-eq tx-sender AIRDROP-PRINCIPAL) ERR-NOT-AUTH)
        (contract-call? .BNS-V2 name-airdrop 
            name 
            namespace 
            imported-at 
            registered-at 
            renewal-height 
            owner
        )
    )
)

(define-public (mng-airdrop-namespace (namespace (buff 20)) (price-function {base: uint, buckets: (list 16 uint), coeff: uint, no-vowel-discount: uint, nonalpha-discount: uint}) (lifetime uint) (namespace-import principal) (manager-address (optional principal)) (can-update-price-function bool) (manager-transfers bool) (manager-frozen bool) (revealed-at uint) (launched-at uint))
    (begin 
        ;; We check for tx-sender which will deploy the contracts
        (asserts! (is-eq tx-sender AIRDROP-PRINCIPAL) ERR-NOT-AUTH)
        (ok 
            (contract-call? .BNS-V2 namespace-airdrop 
                namespace 
                price-function
                lifetime
                namespace-import
                ;; Manager address
                manager-address 
                can-update-price-function
                ;; Manager transfers
                manager-transfers
                ;; Manager frozen
                manager-frozen 
                revealed-at
                (some launched-at)
            )
        )
    )
)
```
