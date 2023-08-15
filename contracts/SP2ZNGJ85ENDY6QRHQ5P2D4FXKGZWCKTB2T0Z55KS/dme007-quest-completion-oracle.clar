;; Title: DME007 Quest Completion Oracle
;; Author: rozar.btc
;; Depends-On: DME000, DME006
;; Synopsis:
;; An authoritative contract designed for verifying quest completion statuses through a centralized oracle mechanism.
;; Description:
;; This contract operates within the Charisma platform to validate quest completions. 
;; Using a designated Stacks address as a centralized oracle, the contract authorizes both the DAO and the oracle to validate or alter quest statuses. 
;; This approach provides a balance between decentralized blockchain capabilities and a trusted validation system.

(impl-trait 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.extension-trait.extension-trait)

(define-constant err-unauthorized (err u3000))

(define-data-var oracle principal 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM) ;; centralized oracle Stacks address

;; --- Authorization check

(define-public (is-dao-or-extension)
	(ok (asserts! (or (is-eq tx-sender 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.dungeon-master) (contract-call? 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.dungeon-master is-extension contract-caller)) err-unauthorized))
)

(define-public (is-oracle)
	(ok (asserts! (is-eq tx-sender (var-get oracle)) err-unauthorized))
)

;; --- Oracle functions

(define-public (set-complete (address principal) (quest-id uint) (state bool))
	(begin
		(try! (is-oracle))
	    (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.dme006-quest-completion set-complete address quest-id state)
	)
)

;; --- Internal DAO functions

(define-public (set-oracle (address principal))
	(begin
		(try! (is-dao-or-extension))
	    (ok (var-set oracle address))
	)
)

;; --- Public functions

(define-read-only (get-oracle)
	(ok (var-get oracle))
)

;; --- Extension callback

(define-public (callback (sender principal) (memo (buff 34)))
	(ok true)
)