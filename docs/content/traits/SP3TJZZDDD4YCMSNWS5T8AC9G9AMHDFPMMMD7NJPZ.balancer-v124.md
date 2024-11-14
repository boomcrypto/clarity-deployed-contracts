---
title: "Trait balancer-v124"
draft: true
---
```
(define-public (balancer (dd uint) (mr uint) (ta uint))
    (begin
        (unwrap-panic (contract-call? 'SP3TJZZDDD4YCMSNWS5T8AC9G9AMHDFPMMMD7NJPZ.balancer-v3-6 balancer dd mr ta))
        (unwrap-panic (contract-call? 'SP3TJZZDDD4YCMSNWS5T8AC9G9AMHDFPMMMD7NJPZ.balancer-v4-11 balancer dd mr ta)) 
        (unwrap-panic (contract-call? 'SP3TJZZDDD4YCMSNWS5T8AC9G9AMHDFPMMMD7NJPZ.balancer-v29-3 balancer dd mr ta)) 
        (unwrap-panic (contract-call? 'SP3TJZZDDD4YCMSNWS5T8AC9G9AMHDFPMMMD7NJPZ.balancer-v2-4 balancer dd mr ta)) 
        (unwrap-panic (contract-call? 'SP3TJZZDDD4YCMSNWS5T8AC9G9AMHDFPMMMD7NJPZ.balancer-v7-1 balancer dd mr ta)) 
        (unwrap-panic (contract-call? 'SP3TJZZDDD4YCMSNWS5T8AC9G9AMHDFPMMMD7NJPZ.balancer-v41-1 balancer dd mr ta)) 
        (ok u11)
    )
)
```
