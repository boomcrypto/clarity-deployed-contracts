---
title: "Trait mytoken"
draft: true
---
```

  (define-fungible-token mytoken)

  (define-public (mint (recipient principal) (amount uint))
    (begin
      (try! (ft-mint? mytoken amount recipient))
      (ok true)
    )
  )

  (define-public (transfer (amount uint) (recipient principal))
    (begin
      (try! (ft-transfer? mytoken amount tx-sender recipient))
      (ok true)
    )
  )
  
```
