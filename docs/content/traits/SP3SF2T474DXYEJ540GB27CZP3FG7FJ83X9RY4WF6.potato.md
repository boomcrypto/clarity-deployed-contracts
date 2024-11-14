---
title: "Trait potato"
draft: true
---
```
(use-trait ft-trait-a 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.trait-sip-010.sip-010-trait)
(use-trait ft-trait-b 'SP2AKWJYC7BNY18W1XXKPGP0YVEK63QJG4793Z2D4.sip-010-trait-ft-standard.sip-010-trait)
(use-trait ft-trait-c 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.dao-traits-v4.sip010-ft-trait)
(use-trait share-fee-to-trait 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-share-fee-to-trait.share-fee-to-trait)
(use-trait share-fee-to-trait-c 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.dao-traits-v4.share-fee-to-trait)


(define-constant ERR-NOT-AUTHORIZED (err u11000))

(define-data-var contract-owner principal tx-sender)

;; (define-read-only (is-approved)
;; 	(contract-call? .auth-v0-0 is-approved contract-caller)
;; )

;; buy A sell B
;; todo add price &/or slippage in arguments & assert its within a threshold to guarantee sell price 
(define-public (swap-a-b (source-trait <ft-trait-a>) 
													(target-trait <ft-trait-a>) 
													(dx uint) 
													(min-d-target uint) 
													(source-factor uint) 
													(id uint)
													(token0 <ft-trait-b>)
													(token1 <ft-trait-b>)
													(token-in <ft-trait-b>)
													(token-out <ft-trait-b>)
													(share-fee-to <share-fee-to-trait>)
													(amt-out-min uint)
													(decDiff uint))
								(contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-router swap-exact-tokens-for-tokens id token0 token1 token-in token-out share-fee-to 
																																						(/ (try! 
																																							(contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-helper source-trait target-trait source-factor dx (some min-d-target))
																																							) decDiff) ;; amt-in
																																			amt-out-min)
)

;; buy B sell A
(define-public (swap-b-a (source-trait <ft-trait-a>) 
													(target-trait <ft-trait-a>) 
													(min-d-target uint) 
													(source-factor uint) 
													(id uint)
													(token0 <ft-trait-b>)
													(token1 <ft-trait-b>)
													(token-in <ft-trait-b>)
													(token-out <ft-trait-b>)
													(amt-in uint)
													(amt-out-min uint)
													(share-fee-to <share-fee-to-trait>)
													(decDiff uint))
								(contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-helper source-trait target-trait source-factor 
																					(* (get amt-out (try! (contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-router swap-exact-tokens-for-tokens id token0 token1 token-in token-out share-fee-to amt-in amt-out-min))) decDiff)
																					(some min-d-target)) 
)



(define-public (swap-a-c3 (source-trait <ft-trait-a>) 
													(target-trait <ft-trait-a>) 
													(dx uint) 
													(min-d-target uint) 
													(source-factor uint) 
													(token-a <ft-trait-c>)
													(token-b <ft-trait-c>)
													(token-c <ft-trait-c>)
													(amt-out-min uint)
													(share-fee-to <share-fee-to-trait-c>)
													(decDiff uint))
								(contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.univ2-path2 swap-3
																																											(/ (try! 
																																												(contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-helper source-trait target-trait source-factor dx (some min-d-target))
																																											) decDiff) 
																																											amt-out-min
																																											token-a
																																											token-b
																																											token-c
																																											share-fee-to
))

(define-public (swap-c3-a (source-trait <ft-trait-a>) 
													(target-trait <ft-trait-a>) 
													(min-d-target uint) 
													(source-factor uint) 
													(token-a <ft-trait-c>)
													(token-b <ft-trait-c>)
													(token-c <ft-trait-c>)
													(amt-in uint)
													(amt-out-min uint)
													(share-fee-to <share-fee-to-trait-c>)
													(decDiff uint))
								(contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-helper source-trait target-trait source-factor 
																					(* (get amt-out (get b (try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.univ2-path2 swap-3 amt-in amt-out-min
																																											token-a
																																											token-b
																																											token-c
																																											share-fee-to)
																						))) decDiff)
																					(some min-d-target)) 
)

(define-public (swap-c3-b (token-a <ft-trait-c>)
													(token-b <ft-trait-c>)
													(token-c <ft-trait-c>)
													(amt-in-c uint)
													(amt-out-min-c uint)
													(share-fee-to-c <share-fee-to-trait>)
													(id uint)
													(token0 <ft-trait-b>)
													(token1 <ft-trait-b>)
													(token-in <ft-trait-b>)
													(token-out <ft-trait-b>)
													(share-fee-to <share-fee-to-trait>)
													(amt-out-min uint)
													(decDiff uint))
								(contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-router swap-exact-tokens-for-tokens id token0 token1 token-in token-out share-fee-to 
																																		(* (get amt-out (get c 
																																		(try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.univ2-path2 swap-3 
																																																										amt-in-c 
																																																										amt-out-min-c
																																																										token-a
																																																										token-b
																																																										token-c
																																																										share-fee-to-c
																																														)))
																																	) 
																																	decDiff)
																amt-out-min
																))

(define-public (swap-b-c3 (token-a <ft-trait-c>)
													(token-b <ft-trait-c>)
													(token-c <ft-trait-c>)
													(amt-out-min-c uint)
													(share-fee-to-c <share-fee-to-trait>)
													(id uint)
													(token0 <ft-trait-b>)
													(token1 <ft-trait-b>)
													(token-in <ft-trait-b>)
													(token-out <ft-trait-b>)
													(amt-in uint)
													(amt-out-min uint)
													(share-fee-to <share-fee-to-trait>)
													(decDiff uint))
										(contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.univ2-path2 swap-3
																					(* (get amt-out (try! (contract-call? 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-router swap-exact-tokens-for-tokens id token0 token1 token-in token-out share-fee-to amt-in amt-out-min))) decDiff)
																			amt-out-min
																			token-a
																			token-b
																			token-c
																			share-fee-to-c
))
```
