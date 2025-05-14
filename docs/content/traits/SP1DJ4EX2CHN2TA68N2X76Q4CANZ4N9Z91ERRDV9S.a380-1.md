---
title: "Trait a380-1"
draft: true
---
```


(define-read-only (velar-get-pools-5)
    (let (
        (usdh-aeusdc (contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.curve-pool-v1_1_0-0001 do-get-pool))
        (stx-ststx (contract-call? 'SP20X3DC5R091J8B6YPQT638J8NR1W83KN6TN5BJY.curve-pool-v1_0_0_ststx-0001 do-get-pool))
        (stx-sbtc (contract-call? 'SP20X3DC5R091J8B6YPQT638J8NR1W83KN6TN5BJY.univ2-pool-v1_0_0-0070 do-get-pool))
        (stx-diko (contract-call? 'SP20X3DC5R091J8B6YPQT638J8NR1W83KN6TN5BJY.univ2-pool-v1_0_0-0056 do-get-pool))
       
    )
    {   
        usdh-aeusdc: (ok usdh-aeusdc),
        stx-ststx: (ok stx-ststx),
        stx-sbtc: (ok stx-sbtc),
        stx-diko: (ok stx-diko)
    })
)
```
