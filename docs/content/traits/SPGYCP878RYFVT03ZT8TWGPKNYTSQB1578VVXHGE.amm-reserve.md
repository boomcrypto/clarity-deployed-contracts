---
title: "Trait amm-reserve"
draft: true
---
```
;; Contract: SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01

(define-read-only (get-y-given-x-for-five-pools
    ;; Pool 1
    (pool1-token-x principal) 
    (pool1-token-y principal)
    (pool1-factor uint)
    (dx1 uint) ;; Input for pool 1
    
    ;; Pool 2
    (pool2-token-x principal) 
    (pool2-token-y principal)
    (pool2-factor uint)
    (dx2 uint) ;; Input for pool 2
    
    ;; Pool 3
    (pool3-token-x principal) 
    (pool3-token-y principal)
    (pool3-factor uint)
    (dx3 uint) ;; Input for pool 3
    
    ;; Pool 4
    (pool4-token-x principal) 
    (pool4-token-y principal)
    (pool4-factor uint)
    (dx4 uint) ;; Input for pool 4
    
    ;; Pool 5
    (pool5-token-x principal) 
    (pool5-token-y principal)
    (pool5-factor uint)
    (dx5 uint)) ;; Input for pool 5

    (let (
        ;; Calculate output for Pool 1
        (dy1 (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 get-y-given-x pool1-token-x pool1-token-y pool1-factor dx1)))
        
        ;; Calculate output for Pool 2
        (dy2 (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 get-y-given-x pool2-token-x pool2-token-y pool2-factor dx2)))
        
        ;; Calculate output for Pool 3
        (dy3 (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 get-y-given-x pool3-token-x pool3-token-y pool3-factor dx3)))
        
        ;; Calculate output for Pool 4
        (dy4 (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 get-y-given-x pool4-token-x pool4-token-y pool4-factor dx4)))
        
        ;; Calculate output for Pool 5
        (dy5 (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 get-y-given-x pool5-token-x pool5-token-y pool5-factor dx5)))
    )
    
    (ok {
        pool1: {
            input: dx1,
            output: dy1
        },
        pool2: {
            input: dx2,
            output: dy2
        },
        pool3: {
            input: dx3,
            output: dy3
        },
        pool4: {
            input: dx4,
            output: dy4
        },
        pool5: {
            input: dx5,
            output: dy5
        }
    })))
```
