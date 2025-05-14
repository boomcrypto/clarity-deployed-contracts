---
title: "Trait g-multi"
draft: true
---
```

(define-read-only (get-user-position-inner (user principal))
  (contract-call? 'SP35E2BBMDT2Y1HB0NTK139YBGYV3PAPK3WA8BRNA.state-v1 get-user-position user)
)

(define-read-only (get-user-position (users (list 100 principal))) 
    (map get-user-position-inner users)
)

(define-read-only (get-user-collateral-inner (arg {user: principal, collateral: principal}))
  (contract-call? 'SP35E2BBMDT2Y1HB0NTK139YBGYV3PAPK3WA8BRNA.state-v1 get-user-collateral (get user arg) (get collateral arg))
)

(define-read-only (get-user-collateral (args (list 100 {user: principal, collateral: principal})))
    (map get-user-collateral-inner args)
)

```
