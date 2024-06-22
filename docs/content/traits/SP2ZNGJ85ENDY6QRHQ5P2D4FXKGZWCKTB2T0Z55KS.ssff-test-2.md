---
title: "Trait ssff-test-2"
draft: true
---
```
(define-constant err-unauthorized (err u3000))
(define-constant err-insufficient-funds (err u4001))

(define-constant ONE_6 (pow u10 u6)) ;; 6 decimal places

(define-constant contract (as-contract tx-sender))

(define-public (swap-stx-for-fenrir (amount-stx uint) (amount-fenrir uint) (amount-swelsh uint) (amount-sodin uint) (amt-in-max uint))
    (let (
        (sender tx-sender)
        (fee-percent (unwrap-panic (contract-call? .fenrir-corgi-of-ragnarok get-craft-fee-percent)))
        (amount-swelsh-plus-fees (+ amount-swelsh (/ (* amount-swelsh fee-percent) ONE_6)))
        (amount-sodin-plus-fees (+ amount-sodin (/ (* amount-sodin fee-percent) ONE_6)))
    )
        (asserts! (>= (stx-get-balance tx-sender) amount-stx) err-insufficient-funds)
        (print {amount-stx: amount-stx, amount-fenrir: amount-fenrir, amount-swelsh: amount-swelsh, amount-sodin: amount-sodin, fee-percent: fee-percent, amount-swelsh-plus-fees: amount-swelsh-plus-fees, amount-sodin-plus-fees: amount-sodin-plus-fees})
        (try! (stx-transfer? amount-stx tx-sender contract))
        (try! (as-contract (contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-router swap-tokens-for-exact-tokens u26 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx .liquid-staked-welsh-v2 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx .liquid-staked-welsh-v2 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-share-fee-to amt-in-max amount-swelsh-plus-fees)))
        (try! (as-contract (contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-router swap-tokens-for-exact-tokens u24 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx .liquid-staked-odin 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx .liquid-staked-odin 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-share-fee-to amt-in-max amount-sodin-plus-fees)))
        (try! (as-contract (contract-call? .liquid-staked-welsh-v2 deflate amount-swelsh-plus-fees)))
        (try! (as-contract (contract-call? .liquid-staked-odin deflate amount-sodin-plus-fees)))
        (try! (as-contract (stx-transfer? (stx-get-balance contract) contract sender)))
        (ok true)
    )
)
```
