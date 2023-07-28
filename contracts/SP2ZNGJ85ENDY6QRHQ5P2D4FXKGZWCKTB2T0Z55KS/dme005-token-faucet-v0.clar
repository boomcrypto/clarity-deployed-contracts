;; Title: DME005 Token Faucet
;; Author: Ross Ragsdale
;; Depends-On: 
;; Synopsis:
;; This contract provides a token faucet functionality for DME (Dungeon Master Extension) tokens. 
;; Users can claim tokens at a specified drip rate. The contract ensures a user can only claim tokens 
;; if sufficient balance is available, and tracks the total amount of tokens issued.
;; Description:
;; This Clarity smart contract implements a token faucet for the Charisma token. 
;; It allows the DAO or extensions to set the amount of tokens (drip amount) to be issued per block. 
;; The faucet tracks the last claim and the total amount of tokens issued to prevent abuse and maintain transparency.
;; There are public functions that allow users to claim tokens, provided that tokens are available. 
;; The amount of tokens available is determined by the product of the set drip amount and the number of blocks since the last claim. 
;; If there are enough tokens available, the user's claim is processed, the last claim block height is updated, 
;; and the total amount of tokens issued is incremented by the number of tokens claimed.
;; There are read-only functions that allow users to check the current drip amount and the block height of the last claim.
;; The contract ensures that only the DAO or authorized extensions can adjust the drip amount, 
;; providing a level of security and control over the token issuance process. 
;; Unauthorized attempts to change the drip amount will result in an error.

(impl-trait 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.extension-trait.extension-trait)

(define-constant err-unauthorized (err u3100))
(define-constant err-insufficient-balance (err u3102))

(define-data-var drip-amount uint u1)
(define-data-var last-claim uint block-height)
(define-data-var total-issued uint u0)

;; --- Authorization check

(define-public (is-dao-or-extension)
	(ok (asserts! (or (is-eq tx-sender 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.dungeon-master) (contract-call? 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.dungeon-master is-extension contract-caller)) err-unauthorized))
)

;; --- Internal DAO functions

(define-public (set-drip-amount (amount uint))
	(begin
		(try! (is-dao-or-extension))
		(ok (var-set drip-amount amount))
	)
)

;; --- Public functions

(define-public (claim)
	(let
		(
			(sender tx-sender)
            (tokens-available (* (var-get drip-amount) (- block-height (var-get last-claim))))
		)
        (asserts! (> tokens-available u0) err-insufficient-balance)
        (var-set last-claim block-height)
        (var-set total-issued (+ (var-get total-issued) tokens-available))		
        (as-contract (contract-call? 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.dme000-governance-token dmg-mint tokens-available sender))
	)
)

(define-read-only (get-drip-amount)
	(ok (var-get drip-amount))
)

(define-read-only (get-last-claim)
	(ok (var-get last-claim))
)

;; --- Extension callback

(define-public (callback (sender principal) (memo (buff 34)))
	(ok true)
)