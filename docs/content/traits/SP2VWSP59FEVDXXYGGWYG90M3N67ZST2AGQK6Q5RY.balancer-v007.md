---
title: "Trait balancer-v007"
draft: true
---
```
(define-public (balancer (dd uint) (mr uint) (ta uint))
    (begin
        (unwrap-panic (contract-call? 'SP2VWSP59FEVDXXYGGWYG90M3N67ZST2AGQK6Q5RY.balancer-v3-6 balancer dd mr ta))
        (unwrap-panic (contract-call? 'SP2VWSP59FEVDXXYGGWYG90M3N67ZST2AGQK6Q5RY.balancer-v4-11 balancer dd mr ta)) 
        (unwrap-panic (contract-call? 'SP2VWSP59FEVDXXYGGWYG90M3N67ZST2AGQK6Q5RY.balancer-v29-3 balancer dd mr ta)) 
        (unwrap-panic (contract-call? 'SP2VWSP59FEVDXXYGGWYG90M3N67ZST2AGQK6Q5RY.balancer-v2-4 balancer dd mr ta)) 
        (unwrap-panic (contract-call? 'SP2VWSP59FEVDXXYGGWYG90M3N67ZST2AGQK6Q5RY.balancer-v7-1 balancer dd mr ta)) 
        (unwrap-panic (contract-call? 'SP2VWSP59FEVDXXYGGWYG90M3N67ZST2AGQK6Q5RY.balancer-v41-1 balancer dd mr ta)) 
        (unwrap-panic (contract-call? 'SP2VWSP59FEVDXXYGGWYG90M3N67ZST2AGQK6Q5RY.balancer-v23-6 balancer dd mr ta)) 
        (ok u11)
    )
)
```
