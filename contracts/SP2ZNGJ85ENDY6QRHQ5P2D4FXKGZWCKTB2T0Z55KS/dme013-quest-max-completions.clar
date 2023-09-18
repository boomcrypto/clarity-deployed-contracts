;; Title: DME013 Quest Max Completions
;; Author: rozar.btc
;; Depends-On: 
;; Synopsis: 
;; A smart contract for tracking the max completions of quests.
;; Description:
;; This proposal defines state giving quests an set number of max completions after which no more users can complete the quest.

(impl-trait 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.extension-trait.extension-trait)

(define-constant err-unauthorized (err u3100))

(define-map quest-max-completions-map uint uint)

;; --- Authorization check

(define-public (is-dao-or-extension)
	(ok (asserts! (or (is-eq tx-sender 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.dungeon-master) (contract-call? 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.dungeon-master is-extension contract-caller)) err-unauthorized))
)

;; --- Internal DAO functions

(define-public (set-max-completions (quest-id uint) (max-completions uint))
	(begin
		(try! (is-dao-or-extension))
	    (ok (map-set quest-max-completions-map quest-id max-completions ))
	)
)

;; --- Public functions

(define-read-only (get-max-completions (quest-id uint))
	(ok (default-to u1000 (map-get? quest-max-completions-map quest-id)))
)

;; --- Extension callback

(define-public (callback (sender principal) (memo (buff 34)))
	(ok true)
)