---
title: "Trait swap-test-1"
draft: true
---
```
;; Title: Swap Wrapper v3
;; Author: rozar.btc

(define-constant err-insufficient-funds (err u4001))

(define-constant ONE_6 (pow u10 u6)) ;; 6 decimal places

(define-constant contract (as-contract tx-sender))

(define-public (swap-stx-for-fenrir (amount-stx uint) (amount-stx-for-swelsh uint) (amount-stx-for-sodin uint) (amount-fenrir uint))
    (let (
        (sender tx-sender)
    )
        (asserts! (>= (stx-get-balance sender) amount-stx) err-insufficient-funds)
        (try! (stx-transfer? amount-stx sender contract))
        (try! (swap-stx-for-swelsh amount-stx-for-swelsh u1))
        (try! (swap-stx-for-sodin amount-stx-for-sodin u1))
        ;; (try! (as-contract (contract-call? .crafting-helper craft .fenrir-corgi-of-ragnarok amount-fenrir .liquid-staked-welsh-v2 .liquid-staked-odin)))
        (try! (swap-all-swelsh-for-stx u1))
        (try! (swap-all-sodin-for-stx u1))
        (as-contract (stx-transfer? (stx-get-balance contract) contract sender))
        ;; (as-contract (contract-call? .fenrir-corgi-of-ragnarok transfer amount-fenrir contract sender none))
    )
)

(define-public (swap-fenrir-for-stx (amount-fenrir uint))
    (let (
        (sender tx-sender)
    )
        (asserts! (>= (unwrap-panic (contract-call? .fenrir-corgi-of-ragnarok get-balance sender)) amount-fenrir) err-insufficient-funds)
        (try! (contract-call? .fenrir-corgi-of-ragnarok transfer amount-fenrir sender contract none))
        (try! (as-contract (contract-call? .crafting-helper salvage .fenrir-corgi-of-ragnarok (unwrap-panic (contract-call? .fenrir-corgi-of-ragnarok get-balance contract)) .liquid-staked-welsh-v2 .liquid-staked-odin)))
        (try! (swap-all-swelsh-for-stx u1))
        (try! (swap-all-sodin-for-stx u1))
        (as-contract (stx-transfer? (stx-get-balance contract) contract sender))
    )
)

(define-private (swap-stx-for-swelsh (amount-stx uint) (amt-out-min uint))
    (as-contract (contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-router swap-exact-tokens-for-tokens u26 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx .liquid-staked-welsh-v2 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx .liquid-staked-welsh-v2 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-share-fee-to amount-stx amt-out-min))
)

(define-private (swap-stx-for-sodin (amount-stx uint) (amt-out-min uint))
    (as-contract (contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-router swap-exact-tokens-for-tokens u24 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx .liquid-staked-odin 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx .liquid-staked-odin 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-share-fee-to amount-stx amt-out-min))
)

(define-private (swap-all-swelsh-for-stx (amt-out-min uint))
    (as-contract (contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-router swap-exact-tokens-for-tokens u26 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx .liquid-staked-welsh-v2 .liquid-staked-welsh-v2 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-share-fee-to (unwrap-panic (contract-call? .liquid-staked-welsh-v2 get-balance contract)) amt-out-min)) 
)

(define-private (swap-all-sodin-for-stx (amt-out-min uint))
    (as-contract (contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-router swap-exact-tokens-for-tokens u24 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx .liquid-staked-odin .liquid-staked-odin 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-share-fee-to (unwrap-panic (contract-call? .liquid-staked-odin get-balance contract)) amt-out-min))
)
```
