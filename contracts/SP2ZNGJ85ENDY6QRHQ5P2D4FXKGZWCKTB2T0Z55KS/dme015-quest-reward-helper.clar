;; Title: DME015 Quest Reward Helper
;; Author: rozar.btc
;; Synopsis:
;; A utility contract to streamline and simplify the quest reward claiming process for users.
;; Description:
;; The Quest Reward Helper is an intuitive bridge that aids users in seamlessly claiming their rewards upon quest completion. 
;; This latest iteration adds support for quest activation and deactivation, as well as STX quest reward payouts.

(impl-trait 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.extension-trait.extension-trait)

(define-constant err-not-found (err u2001))
(define-constant err-not-completed (err u3101))
(define-constant err-rewards-locked (err u3102))
(define-constant err-expired (err u3103))
(define-constant err-unactivated (err u3104))

;; --- Authorization checks

(define-read-only (is-completed-and-unlocked (quest-id uint))
	(begin
		(asserts! (try! (contract-call? .dme006-quest-completion is-complete tx-sender quest-id)) err-not-completed)
		(asserts! (not (unwrap! (contract-call? .dme009-charisma-rewards is-locked tx-sender quest-id) err-not-found)) err-rewards-locked)
		(ok true)
	)
)

(define-read-only (is-activated-and-unexpired (quest-id uint))
	(begin
		(asserts! (>= (unwrap! (contract-call? .dme011-quest-expiration get-expiration quest-id) err-not-found) block-height) err-expired)
		(asserts! (<= (unwrap! (contract-call? .dme012-quest-activation get-activation quest-id) err-not-found) block-height) err-unactivated)
		(ok true)
	)
)

;; --- Public functions

(define-public (claim-quest-reward (quest-id uint))
    (begin
        ;; Check if the quest is completed, unlocked, activated, and hasn't expired
        (try! (is-completed-and-unlocked quest-id))
        (try! (is-activated-and-unexpired quest-id))

        ;; Extract and lock the quest rewards
        (let
            (
                (charisma-rewards (unwrap! (contract-call? .dme009-charisma-rewards get-rewards quest-id) err-not-found))
                (stx-rewards (unwrap! (contract-call? .dme014-stx-rewards get-rewards quest-id) err-not-found))
            )
            ;; Claim charisma rewards if they exist
            (if (> charisma-rewards u0)
                (try! (contract-call? .dme009-charisma-rewards claim quest-id))
                false
            )
            
            ;; Claim STX rewards if they exist
            (if (> stx-rewards u0)
                (try! (contract-call? .dme014-stx-rewards claim quest-id))
                false
            )
            
            ;; Lock the quest rewards
			(contract-call? .dme009-charisma-rewards set-locked tx-sender quest-id true)
        )
    )
)

;; --- Extension callback

(define-public (callback (sender principal) (memo (buff 34)))
	(ok true)
)