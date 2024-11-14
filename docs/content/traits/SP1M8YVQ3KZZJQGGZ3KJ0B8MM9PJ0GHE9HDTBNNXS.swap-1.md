---
title: "Trait swap-1"
draft: true
---
```
(use-trait ft-trait 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.trait-sip-010.sip-010-trait)
(define-constant ERR-NOT-AUTHORIZED (err u100))
(define-constant ERR-INVALID-LIQUIDITY (err u101))
(define-constant ERR-PAUSED (err u102))
(define-constant ONE_8 u100000000)
(define-constant CONTRACT_OWNER 'SP21SK3F23JMA5E15R8TQK3AVX6PEZFXEHT6RKNCG)
(define-data-var DEFAULT_FEE uint u1000000)
(define-data-var paused bool false)
(define-private (assert-contract-owner) (ok (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR-NOT-AUTHORIZED)))
(define-private (mul-up (a uint) (b uint))
	(let (
		(product (* a b))
	)
	(if (is-eq product u0) u0 (+ u1 (/ (- product u1) ONE_8)))))
(define-public (update-fee (new-fee uint))
    (begin
        (asserts! (> new-fee u0) ERR-INVALID-LIQUIDITY)
        (try! (assert-contract-owner))
        (ok (var-set DEFAULT_FEE new-fee))
    )
)
(define-read-only (is-paused) (var-get paused))
(define-public (swap-helper-with-fee (token-x-trait <ft-trait>) (token-y-trait <ft-trait>) (factor uint) (dx uint) (min-dy (optional uint)) (swap-fee (optional uint)))
    (let (
        (fee (mul-up dx (default-to (var-get DEFAULT_FEE) swap-fee)))
        (dx-net-fees (if (<= dx fee) u0 (- dx fee)))
    )   
        (asserts! (not (is-paused)) ERR-PAUSED)
        (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-helper token-x-trait token-y-trait factor dx-net-fees min-dy))
        ;; #[filter(token-x-trait)]
        (try! (contract-call? token-x-trait transfer-fixed fee tx-sender .swap-1 none))
        (print {
            dx: dx,
            fee: fee,
            dx-net-fees: dx-net-fees,
            min-dy: min-dy,
            token-x-trait: token-x-trait,
        })
        (ok true)
    )
)
(define-public (swap-helper-a-with-fee (token-x-trait <ft-trait>) (token-y-trait <ft-trait>) (token-z-trait <ft-trait>) (factor-x uint) (factor-y uint) (dx uint) (min-dz (optional uint)) (swap-fee (optional uint)))
    (let (
        (fee (mul-up dx (default-to (var-get DEFAULT_FEE) swap-fee)))
        (dx-net-fees (if (<= dx fee) u0 (- dx fee)))
    )   
        (asserts! (not (is-paused)) ERR-PAUSED)
        (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-helper-a token-x-trait token-y-trait token-z-trait factor-x factor-y dx-net-fees min-dz))
        ;; #[filter(token-x-trait)]
        (try! (contract-call? token-x-trait transfer-fixed fee tx-sender .swap-1 none))
        (print {
            dx: dx,
            fee: fee,
            dx-net-fees: dx-net-fees,
            min-dz: min-dz,
            token-x-trait: token-x-trait,
        })
        (ok true)
    )
)
(define-public (swap-helper-b (token-x-trait <ft-trait>) (token-y-trait <ft-trait>) (token-z-trait <ft-trait>) (token-w-trait <ft-trait>) (factor-x uint) (factor-y uint) (factor-z uint) (dx uint) (min-dw (optional uint)) (swap-fee (optional uint)))
    (let (
        (fee (mul-up dx (default-to (var-get DEFAULT_FEE) swap-fee)))
        (dx-net-fees (if (<= dx fee) u0 (- dx fee)))
    )   
        (asserts! (not (is-paused)) ERR-PAUSED)
        (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-helper-b token-x-trait token-y-trait token-z-trait token-w-trait factor-x factor-y factor-z dx-net-fees min-dw))
        ;; #[filter(token-x-trait)]
        (try! (contract-call? token-x-trait transfer-fixed fee tx-sender .swap-1 none))
        (print {
            dx: dx,
            fee: fee,
            dx-net-fees: dx-net-fees,
            min-dw: min-dw,
            token-x-trait: token-x-trait,
        })
        (ok true)
    )
)
(define-public (swap-helper-c (token-x-trait <ft-trait>) (token-y-trait <ft-trait>) (token-z-trait <ft-trait>) (token-w-trait <ft-trait>) (token-v-trait <ft-trait>) (factor-x uint) (factor-y uint) (factor-z uint) (factor-w uint) (dx uint) (min-dv (optional uint)) (swap-fee (optional uint)))
    (let (
        (fee (mul-up dx (default-to (var-get DEFAULT_FEE) swap-fee)))
        (dx-net-fees (if (<= dx fee) u0 (- dx fee)))
    )   
        (asserts! (not (is-paused)) ERR-PAUSED)
        (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-helper-c token-x-trait token-y-trait token-z-trait token-w-trait token-v-trait factor-x factor-y factor-z factor-w dx-net-fees min-dv))
        ;; #[filter(token-x-trait)]
        (try! (contract-call? token-x-trait transfer-fixed fee tx-sender .swap-1 none))
        (print {
            dx: dx,
            fee: fee,
            dx-net-fees: dx-net-fees,
            min-dw: min-dv,
            token-x-trait: token-x-trait,
        })
        (ok true)
    )
)
(define-public (withdraw-fees (token <ft-trait>) (amount uint) (recipient principal))
    (begin
        (try! (assert-contract-owner))
        ;; #[filter(token)]
        (try! (as-contract (contract-call? token transfer-fixed amount .swap-1 recipient none)))
        (ok true)
    )
)
(define-public (pause (new-paused bool))
	(begin
		(try! (assert-contract-owner))
		(ok (var-set paused new-paused))
    )
)
```
