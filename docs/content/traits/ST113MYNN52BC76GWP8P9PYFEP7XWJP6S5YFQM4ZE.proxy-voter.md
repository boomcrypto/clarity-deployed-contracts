---
title: "Trait proxy-voter"
draft: true
---
```
;; proxy-voter for candidate 2

(define-public (vote-proxy)
  (ok (contract-call? 'ST113MYNN52BC76GWP8P9PYFEP7XWJP6S5YFQM4ZE.pay-to-vote vote-for-candidate2)))
```
