---
title: "Trait supply-adjuster"
draft: true
---
```
;; Title: Supply Adjuster
;; Author: rozar.btc
;; Synopsis:
;; This airdrops tokens to early users to account for the supply increase.

(define-constant err-generic (err u500))

(define-read-only (get-balance-at-block (address principal) (block-hash (buff 32)))
	(at-block block-hash (contract-call? 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.dme000-governance-token get-balance address))
)

(define-public (airdrop (address principal))
	(let
		(
			(amount (unwrap! (get-balance-at-block address 0x5930a3707877fcb574d4abef243f0b795c0a781c338f40df5dbbee077e78a031) err-generic))
		)
		(try! (contract-call? 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.dme000-governance-token dmg-mint (* amount u999999) address))
		(print {
			notification: "airdrop",
			payload: {
				recipient: address,
				amount: amount
			}
		})
		(ok true)
	)
)

(define-public (airdrop-early-users)
	(begin
		;; airdrop rewards to early users to account for the increased supply
		(map airdrop (contract-call? .early-users-list-v0 get-users))
		(ok true)
	)
)
```
