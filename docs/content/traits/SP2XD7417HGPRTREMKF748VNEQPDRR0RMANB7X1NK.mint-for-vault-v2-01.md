---
title: "Trait mint-for-vault-v2-01"
draft: true
---
```
(use-trait ft-trait .trait-sip-010.sip-010-trait)
(define-constant err-unauthorised (err u1000))
(define-read-only (is-dao-or-extension)
	(ok (asserts! (or (is-eq tx-sender .executor-dao) (contract-call? .executor-dao is-extension contract-caller)) err-unauthorised)))
(define-public (mint-for-vault (token-trait <ft-trait>) (amount-in-fixed uint) (dest-chain-id uint) (settle-address (buff 256)) (src-address (buff 256)))
	(begin
		(try! (contract-call? token-trait mint-fixed amount-in-fixed tx-sender))
		(try! (contract-call? .cross-peg-out-endpoint-v2-01 transfer-to-unwrap token-trait amount-in-fixed dest-chain-id settle-address))
		(print { event: "mint-for-vault", payload: { token: (contract-of token-trait), amount: amount-in-fixed, dest-chain-id: dest-chain-id, settle-address: settle-address, src-address: src-address }})
		(ok true)))
```
