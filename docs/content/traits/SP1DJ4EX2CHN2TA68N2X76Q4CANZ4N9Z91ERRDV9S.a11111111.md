---
title: "Trait a11111111"
draft: true
---
```
(define-read-only (get-pools)
    (let (
        (stx-leo (contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-core do-get-pool u28))
        (leo-aeusdc (contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-core do-get-pool u9))
        (stx-aeusdc (contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-core do-get-pool u6))
        (stx-abtc (contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-core do-get-pool u3))
        (stx-welsh (contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-core do-get-pool u27))
)
    {
        stx-leo: (ok stx-leo),
        leo-aeusdc: (ok leo-aeusdc),
        stx-aeusdc: (ok stx-aeusdc),
        stx-abtc: (ok stx-abtc),
        stx-welsh: (ok stx-welsh)
    })
)
```
