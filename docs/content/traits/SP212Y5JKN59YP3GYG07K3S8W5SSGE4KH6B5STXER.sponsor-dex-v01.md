---
title: "Trait sponsor-dex-v01"
draft: true
---
```
(use-trait ft-trait 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.trait-sip-010.sip-010-trait)

(define-constant err-unauthorized (err u1000))

(define-read-only (is-dao-or-extension)
	(ok (asserts! (or (is-eq tx-sender .executor-dao) (contract-call? .executor-dao is-extension contract-caller)) err-unauthorized)))

(define-public (claim (token <ft-trait>) (amount uint) (recipient principal))
	(begin
		(try! (is-dao-or-extension))
		(as-contract (contract-call? token transfer amount tx-sender recipient none))
	)
)

(define-public (swap-helper (token-x <ft-trait>) (token-y <ft-trait>) (factor uint) (dx uint) (min-dy (optional uint)) (fee uint))
	(begin
		(try! (contract-call? token-x transfer fee tx-sender (as-contract tx-sender) none))
		(ok (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-helper token-x token-y factor dx min-dy))
	)
)

(define-public (swap-helper-a (token-x <ft-trait>) (token-y <ft-trait>) (token-z <ft-trait>) (factor-x uint) (factor-y uint) (dx uint) (min-dz (optional uint)) (fee uint))
	(begin
		(try! (contract-call? token-x transfer fee tx-sender (as-contract tx-sender) none))
		(ok (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-helper-a token-x token-y token-z factor-x factor-y dx min-dz))
	)
)

(define-public (swap-helper-b
		(token-x <ft-trait>) (token-y <ft-trait>) (token-z <ft-trait>) (token-w <ft-trait>)
		(factor-x uint) (factor-y uint) (factor-z uint)
		(dx uint) (min-dw (optional uint)) (fee uint))
	(begin
		(try! (contract-call? token-x transfer fee tx-sender (as-contract tx-sender) none))
		(ok (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-helper-b token-x token-y token-z token-w factor-x factor-y factor-z dx min-dw))
	)
)

(define-public (swap-helper-c
		(token-x <ft-trait>) (token-y <ft-trait>) (token-z <ft-trait>) (token-w <ft-trait>) (token-v <ft-trait>)
		(factor-x uint) (factor-y uint) (factor-z uint) (factor-w uint)
		(dx uint) (min-dv (optional uint)) (fee uint))
	(begin
		(try! (contract-call? token-x transfer fee tx-sender (as-contract tx-sender) none))
		(ok (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-helper-c token-x token-y token-z token-w token-v factor-x factor-y factor-z factor-w dx min-dv))
	)
)
```
