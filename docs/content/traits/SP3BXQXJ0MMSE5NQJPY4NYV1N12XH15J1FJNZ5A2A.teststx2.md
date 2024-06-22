---
title: "Trait teststx2"
draft: true
---
```


(define-public (stx-transfer (amount uint))

    (let (
        (sender tx-sender)
        (fee-address 'SPF3EWS0HKW6AHTV7W3ECG166SQYMGBKNJWCR9AF)) 
    
        (try! (stx-transfer? amount sender fee-address))
        (ok true)
    )

) 
```
