---
title: "Trait amm-reserve-v0"
draft: true
---
```
;; Contract: SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01

;; One pool
(define-read-only (get-y-given-x-for-one-pool
    (pool1-token-x principal) 
    (pool1-token-y principal)
    (pool1-factor uint)
    (dx1 uint))
    
    (let (
        (dy1 (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 get-y-given-x pool1-token-x pool1-token-y pool1-factor dx1)))
    )
    (ok {
        pool1: {
            input: dx1,
            output: dy1
        }
    })))

;; Two pools
(define-read-only (get-y-given-x-for-two-pools
    (pool1-token-x principal) 
    (pool1-token-y principal)
    (pool1-factor uint)
    (dx1 uint)
    
    (pool2-token-x principal) 
    (pool2-token-y principal)
    (pool2-factor uint)
    (dx2 uint))
    
    (let (
        (dy1 (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 get-y-given-x pool1-token-x pool1-token-y pool1-factor dx1)))
        (dy2 (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 get-y-given-x pool2-token-x pool2-token-y pool2-factor dx2)))
    )
    (ok {
        pool1: {
            input: dx1,
            output: dy1
        },
        pool2: {
            input: dx2,
            output: dy2
        }
    })))

;; Three pools
(define-read-only (get-y-given-x-for-three-pools
    (pool1-token-x principal) 
    (pool1-token-y principal)
    (pool1-factor uint)
    (dx1 uint)
    
    (pool2-token-x principal) 
    (pool2-token-y principal)
    (pool2-factor uint)
    (dx2 uint)
    
    (pool3-token-x principal) 
    (pool3-token-y principal)
    (pool3-factor uint)
    (dx3 uint))
    
    (let (
        (dy1 (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 get-y-given-x pool1-token-x pool1-token-y pool1-factor dx1)))
        (dy2 (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 get-y-given-x pool2-token-x pool2-token-y pool2-factor dx2)))
        (dy3 (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 get-y-given-x pool3-token-x pool3-token-y pool3-factor dx3)))
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
        }
    })))

;; Four pools
(define-read-only (get-y-given-x-for-four-pools
    (pool1-token-x principal) 
    (pool1-token-y principal)
    (pool1-factor uint)
    (dx1 uint)
    
    (pool2-token-x principal) 
    (pool2-token-y principal)
    (pool2-factor uint)
    (dx2 uint)
    
    (pool3-token-x principal) 
    (pool3-token-y principal)
    (pool3-factor uint)
    (dx3 uint)
    
    (pool4-token-x principal) 
    (pool4-token-y principal)
    (pool4-factor uint)
    (dx4 uint))
    
    (let (
        (dy1 (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 get-y-given-x pool1-token-x pool1-token-y pool1-factor dx1)))
        (dy2 (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 get-y-given-x pool2-token-x pool2-token-y pool2-factor dx2)))
        (dy3 (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 get-y-given-x pool3-token-x pool3-token-y pool3-factor dx3)))
        (dy4 (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 get-y-given-x pool4-token-x pool4-token-y pool4-factor dx4)))
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
        }
    })))

;; Five pools (existing function)
(define-public (get-y-given-x-for-five-pools
    (pool1-token-x principal) 
    (pool1-token-y principal)
    (pool1-factor uint)
    (dx1 uint)
    
    (pool2-token-x principal) 
    (pool2-token-y principal)
    (pool2-factor uint)
    (dx2 uint)
    
    (pool3-token-x principal) 
    (pool3-token-y principal)
    (pool3-factor uint)
    (dx3 uint)
    
    (pool4-token-x principal) 
    (pool4-token-y principal)
    (pool4-factor uint)
    (dx4 uint)
    
    (pool5-token-x principal) 
    (pool5-token-y principal)
    (pool5-factor uint)
    (dx5 uint))
    
    (let (
        (dy1 (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 get-y-given-x pool1-token-x pool1-token-y pool1-factor dx1)))
        (dy2 (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 get-y-given-x pool2-token-x pool2-token-y pool2-factor dx2)))
        (dy3 (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 get-y-given-x pool3-token-x pool3-token-y pool3-factor dx3)))
        (dy4 (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 get-y-given-x pool4-token-x pool4-token-y pool4-factor dx4)))
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
