;; Title: Supply Adjuster
;; Author: rozar.btc
;; Synopsis:
;; This airdrops tokens to early users to account for the supply increase.

(impl-trait .dao-traits-v2.extension-trait)

(define-constant err-unauthorized (err u3000))
(define-constant err-generic (err u500))

(define-constant target-block u149340)

;; --- Authorization check

(define-read-only (is-dao-or-extension)
	(ok (asserts! (or (is-eq tx-sender 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.dungeon-master) (contract-call? 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.dungeon-master is-extension contract-caller)) err-unauthorized))
)

(define-public (airdrop (address principal))
	(let
		(
			(amount (unwrap! (contract-call? .balance-at-block-v2 get-balance-at-block address target-block) err-generic))
		)
		(try! (is-dao-or-extension))
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
		(try! (is-dao-or-extension))
		;; airdrop rewards to early users to account for the increased supply
		(map airdrop (contract-call? .early-users-list-v0 get-users))
		(ok true)
	)
)

;; --- Extension callback

(define-public (callback (sender principal) (memo (buff 34)))
	(ok true)
)

(contract-call? 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.dungeon-master set-extension (as-contract tx-sender) true)