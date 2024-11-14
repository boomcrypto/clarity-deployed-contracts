---
title: "Trait fuji-helper-v0"
draft: true
---
```
(define-public (restock (cha-amount uint) (target-farm principal))
	(let
		(
			(fuji-amount (try! (mint cha-amount)))
		)
		(contract-call? .fuji-apples transfer fuji-amount tx-sender target-farm none)
	)
)

(define-public (mint (cha-amount uint))
	(let
		(
      (scha-amount (try! (contract-call? .scha-helper-v0 mint cha-amount)))
			(fuji-amount (try! (stake scha-amount)))
		)
		(ok fuji-amount)
	)
)

(define-public (stake (scha-amount uint))
	(let
		(
			(initial-fuji-balance (unwrap-panic (contract-call? .fuji-apples get-balance tx-sender)))
		)
		(try! (contract-call? .fuji-apples add-liquidity (/ scha-amount u2)))
		(let
			(
				(after-fuji-balance (unwrap-panic (contract-call? .fuji-apples get-balance tx-sender)))
				(fuji-balance (- after-fuji-balance initial-fuji-balance))
			)
			(ok fuji-balance)
		)
	)
)
```
