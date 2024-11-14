---
title: "Trait default-strategy"
draft: true
---
```
(impl-trait .strategy.default-strategy)

(use-trait ft 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.trait-sip-010.sip-010-trait)


(define-constant ERR-NOT-AUTHORIZED (err u1000))

(define-read-only (is-approved)
	(contract-call? .auth is-approved)
)


(define-public (swap-wrapper (source-trait <ft>) 
															(target-trait <ft>) 
															(source-factor uint) 
															(dx uint) 
															(min-d-target uint) 
															(amm-id uint) 
															(factor-hop uint)
															(hop-trait-opt (optional <ft>))) 
(begin
	(asserts! (is-approved) ERR-NOT-AUTHORIZED) 
	(let ((swap-response (try! (swap source-trait target-trait source-factor dx min-d-target amm-id factor-hop hop-trait-opt))))
			 (try! (as-contract (contract-call? target-trait transfer swap-response tx-sender .dca-vault none)))
			 (print {function:"swap-wrapper", 
			 				params:{source-trait:source-trait, target-trait:target-trait, source-factor:source-factor, dx:dx, min-d-target:min-d-target, amm-id:amm-id, facotr-hop:factor-hop, hop-trait-opt:hop-trait-opt},
							more:{swap-response:swap-response}})
			 (ok swap-response)
)))



(define-private (swap (source-trait <ft>) 
															(target-trait <ft>) 
															(source-factor uint) 
															(dx uint) 
															(min-d-target uint) 
															(amm-id uint) 
															(factor-hop uint)
															(hop-trait-opt (optional <ft>))) 
			(match hop-trait-opt hop-trait 
													(as-contract (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-helper-a source-trait target-trait hop-trait source-factor factor-hop dx (some min-d-target)))
													(as-contract (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-pool-v2-01 swap-helper source-trait target-trait source-factor dx (some min-d-target)))
))
```
