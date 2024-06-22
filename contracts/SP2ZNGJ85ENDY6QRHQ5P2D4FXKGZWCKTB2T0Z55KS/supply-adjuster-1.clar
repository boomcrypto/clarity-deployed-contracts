;; Title: Supply Adjuster
;; Author: rozar.btc
;; Synopsis:
;; This airdrops tokens to early users to account for the supply increase.

(define-constant err-generic (err u500))
(define-constant target-block u149340)

(define-public (airdrop (address principal))
	(let
		(
			(amount (unwrap! (contract-call? .balance-at-block-v2 get-balance-at-block address target-block) err-generic))
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