---
title: "Trait rose-0524-0630"
draft: true
---
```
;; test www
(use-trait sip-trait .sip-010-trait-ft-standard.sip-010-trait)
(define-constant sender 'SP3RQY2KAMTAAZWMAVEMFKC9QBX0MH91010MNBZ9E)






;; Arkadiko
(define-public (swap-wstx-usda-arkadiko (dx uint))
  (let ((r (try! 
          (contract-call? 
          'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-x-for-y 
          'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token 
          'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token 
          dx 
          u0))))
  (ok (unwrap-panic (element-at r u1))))
)

(define-read-only (test-dogetpool-6)
  (let
    (          
      (a1 (contract-call? 
            'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-core do-get-pool
            u6
          )
      )
    )
    (ok a1)
  )
)
```
