;; Title: DME009 Charisma Rewards
;; Author: rozar.btc
;; Depends-On: DME000, DME001 
;; Synopsis:
;; A modular rewards system that disburses Charisma rewards for quest completions.
;; Description:
;; The Charisma Rewards contract serves as the foundational framework for distributing Charisma tokens as rewards for quest completions. 
;; It maintains an internal record of reward amounts mapped to specific quests. 
;; Ensuring secure and authorized claim procedures, this contract integrates seamlessly with the larger quest ecosystem, 
;; offering a tangible incentive for users to engage and complete quests.

(impl-trait 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.extension-trait.extension-trait)

(define-constant err-not-found (err u2001))
(define-constant err-unauthorized (err u3100))

(define-map quest-rewards-map uint uint)
(define-map quest-locked-map
  {
    address: principal,
    quest-id: uint,
  }
  bool
)

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
			)
			(contract-call? 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.dme000-governance-token dmg-mint reward-amount tx-sender)
		)
	)
)

(define-public (set-rewards (quest-id uint) (amount uint))
	(begin
		(try! (is-dao-or-extension))
	    (ok (map-set quest-rewards-map quest-id amount ))
	)
)

(define-public (set-locked (address principal) (quest-id uint) (locked bool))
	(begin
		(try! (is-dao-or-extension))
	    (ok (map-set quest-locked-map { address: address, quest-id: quest-id } locked))
	)
)

;; --- Public functions

(define-read-only (get-rewards (quest-id uint))
	(ok (default-to u0 (map-get? quest-rewards-map quest-id)))
)

(define-read-only (is-locked (address principal) (quest-id uint))
	(ok (default-to false (map-get? quest-locked-map { address: address, quest-id: quest-id })))
)

;; --- Extension callback

(define-public (callback (sender principal) (memo (buff 34)))
	(ok true)
)