---
title: "Trait univ2-router"
draft: true
---
```
(define-constant A tx-sender)

(define-public (swap-x-for-y (a0 uint))
(let ((sender tx-sender))
	(asserts! (is-eq tx-sender A) (err u0))
	(try! (stx-transfer? a0 sender (as-contract tx-sender)))
	(as-contract
	(let (
		(b0 (try! (contract-call?
			'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-x-for-y
			'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2
			'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex
			u100000000 (* a0 u100) none)))
		(a1 (/ (get dy b0) u100))
		(b1 (try! (contract-call?
			'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-x-for-y
			'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex
			'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wusda
			u100000000 (* a1 u100) none)))
		(a2 (/ (get dy b1) u100))
		(b2 (try! (contract-call?
            'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-y-for-x
            'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token
            'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token
            a2 u0)))
        (a3 (unwrap-panic (element-at b2 u0)))
	)
		(asserts! (> a3 a0) (err a3))
		(try! (stx-transfer? a3 tx-sender sender))
		(ok (list a0 a1 a2 a3))
	)
	)
))

(define-public (swap-y-for-x (a0 uint))
(let ((sender tx-sender))
	(asserts! (is-eq tx-sender A) (err u0))
	(try! (stx-transfer? a0 sender (as-contract tx-sender)))
	(as-contract
	(let (
        (b0 (try! (contract-call?
			'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-x-for-y
            'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token
            'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token
			a0 u0)))
		(a1 (unwrap-panic (element-at b0 u1)))
		(b1 (try! (contract-call?
			'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-y-for-x
			'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex
			'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wusda
			u100000000 (* a1 u100) none)))
		(a2 (/ (get dx b1) u100))
		(b2 (try! (contract-call?
			'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-y-for-x
			'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2
			'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex
			u100000000 (* a2 u100) none)))
		(a3 (/ (get dx b2) u100))
	)
		(asserts! (> a3 a0) (err a3))
		(try! (stx-transfer? a3 tx-sender sender))
		(ok (list a0 a1 a2 a3))
	)
	)
))

(define-public (add-to-position (a0 uint))
(let ((sender tx-sender))
	(asserts! (is-eq tx-sender A) (err u0))
	(try! (stx-transfer? a0 sender (as-contract tx-sender)))
	(as-contract
	(let (
		(b0 (try! (contract-call?
			'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-x-for-y
			'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2
			'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex
			u100000000 (* a0 u100) none)))
		(a1 (/ (get dy b0) u100))
		(b1 (try! (contract-call?
			'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-x-for-y
			'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex
			'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wdiko
			u100000000 (* a1 u100) none)))
		(a2 (/ (get dy b1) u100))
		(b2 (try! (contract-call?
            'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-y-for-x
            'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token
            'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token
            a2 u0)))
        (a3 (unwrap-panic (element-at b2 u0)))
	)
		(asserts! (> a3 a0) (err a3))
		(try! (stx-transfer? a3 tx-sender sender))
		(ok (list a0 a1 a2 a3))
	)
	)
))

(define-public (reduce-position (a0 uint))
(let ((sender tx-sender))
	(asserts! (is-eq tx-sender A) (err u0))
	(try! (stx-transfer? a0 sender (as-contract tx-sender)))
	(as-contract
	(let (
        (b0 (try! (contract-call?
			'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-x-for-y
            'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token
            'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token
			a0 u0)))
		(a1 (unwrap-panic (element-at b0 u1)))
		(b1 (try! (contract-call?
			'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-y-for-x
			'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex
			'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wdiko
			u100000000 (* a1 u100) none)))
		(a2 (/ (get dx b1) u100))
		(b2 (try! (contract-call?
			'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-y-for-x
			'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2
			'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex
			u100000000 (* a2 u100) none)))
		(a3 (/ (get dx b2) u100))
	)
		(asserts! (> a3 a0) (err a3))
		(try! (stx-transfer? a3 tx-sender sender))
		(ok (list a0 a1 a2 a3))
	)
	)
))
```
