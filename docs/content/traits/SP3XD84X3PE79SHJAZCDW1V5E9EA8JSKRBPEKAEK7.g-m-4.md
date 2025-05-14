---
title: "Trait g-m-4"
draft: true
---
```
(define-read-only (get-market-state) 
    {
      lp-params: (contract-call? 'SP35E2BBMDT2Y1HB0NTK139YBGYV3PAPK3WA8BRNA.state-v1 get-lp-params),
      debt-params: (contract-call? 'SP35E2BBMDT2Y1HB0NTK139YBGYV3PAPK3WA8BRNA.state-v1 get-debt-params),
      accrue-interest-params: (contract-call? 'SP35E2BBMDT2Y1HB0NTK139YBGYV3PAPK3WA8BRNA.state-v1 get-accrue-interest-params)
    }
)
 
```
