;; Title: DME014 STX Rewards
;; Author: rozar.btc
;; Depends-On: DME000, DME001
;; Synopsis:
;; A modular rewards system that disburses STX rewards for quest completions.
;; Description:
;; The rewards are paid out by the contract, which is controlled by the DAO. 
;; The DAO can also set the fee percentage and the fee address.

(impl-trait 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.extension-trait.extension-trait)

(define-constant err-not-found (err u2001))
(define-constant err-unauthorized (err u3100))

(define-map quest-rewards-map uint uint)

(define-data-var fee-percentage uint u5)
(define-data-var fee-address principal 'SP2MR4YP9C7P93EJZC4W1JT8HKAX8Q4HR9Q6X3S88)

;; --- Authorization check

(define-public (is-dao-or-extension)
	(ok (asserts! (or (is-eq tx-sender 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.dungeon-master) (contract-call? 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.dungeon-master is-extension contract-caller)) err-unauthorized))
)

;; --- Internal DAO functions

(define-public (claim (quest-id uint))
	(begin
        (try! (is-dao-or-extension))
		(let
			(
				(reward-amount (default-to u0 (map-get? quest-rewards-map quest-id)))
				(percentage (var-get fee-percentage))
				(fee-amount (/ (* reward-amount percentage) u100))
				(address (var-get fee-address))
				(sender tx-sender)
			)
			(try! (as-contract (stx-transfer? reward-amount tx-sender sender)))
			(as-contract (stx-transfer? fee-amount tx-sender address))
		)
	)
)

(define-public (set-rewards (quest-id uint) (amount uint))
	(begin
		(try! (is-dao-or-extension))
	    (ok (map-set quest-rewards-map quest-id amount ))
	)
)

(define-public (set-fee-percentage (amount uint))
	(begin
		(try! (is-dao-or-extension))
		(ok (var-set fee-percentage amount))
	)
)

;; --- Public functions

(define-read-only (get-rewards (quest-id uint))
	(ok (default-to u0 (map-get? quest-rewards-map quest-id)))
)

(define-read-only (get-fee-percentage)
	(ok (var-get fee-percentage))
)

;; --- Extension callback

(define-public (callback (sender principal) (memo (buff 34)))
	(ok true)
)