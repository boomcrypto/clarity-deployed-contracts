;; Title: Liquid Staked Odin
;; Author: rozar.btc
;; Synopsis:
;; This contract implements a liquid staking solution for Odin.
;; It provides users with liquid tokens (sODIN) that represent staked Odin. 
;; This allows users to retain liquidity while participating in staking.

;; .odin-tkn
;; 

(impl-trait .dao-traits-v1.sip010-ft-trait)

(define-fungible-token liquid-staked-odin)

(define-constant err-unauthorized (err u3000))
(define-constant err-not-token-owner (err u4))

(define-constant ONE_6 (pow u10 u6)) ;; 6 decimal places

(define-constant contract (as-contract tx-sender))

(define-data-var token-name (string-ascii 32) "Liquid Staked Odin")
(define-data-var token-symbol (string-ascii 10) "sODIN")
(define-data-var token-uri (optional (string-utf8 256)) (some u"https://charisma.rocks/liquid-staked-odin.json"))
(define-data-var token-decimals uint u6)

;; --- Authorization check

(define-public (is-dao-or-extension)
	(ok (asserts! (or (is-eq tx-sender 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.dungeon-master) (contract-call? 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.dungeon-master is-extension contract-caller)) err-unauthorized))
)

;; --- Public functions

(define-public (stake (amount uint))
	(begin
		(let
			(
				(inverse-rate (get-inverse-rate))
				(amount-lso (/ (* amount inverse-rate) ONE_6))
				(sender tx-sender)
			)
			(try! (contract-call? 'SP2X2Z28NXZVJFCJPBR9Q3NBVYBK3GPX8PXA3R83C.odin-tkn transfer amount sender contract none))
			(try! (mint amount-lso sender))
		)
		(ok true)
	)
)

(define-public (unstake (amount uint))
	(begin
		(let
			(
				(exchange-rate (get-exchange-rate))
				(amount-odin (/ (* amount exchange-rate) ONE_6))
				(sender tx-sender)
			)
			(try! (burn amount sender))
			(try! (as-contract (contract-call? 'SP2X2Z28NXZVJFCJPBR9Q3NBVYBK3GPX8PXA3R83C.odin-tkn transfer amount-odin contract sender none)))
		)
		(ok true)
	)
)

(define-public (deposit (amount uint))
    (contract-call? 'SP2X2Z28NXZVJFCJPBR9Q3NBVYBK3GPX8PXA3R83C.odin-tkn transfer amount tx-sender contract none)
)

(define-public (deflate (amount uint))
    (burn amount tx-sender)
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
		(var-set token-uri new-uri)
		(ok 
			(print {
				notification: "token-metadata-update",
				payload: {
					contract-id: (as-contract tx-sender),
					token-class: "ft"
				}
			})
		)
	)
)

(define-public (transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
	(begin
		(asserts! (or (is-eq tx-sender sender) (is-eq contract-caller sender)) err-not-token-owner)
		(ft-transfer? liquid-staked-odin amount sender recipient)
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
	(ok (ft-get-balance liquid-staked-odin who))
)

(define-read-only (get-total-supply)
	(ok (ft-get-supply liquid-staked-odin))
)

(define-read-only (get-token-uri)
	(ok (var-get token-uri))
)

(define-read-only (get-total-odin-in-pool)
	(unwrap-panic (contract-call? 'SP2X2Z28NXZVJFCJPBR9Q3NBVYBK3GPX8PXA3R83C.odin-tkn get-balance contract))
)

(define-read-only (get-exchange-rate)
	(/ (* (get-total-odin-in-pool) ONE_6) (ft-get-supply liquid-staked-odin))
)

(define-read-only (get-inverse-rate)
	(/ (* (ft-get-supply liquid-staked-odin) ONE_6) (get-total-odin-in-pool))
)

;; --- Private functions

(define-private (mint (amount uint) (recipient principal))
    (ft-mint? liquid-staked-odin amount recipient)
)

(define-private (burn (amount uint) (owner principal))
    (ft-burn? liquid-staked-odin amount owner)
)

;; --- Init

(mint u1 contract)