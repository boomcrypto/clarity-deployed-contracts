---
title: "Trait balancer-v0011"
draft: true
---
```
(define-public (balancer (dd uint) (mr uint) (ta uint))
    (begin
        (unwrap-panic (contract-call? 'SP39JCPYF3XTGS663GSY41G9VX04XRBM0KQ2ZZQ14.balancer-v93-8 balancer dd mr ta))
        (unwrap-panic (contract-call? 'SP39JCPYF3XTGS663GSY41G9VX04XRBM0KQ2ZZQ14.balancer-v17-1 balancer dd mr ta)) 
        (unwrap-panic (contract-call? 'SP39JCPYF3XTGS663GSY41G9VX04XRBM0KQ2ZZQ14.balancer-v11-4 balancer dd mr ta)) 
        (unwrap-panic (contract-call? 'SP39JCPYF3XTGS663GSY41G9VX04XRBM0KQ2ZZQ14.balancer-v19-9 balancer dd mr ta)) 
        (unwrap-panic (contract-call? 'SP39JCPYF3XTGS663GSY41G9VX04XRBM0KQ2ZZQ14.balancer-v35-5 balancer dd mr ta)) 
        (ok u11)
    )
)
```
