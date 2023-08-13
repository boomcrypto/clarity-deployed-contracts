;; Title: DME006 Quest Completion
;; Author: rozar.btc
;; Depends-On: 
;; Synopsis: 
;; A smart contract for tracking the completion status of quests for given addresses.
;; Description:
;; This contract serves as a foundational layer to integrate with a larger system or platform 
;; where quests or challenges are part of the user experience. 
;; Whether it's a game, a learning platform, or any other interactive system, 
;; the contract ensures that quest completions are verifiably stored and easily accessible.

(impl-trait 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.extension-trait.extension-trait)

(define-constant err-not-found (err u2001))
(define-constant err-unauthorized (err u3100))

(define-map quest-completion-map
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

(define-public (set-complete (address principal) (quest-id uint) (state bool))
	(begin
		(try! (is-dao-or-extension))
	    (ok (map-set quest-completion-map { address: address, quest-id: quest-id } state ))
	)
)

;; --- Public functions

(define-read-only (is-complete (address principal) (quest-id uint))
	(ok (unwrap! (map-get? quest-completion-map { address: address, quest-id: quest-id } ) err-not-found))
)

;; --- Extension callback

(define-public (callback (sender principal) (memo (buff 34)))
	(ok true)
)