---
title: "Trait viki-aggregator"
draft: true
---
```

(use-trait ft-trait 'SP2AKWJYC7BNY18W1XXKPGP0YVEK63QJG4793Z2D4.sip-010-trait-ft-standard.sip-010-trait)
(use-trait share-fee-to-trait 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-share-fee-to-trait.share-fee-to-trait)

(define-data-var  transfer-fee-percent uint u10000) ;; 1%
(define-data-var  transfer-fee-percent_35 uint u350000) 
(define-data-var  transfer-fee-percent_35_2 uint u350000) 
(define-data-var  transfer-fee-percent_10 uint u100000) 
(define-data-var  transfer-fee-percent_20 uint u200000) 
(define-constant ONE_6 (pow u10 u6)) ;; 6 decimal places
(define-constant err-insufficient-funds (err u4001))
(define-data-var transfer-reward-factor uint u0)
(define-constant contract (as-contract tx-sender))

(define-constant err-check-owner (err u101))

(define-data-var owner principal tx-sender)
(define-read-only (get-owner) (var-get owner))

(define-private (check-owner)
  (ok (asserts! (is-eq contract-caller (get-owner)) err-check-owner)))

(define-public (set-owner (new-owner principal))
  (begin
   (try! (check-owner))
   (ok (var-set owner new-owner)) ))

(define-data-var share-fee-to_35 principal tx-sender )
(define-data-var share-fee-to_35_2 principal tx-sender)
(define-data-var share-fee-to_10 principal tx-sender )
(define-data-var share-fee-to_20 principal tx-sender )


(define-public (set-share-fee-to_35 (new_share-fee-to_35 principal))
  (begin
   (try! (check-owner))
   (ok (var-set share-fee-to_35 new_share-fee-to_35))))

(define-public (set-share-fee-to_35_2 (new_share-fee-to_35_2 principal))
  (begin
   (try! (check-owner))
   (ok (var-set share-fee-to_35_2 new_share-fee-to_35_2))))

(define-public (set-share-fee-to_10 (new_share-fee-to_10 principal))
  (begin
   (try! (check-owner))
   (ok (var-set share-fee-to_10 new_share-fee-to_10))))

(define-public (set-share-fee-to_20 (new_share-fee-to_20 principal))
  (begin
   (try! (check-owner))
   (ok (var-set share-fee-to_20 new_share-fee-to_20))))


(define-public (swap-stx-to-token (id uint) (token0 <ft-trait>) (token1 <ft-trait>) (token-in <ft-trait>) (token-out <ft-trait>) (share-fee-to <share-fee-to-trait>) (amt-in uint) (amt-out-min uint) (reward-token <ft-trait>))
    (let
            (
                (sender tx-sender)
                (transfer-fee (/ (* amt-in (var-get transfer-fee-percent)) ONE_6))
                (transfer-fee_35 (/ (* transfer-fee (var-get transfer-fee-percent_35)) ONE_6))
                (transfer-fee_35_2 (/ (* transfer-fee (var-get transfer-fee-percent_35_2)) ONE_6))
                (transfer-fee_10 (/ (* transfer-fee (var-get transfer-fee-percent_10)) ONE_6))
                (transfer-fee_20 (/ (* transfer-fee (var-get transfer-fee-percent_20)) ONE_6))
                (amount-after-fee (- amt-in transfer-fee))
                (scope_fee_35 (var-get share-fee-to_35))
                (scope_fee_35_2 (var-get share-fee-to_35_2))
                (scope_fee_10 (var-get share-fee-to_10))
                (scope_fee_20 (var-get share-fee-to_20))
            )  
            (try! (contract-call? 
            'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-router swap-exact-tokens-for-tokens 
            id
            token0 token1
            token-in token-out
            share-fee-to
            amount-after-fee 
            amt-out-min))
            (try! (stx-transfer? transfer-fee_35 sender scope_fee_35))
            (try! (stx-transfer? transfer-fee_35_2 sender scope_fee_35_2))
            (try! (stx-transfer? transfer-fee_10 sender scope_fee_10))
            (try! (stx-transfer? transfer-fee_20 sender scope_fee_20))
            (try! (contract-call? 
            'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-router swap-exact-tokens-for-tokens 
            id
            token0 token1
            token-in token-out
            share-fee-to
            amount-after-fee 
            amt-out-min))
            (try! (stx-transfer? transfer-fee_35 sender scope_fee_35))
            (try! (stx-transfer? transfer-fee_35_2 sender scope_fee_35_2))
            (try! (stx-transfer? transfer-fee_10 sender scope_fee_10))
            (try! (stx-transfer? transfer-fee_20 sender scope_fee_20))
            (try! (as-contract (contract-call? reward-token transfer
            amt-in
            contract
            sender
            none)))
            (ok true)
            
        )
)

(define-public (swap-token-to-stx (id uint) (token0 <ft-trait>) (token1 <ft-trait>) (token-in <ft-trait>) (token-out <ft-trait>) (share-fee-to <share-fee-to-trait>) (amt-in uint) (amt-out-min uint) (amt-estimated uint) (reward-token <ft-trait>))
    (let
            (
                (sender tx-sender)
                (transfer-fee (/ (* amt-estimated (var-get transfer-fee-percent)) ONE_6))
                (transfer-fee_35 (/ (* transfer-fee (var-get transfer-fee-percent_35)) ONE_6))
                (transfer-fee_35_2 (/ (* transfer-fee (var-get transfer-fee-percent_35_2)) ONE_6))
                (transfer-fee_10 (/ (* transfer-fee (var-get transfer-fee-percent_10)) ONE_6))
                (transfer-fee_20 (/ (* transfer-fee (var-get transfer-fee-percent_20)) ONE_6))
                (scope_fee_35 (var-get share-fee-to_35))
                (scope_fee_35_2 (var-get share-fee-to_35_2))
                (scope_fee_10 (var-get share-fee-to_10))
                (scope_fee_20 (var-get share-fee-to_20))

            )  
            (try! (contract-call? 
            'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-router swap-exact-tokens-for-tokens 
            id
            token0 token1
            token-in token-out
            share-fee-to
            amt-in
            amt-out-min))
            (try! (stx-transfer? transfer-fee_35 sender scope_fee_35))
            (try! (stx-transfer? transfer-fee_35_2 sender scope_fee_35_2))
            (try! (stx-transfer? transfer-fee_10 sender scope_fee_10))
            (try! (stx-transfer? transfer-fee_20 sender scope_fee_20))
            (try! (as-contract (contract-call? reward-token transfer
            amt-in
            contract
            sender
            none)))
            (ok true)
            
        )
)


(define-read-only (get-transfer-fee-percent)
	(ok (var-get transfer-fee-percent))
)
```
