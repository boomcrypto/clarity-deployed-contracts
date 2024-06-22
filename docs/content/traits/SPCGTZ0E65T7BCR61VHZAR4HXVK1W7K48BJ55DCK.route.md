---
title: "Trait route"
draft: true
---
```

(define-data-var  transfer-fee-percent uint u10000) ;; 1%
(define-constant ONE_6 (pow u10 u6)) ;; 6 decimal places
(define-constant err-insufficient-funds (err u4001))
(define-data-var transfer-reward-factor uint u0)
(define-constant fee-address 'SPF3EWS0HKW6AHTV7W3ECG166SQYMGBKNJWCR9AF)


(define-private (cal-fee (amount-stx uint))
 (/ (* amount-stx (var-get transfer-fee-percent)) ONE_6)
)




(define-public (swap-stx-to-odin (amount-stx uint) (amt-out-min uint))
	(let
        (
        (sender tx-sender)
        (transfer-fee (cal-fee amount-stx))
        (amount-after-fee (- amount-stx transfer-fee))
        (try! (swap-stx-to-swelsh amount-after-fee amt-out-min))
        )
        (asserts! (>= (stx-get-balance sender) amount-stx) err-insufficient-funds)
        (as-contract (stx-transfer? transfer-fee sender fee-address))
        
	)
)




(define-private (swap-stx-to-swelsh (amount-stx uint) (amt-out-min uint))
    
    (as-contract (contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-router swap-tokens-for-exact-tokens u23 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx 'SP2X2Z28NXZVJFCJPBR9Q3NBVYBK3GPX8PXA3R83C.odin-tkn 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx 'SP2X2Z28NXZVJFCJPBR9Q3NBVYBK3GPX8PXA3R83C.odin-tkn 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-share-fee-to amount-stx amt-out-min))
)
  


(define-read-only (get-transfer-fee-percent)
	(ok (var-get transfer-fee-percent))
)
```
