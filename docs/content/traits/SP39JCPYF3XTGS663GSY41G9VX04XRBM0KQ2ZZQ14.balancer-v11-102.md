---
title: "Trait balancer-v11-102"
draft: true
---
```
(define-constant ONE_6 u1000000)
(define-constant ONE_8 u100000000)
(define-constant ERR-NO-PR (err u400))

(define-read-only (six-to-eight (n uint))
    (/ (* n ONE_8) ONE_6)
)

(define-public (balancer1_i (in uint) (mrc uint))
    (begin 
        (try! (contract-call? 
            'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-helper 
            'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2 
            'SP1E0XBN9T4B10E9QMR7XMFJPMA19D77WY3KP2QKC.token-wwennaka  
            u100000000 (six-to-eight in) none))
        (let 
            (
                (bb (stx-get-balance tx-sender))
            )            
            (try! (contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.path-apply_v1_2_0 apply  
                (list {a: "v", b: 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-pool-v1_0_0-0009, c: u21000009, d: 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx, e: 'SP25K3XPVBNWXPMYDXBPSZHGC8APW0Z21CWJ3Y3B1.wen-nakamoto-stxcity, f: false}) 
                (unwrap-panic (contract-call? 'SP25K3XPVBNWXPMYDXBPSZHGC8APW0Z21CWJ3Y3B1.wen-nakamoto-stxcity get-balance tx-sender))
                (some 'SP25K3XPVBNWXPMYDXBPSZHGC8APW0Z21CWJ3Y3B1.wen-nakamoto-stxcity) 
                (some 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx )
                none
                none
                none
                (some 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-share-fee-to) 
                (some 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-pool-v1_0_0-0009) 
                none
                none
                none 
                (some 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-fees-v1_0_0-0009) 
                none
                none
                none
                none
                none
                none
                none
                none
                none
                none
                none
            ))
            (let 
                (
                    (ba (stx-get-balance tx-sender))
                    (rc (- ba bb))
                )
                (asserts! (>= rc mrc) ERR-NO-PR)
                (ok (list bb ba))
            ) 
        )
    )
)

(define-public (balancer1 (dd uint) (mr uint) (ta uint))
    (let (
            (r (list 
                (balancer1_i dd mr)
            ))
        )
        (and (> (stx-get-balance tx-sender) ta) (try! (stx-transfer? (- (stx-get-balance tx-sender) ta) tx-sender 'SP39JCPYF3XTGS663GSY41G9VX04XRBM0KQ2ZZQ14)))
        (ok r)
    )
)

(define-public (balancer2_i (in uint) (mout uint))
    (begin
        (try! (contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.path-apply_v1_2_0 apply  
                (list {a: "v", b: 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-pool-v1_0_0-0009, c: u21000009, d: 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx, e: 'SP25K3XPVBNWXPMYDXBPSZHGC8APW0Z21CWJ3Y3B1.wen-nakamoto-stxcity, f: true}) 
                in
                (some 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx )
                (some 'SP25K3XPVBNWXPMYDXBPSZHGC8APW0Z21CWJ3Y3B1.wen-nakamoto-stxcity) 
                none
                none
                none
                (some 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-share-fee-to) 
                (some 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-pool-v1_0_0-0009) 
                none
                none
                none 
                (some 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-fees-v1_0_0-0009) 
                none
                none
                none
                none
                none
                none
                none
                none
                none
                none
                none
            ))
        (let
            (
                (bb (stx-get-balance tx-sender))
            )
            (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-helper 
                'SP1E0XBN9T4B10E9QMR7XMFJPMA19D77WY3KP2QKC.token-wwennaka 
                'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2   
                u100000000 
                (six-to-eight (unwrap-panic (contract-call? 'SP25K3XPVBNWXPMYDXBPSZHGC8APW0Z21CWJ3Y3B1.wen-nakamoto-stxcity get-balance tx-sender)))
                none
            ))
            (let 
                (
                    (ba (stx-get-balance tx-sender))
                    (rc (- ba bb))
                )
                (asserts! (>= rc mout) (err u400))
                (ok (list bb ba))
            ) 
        )
    )
)

(define-public (balancer2 (dd uint) (mr uint) (ta uint))
    (let (
            (r (list 
                (balancer2_i dd mr)
            ))
        )
        (and (> (stx-get-balance tx-sender) ta) (try! (stx-transfer? (- (stx-get-balance tx-sender) ta) tx-sender 'SP39JCPYF3XTGS663GSY41G9VX04XRBM0KQ2ZZQ14)))
        (ok r)
    )
)

(define-public (balancer (dd uint) (mr uint) (ta uint))
    (let (
            (r (list 
                (balancer1_i dd mr)
                (balancer2_i dd mr)
            ))
        )
        (and (> (stx-get-balance tx-sender) ta) (try! (stx-transfer? (- (stx-get-balance tx-sender) ta) tx-sender 'SP39JCPYF3XTGS663GSY41G9VX04XRBM0KQ2ZZQ14)))
        (ok r)
    )
)
```
