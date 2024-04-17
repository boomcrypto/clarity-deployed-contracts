;; Title: DME020 Liquid Staked Welshcorgicoin
;; Author: rozar.btc
;; Synopsis:
;; This contract implements a liquid staking solution for Welshcorgicoin.
;; It provides users with liquid tokens (lsWELSH) that represent staked Welshcorgicoin. 
;; This allows users to retain liquidity while participating in staking.
;; Description:
;; The Liquid Staked Welshcorgicoin contract allows Welshcorgicoin holders to
;; stake their coins in exchange for an equivalent amount of liquid-staked-welsh tokens, 
;; which can be used within the ecosystem without sacrificing their staking benefits. 
;; The contract supports essential token management functions such as minting, burning, 
;; and transferring liquid tokens, alongside administrative functions 
;; controlled by the Dungeon Master DAO or an authorized extension.

(impl-trait 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.sip010-ft-trait.sip010-ft-trait)
(impl-trait 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.extension-trait.extension-trait)

(define-constant err-unauthorized (err u3000))
(define-constant err-not-token-owner (err u4))

(define-fungible-token liquid-staked-welsh)

(define-data-var token-name (string-ascii 32) "Liquid Staked Welshcorgicoin")
(define-data-var token-symbol (string-ascii 10) "lsWELSH")
(define-data-var token-uri (optional (string-utf8 256)) (some u"https://charisma.rocks/liquid-staked-welshcorgicoin.json"))
(define-data-var token-decimals uint u6)

;; --- Authorization check

(define-public (is-dao-or-extension)
	(ok (asserts! (or (is-eq tx-sender 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.dungeon-master) (contract-call? 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.dungeon-master is-extension contract-caller)) err-unauthorized))
)

;; --- Internal DAO functions

(define-public (mint (amount uint) (recipient principal))
	(begin
		(try! (is-dao-or-extension))
		(ft-mint? liquid-staked-welsh amount recipient)
	)
)

(define-public (burn (amount uint) (owner principal))
	(begin
		(try! (is-dao-or-extension))
		(ft-burn? liquid-staked-welsh amount owner)
	)
)

(define-public (set-name (new-name (string-ascii 32)))
	(begin
		(try! (is-dao-or-extension))
		(ok (var-set token-name new-name))
	)
)

(define-public (set-symbol (new-symbol (string-ascii 10)))
	(begin
		(try! (is-dao-or-extension))
		(ok (var-set token-symbol new-symbol))
	)
)

(define-public (set-decimals (new-decimals uint))
	(begin
		(try! (is-dao-or-extension))
		(ok (var-set token-decimals new-decimals))
	)
)

(define-public (set-token-uri (new-uri (optional (string-utf8 256))))
	(begin
		(try! (is-dao-or-extension))
		(ok (var-set token-uri new-uri))
	)
)

;; --- Public functions

(define-public (transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
	(begin
		(asserts! (or (is-eq tx-sender sender) (is-eq contract-caller sender)) err-not-token-owner)
		(ft-transfer? liquid-staked-welsh amount sender recipient)
	)
)

(define-read-only (get-name)
	(ok (var-get token-name))
)

(define-read-only (get-symbol)
	(ok (var-get token-symbol))
)

(define-read-only (get-decimals)
	(ok (var-get token-decimals))
)

(define-read-only (get-balance (who principal))
	(ok (ft-get-balance liquid-staked-welsh who))
)

(define-read-only (get-total-supply)
	(ok (ft-get-supply liquid-staked-welsh))
)

(define-read-only (get-token-uri)
	(ok (var-get token-uri))
)

(define-read-only (get-percentage-balance (who principal) (factor uint))
	(ok (>= (* (unwrap-panic (get-balance who)) factor) (* (unwrap-panic (get-total-supply)) u1000)))
)

;; --- Extension callback

(define-public (callback (sender principal) (memo (buff 34)))
	(ok true)
)
