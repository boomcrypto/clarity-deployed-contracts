---
title: "Trait test_airdrop_nikoten1"
draft: true
---
```
(define-private (trans (address principal) (amount uint))
    (contract-call? 'SP3QJ0MM9G8M3DSF5NEX7CEJ99NFDQ81WG17T7RMC.nikoten-stxcity transfer amount tx-sender address none)
)

(trans 'SPR2C6KFGBXKER3AZXN9ZJV0HHQ7ADSBJ4S21DSF u12000000)
(trans 'SP26TF53HVACKGDRK8X1VVQEC61WJEBYB7DMKNY3A u19000000)
(trans 'SPPP6E721JK7ETZQQ2911JQ8E729H1T467M34CNW u13000000)
(trans 'SP11JW6P0HV7FQ9YMVDSB6NYK9E4YJ6P7HG9D9TX u24000000)
```
