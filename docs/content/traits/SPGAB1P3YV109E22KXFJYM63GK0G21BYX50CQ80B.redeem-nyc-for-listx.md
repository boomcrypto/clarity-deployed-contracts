---
title: "Trait redeem-nyc-for-listx"
draft: true
---
```
;; redeem-nyc-for-listx
;; Redeem NYC tokens and convert received STX in to liquid stx with Lisa (liSTX).
(define-constant err-redeem-failed (err u9999))

(define-public (redeem-nyc-and-stack-with-lisa)
    (let ((amount 
            ;; redeem NYC tokens 
            (unwrap!
                (try! (contract-call? 'SP8A9HZ3PKST0S42VM9523Z9NV42SZ026V4K39WH.ccd012-redemption-nyc 
                        redeem-nyc)) 
                err-redeem-failed))
        (lisa-id 
            ;; request liSTX for the received STX
            (try! (contract-call? 'SM3KNVZS30WM7F89SXKVVFY4SN9RMPZZ9FX929N0V.lqstx-mint-endpoint-v2-01 
                    request-mint amount))))
    ;; report results
    (ok {amount-stx: amount, lisa-id: lisa-id, amount-listx-when-finalizing-lisa-id: amount})))
```
