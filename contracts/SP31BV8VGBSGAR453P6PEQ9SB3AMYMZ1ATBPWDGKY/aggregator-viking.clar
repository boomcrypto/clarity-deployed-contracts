(use-trait ft-trait 'SP2AKWJYC7BNY18W1XXKPGP0YVEK63QJG4793Z2D4.sip-010-trait-ft-standard.sip-010-trait)
(use-trait share-fee-to-trait 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-share-fee-to-trait.share-fee-to-trait)

(define-data-var  transfer-fee-percent uint u10000) ;; 1%
(define-constant ONE_6 (pow u10 u6)) ;; 6 decimal places
(define-constant err-insufficient-funds (err u4001))
(define-constant contract (as-contract tx-sender))
(define-constant err-check-owner (err u101))




(define-public (swap-stx-to-token (id uint) (token0 <ft-trait>) (token1 <ft-trait>) (token-in <ft-trait>) (token-out <ft-trait>) (share-fee-to <share-fee-to-trait>) (amt-in uint) (amt-out-min uint))
    (let
            (
                (sender tx-sender)
                (transfer-fee (/ (* amt-in (var-get transfer-fee-percent)) ONE_6))
                (amount-after-fee (- amt-in transfer-fee))

            )  
            (try! (contract-call? 
            'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-router swap-exact-tokens-for-tokens 
            id
            token0 token1
            token-in token-out
            share-fee-to
            amount-after-fee 
            amt-out-min))
            (try! (contract-call? 
            'SP31BV8VGBSGAR453P6PEQ9SB3AMYMZ1ATBPWDGKY.fee-share fee-for-stx-to-token 
            amt-in
            ))
            (ok true)
            
        )
)

(define-public (swap-token-to-stx (id uint) (token0 <ft-trait>) (token1 <ft-trait>) (token-in <ft-trait>) (token-out <ft-trait>) (share-fee-to <share-fee-to-trait>) (amt-in uint) (amt-out-min uint))
 (let
            (
                (sender tx-sender)
                (transfer-fee (/ (* amt-in (var-get transfer-fee-percent)) ONE_6))
                (amount-after-fee (- amt-in transfer-fee))

            )  
            (try! (contract-call? 
            'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-router swap-exact-tokens-for-tokens 
            id
            token0 token1
            token-in token-out
            share-fee-to
            amount-after-fee 
            amt-out-min))
            (try! (contract-call? 
            'SP31BV8VGBSGAR453P6PEQ9SB3AMYMZ1ATBPWDGKY.fee-share fee-for-token-to-stx 
            amt-in
            token-in
            ))
            (ok true)  
        )
)




(define-read-only (get-transfer-fee-percent)
	(ok (var-get transfer-fee-percent))
)