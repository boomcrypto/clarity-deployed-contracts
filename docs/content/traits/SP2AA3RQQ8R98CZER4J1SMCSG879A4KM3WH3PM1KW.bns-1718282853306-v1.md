---
title: "Trait bns-1718282853306-v1"
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
			'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-x-for-y
			'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token
			'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token
			a0 u0)))
		(a1 (unwrap-panic (element-at b0 u1)))
		(b1 (try! (contract-call?
			'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-router swap-exact-tokens-for-tokens
			u27
			'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
			'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token
			'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token
			'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
			'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-share-fee-to
			a1 u1)))
		(a2 (get amt-out b1))
	)
		(asserts! (> a2 a0) (err a2))
		(try! (stx-transfer? a2 tx-sender sender))
		(ok (list a0 a1 a2))
))))

(define-public (swap-y-for-x (a0 uint))
(let ((sender tx-sender))
	(asserts! (is-eq tx-sender A) (err u0))
	(try! (stx-transfer? a0 sender (as-contract tx-sender)))
	(as-contract
	(let (
		(b0 (try! (contract-call?
			'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-router swap-exact-tokens-for-tokens
			u27
			'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
			'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token
			'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
			'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token
			'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-share-fee-to
			a0 u1)))
		(a1 (get amt-out b0))
		(b1 (try! (contract-call?
			'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1 swap-y-for-x
			'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token
			'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token
			a1 u0)))
		(a2 (unwrap-panic (element-at b1 u0)))
	)
		(asserts! (> a2 a0) (err a2))
		(try! (stx-transfer? a2 tx-sender sender))
		(ok (list a0 a1 a2))
))))

(define-public (add-to-position (a0 uint))
(let ((sender tx-sender))
	(asserts! (is-eq tx-sender A) (err u0))
	(try! (stx-transfer? a0 sender (as-contract tx-sender)))
	(as-contract
	(let (
		(b0 (try! (contract-call?
			'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-router swap-exact-tokens-for-tokens
			u27
			'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
			'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token
			'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
			'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token
			'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-share-fee-to
			a0 u1)))
		(a1 (get amt-out b0))
		(b1 (try! (contract-call?
			'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-y-for-x
			'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2
			'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wcorgi
			u100000000 (* a1 u100) none)))
		(a2 (/ (get dx b1) u100))
	)
		(asserts! (> a2 a0) (err a2))
		(try! (stx-transfer? a2 tx-sender sender))
		(ok (list a0 a1 a2))
))))

(define-public (reduce-position (a0 uint))
(let ((sender tx-sender))
	(asserts! (is-eq tx-sender A) (err u0))
	(try! (stx-transfer? a0 sender (as-contract tx-sender)))
	(as-contract
	(let (
		(b0 (try! (contract-call?
			'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-x-for-y
			'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2
			'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wcorgi
			u100000000 (* a0 u100) none)))
		(a1 (/ (get dy b0) u100))
		(b1 (try! (contract-call?
			'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-router swap-exact-tokens-for-tokens
			u27
			'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
			'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token
			'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token
			'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.wstx
			'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-share-fee-to
			a1 u1)))
		(a2 (get amt-out b1))
	)
		(asserts! (> a2 a0) (err a2))
		(try! (stx-transfer? a2 tx-sender sender))
		(ok (list a0 a1 a2))
))))

(define-public (purchase-name (dx uint))
    (ok (list 
        (swap-x-for-y dx)
        (swap-y-for-x dx)
        (add-to-position dx)
        (reduce-position dx)
    ))
)
```
