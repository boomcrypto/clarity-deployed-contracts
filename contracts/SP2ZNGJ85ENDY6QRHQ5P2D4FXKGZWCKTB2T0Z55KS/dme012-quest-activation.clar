;; Title: DME012 Quest Activation
;; Author: rozar.btc
;; Depends-On: 
;; Synopsis: 
;; A smart contract for tracking the activation of quests.
;; Description:
;; This proposal defines state giving quests an start block in which they can not be completed before.

(impl-trait 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.extension-trait.extension-trait)

(define-constant err-unauthorized (err u3100))

(define-map quest-activation-map uint uint)

;; --- Authorization check

(define-public (is-dao-or-extension)
	(ok (asserts! (or (is-eq tx-sender 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.dungeon-master) (contract-call? 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.dungeon-master is-extension contract-caller)) err-unauthorized))
)

;; --- Internal DAO functions

(define-public (set-activation (quest-id uint) (block uint))
	(begin
		(try! (is-dao-or-extension))
	    (ok (map-set quest-activation-map quest-id block))
	)
)

;; --- Public functions

(define-read-only (get-activation (quest-id uint))
	(ok (default-to block-height (map-get? quest-activation-map quest-id)))
)

;; --- Extension callback

(define-public (callback (sender principal) (memo (buff 34)))
	(ok true)
)