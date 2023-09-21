;; Title: DME016 Quest Ownership
;; Author: rozar.btc
;; Depends-On: 
;; Synopsis: 
;; A smart contract for tracking the ownership of quests and quest-rewards deposited.
;; Description:
;; This defines state giving quests an owner principal which can be used to update the quest.
;; It also includes a map for quest-rewards deposited that only the DAO can modify.

(impl-trait 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.extension-trait.extension-trait)

(define-constant err-unauthorized (err u3100))

(define-map quest-ownership-map uint principal)
(define-map quest-rewards-deposited-map uint uint)

;; --- Authorization checks

(define-read-only (is-owner (quest-id uint))
    (match (map-get? quest-ownership-map quest-id)
        current-owner (ok (is-eq tx-sender current-owner))
        err-unauthorized
    )
)

(define-public (is-dao-or-extension)
	(ok (asserts! (or (is-eq tx-sender 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.dungeon-master) (contract-call? 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.dungeon-master is-extension contract-caller)) err-unauthorized))
)

;; --- Quest Owner functions

(define-public (set-owner (quest-id uint) (owner principal))
    (let ((current-owner-opt (map-get? quest-ownership-map quest-id)))
        (begin
            ;; if there is no owner or the user is the owner, set it
            (asserts! (or (is-none current-owner-opt) (is-eq tx-sender (unwrap-panic current-owner-opt))) err-unauthorized)
            (ok (map-set quest-ownership-map quest-id owner))
        )
    )
)

;; --- Internal DAO functions

(define-public (increment-quest-rewards-deposited (quest-id uint) (rewards uint))
	(begin
		(try! (is-dao-or-extension))
		(let ((current-rewards (unwrap! (get-quest-rewards-deposited quest-id) err-unauthorized)))
			(ok (map-set quest-rewards-deposited-map quest-id (+ current-rewards rewards)))
		)
	)
)

;; --- Public functions

(define-read-only (get-owner (quest-id uint))
	(ok (map-get? quest-ownership-map quest-id))
)

(define-read-only (get-quest-rewards-deposited (quest-id uint))
	(ok (default-to u0 (map-get? quest-rewards-deposited-map quest-id)))
)

;; --- Extension callback

(define-public (callback (sender principal) (memo (buff 34)))
	(ok true)
)

