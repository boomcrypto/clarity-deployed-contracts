;; Title: DME011 Quest Expiration
;; Author: rozar.btc
;; Depends-On: 
;; Synopsis: 
;; A smart contract for tracking the expiration of quests.
;; Description:
;; This proposal defines state giving quests an end block in which they can not be completed after.

(impl-trait 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.extension-trait.extension-trait)

(define-constant err-unauthorized (err u3100))

(define-map quest-expiration-map uint uint)

;; --- Authorization check

(define-public (is-dao-or-extension)
	(ok (asserts! (or (is-eq tx-sender 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.dungeon-master) (contract-call? 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.dungeon-master is-extension contract-caller)) err-unauthorized))
)

;; --- Internal DAO functions

(define-public (set-expiration (quest-id uint) (block uint))
	(begin
		(try! (is-dao-or-extension))
	    (ok (map-set quest-expiration-map quest-id block))
	)
)

;; --- Public functions

(define-read-only (get-expiration (quest-id uint))
	(ok (default-to block-height (map-get? quest-expiration-map quest-id)))
)

;; --- Extension callback

(define-public (callback (sender principal) (memo (buff 34)))
	(ok true)
)