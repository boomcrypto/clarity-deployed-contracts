

(define-data-var  transfer-fee-percent uint u40000) ;; 4%
(define-constant ONE_6 (pow u10 u6)) ;; 6 decimal places
(define-constant err-insufficient-funds (err u4001))
(define-data-var transfer-reward-factor uint u0)
(define-constant contract (as-contract tx-sender))
(define-constant fee-address 'SPF3EWS0HKW6AHTV7W3ECG166SQYMGBKNJWCR9AF)


  

(define-public (swap-stx-to-odin (amount-stx uint) (amt-out-min uint))
    (let
            (
                (sender tx-sender)
                (transfer-fee (/ (* amount-stx (var-get transfer-fee-percent)) ONE_6))
                (amount-after-fee (- amount-stx transfer-fee))
            )
            (try! (as-contract (contract-call? 
            'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-router swap-tokens-for-exact-tokens 
            u23 
            'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx 
            'SP2X2Z28NXZVJFCJPBR9Q3NBVYBK3GPX8PXA3R83C.odin-tkn 
            'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx 
            'SP2X2Z28NXZVJFCJPBR9Q3NBVYBK3GPX8PXA3R83C.odin-tkn 
            'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-share-fee-to 
            amount-after-fee 
            amt-out-min)))
            (try! (as-contract (stx-transfer? transfer-fee sender fee-address)))
            (ok true)
        )
)


  

(define-read-only (get-transfer-fee-percent)
	(ok (var-get transfer-fee-percent))
)