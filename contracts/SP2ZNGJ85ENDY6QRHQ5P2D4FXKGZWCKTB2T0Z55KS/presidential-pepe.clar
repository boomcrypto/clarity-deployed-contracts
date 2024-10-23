;; Title: Presidential Pepe
;; Author: SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS
;; Created With Charisma
;; Description:
;; An index token composed of sPEPE and sCHA at a fixed 10k:1 ratio.

(impl-trait 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.dao-traits-v2.sip010-ft-trait)
(impl-trait 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.dao-traits-v2.extension-trait)

(define-constant err-unauthorized (err u3000))
(define-constant err-not-token-owner (err u4))

(define-constant contract (as-contract tx-sender))
(define-constant unlock-block u157890)
(define-constant token-a-ratio u10000)
(define-constant token-b-ratio u1)
(define-constant index-token-ratio u1)

(define-fungible-token index-token)

(define-data-var token-name (string-ascii 32) "Presidential Pepe")
(define-data-var token-symbol (string-ascii 10) "iPP")
(define-data-var token-uri (optional (string-utf8 256)) (some u"https://charisma.rocks/api/metadata/SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.presidential-pepe.json"))
(define-data-var token-decimals uint u6)

(define-data-var blocks-per-tx uint u5)
(define-data-var block-counter uint u0)

;; --- Authorization check

(define-read-only (is-dao-or-extension)
	(ok (asserts! (or (is-eq tx-sender 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.dungeon-master) (contract-call? 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.dungeon-master is-extension contract-caller)) err-unauthorized))
)

(define-read-only (is-unlocked)
	(ok (asserts! (>= block-height (+ unlock-block (var-get block-counter))) err-unauthorized))
)

;; --- Internal DAO functions

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

(define-public (set-blocks-per-tx (new-blocks-per-tx uint))
	(begin
		(try! (is-dao-or-extension))
		(ok (var-set blocks-per-tx new-blocks-per-tx))
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
					token-class: "ft",
					contract-id: contract
				}
			})
		)
	)
)

;; --- Index token functions

(define-public (add-liquidity (amount uint))
    (let
        (
            (amount-a (* amount token-a-ratio))
            (amount-b (* amount token-b-ratio))
            (amount-index (* amount index-token-ratio))
        )
        (try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.liquid-staked-pepe transfer amount-a tx-sender contract none))
        (try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.liquid-staked-charisma transfer amount-b tx-sender contract none))
        (try! (ft-mint? index-token amount-index tx-sender))
        (var-set block-counter (+ (var-get block-counter) (var-get blocks-per-tx)))
        (ok true)
    )
)

(define-public (remove-liquidity (amount uint))
    (let
        (
            (sender tx-sender)
            (amount-a (* amount token-a-ratio))
            (amount-b (* amount token-b-ratio))
            (amount-index (* amount index-token-ratio))
        )
        (try! (is-unlocked))
        (try! (ft-burn? index-token amount-index tx-sender))
        (try! (as-contract (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.liquid-staked-pepe transfer amount-a contract sender none)))
        (try! (as-contract (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.liquid-staked-charisma transfer amount-b contract sender none)))
        (var-set block-counter (+ (var-get block-counter) (var-get blocks-per-tx)))
        (ok true)
    )
)
    
(define-read-only (get-token-a-ratio)
    (ok token-a-ratio)
)

(define-read-only (get-token-b-ratio)
    (ok token-b-ratio)
)

(define-read-only (get-index-token-ratio)
    (ok index-token-ratio)
)

(define-read-only (get-blocks-per-tx)
	(ok (var-get blocks-per-tx))
)

(define-read-only (get-block-counter)
	(ok (var-get block-counter))
)

(define-read-only (get-txs-available)
    (begin
        (asserts! (>= block-height (+ unlock-block (var-get block-counter))) (ok u0))
        (ok (/ (- block-height (+ unlock-block (var-get block-counter))) (var-get blocks-per-tx)))
    )
)

(define-read-only (get-blocks-until-unlock)
    (begin
        (asserts! (< block-height (+ unlock-block (var-get block-counter))) (ok u0))
	    (ok (- (+ unlock-block (var-get block-counter)) block-height))
    )
)

;; --- SIP-010 FT Trait

(define-public (transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
	(begin
		(asserts! (or (is-eq tx-sender sender) (is-eq contract-caller sender)) err-not-token-owner)
		(ft-transfer? index-token amount sender recipient)
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
	(ok (ft-get-balance index-token who))
)

(define-read-only (get-total-supply)
	(ok (ft-get-supply index-token))
)

(define-read-only (get-token-uri)
	(ok (var-get token-uri))
)

;; --- Utility functions

(define-public (send-many (recipients (list 200 { to: principal, amount: uint, memo: (optional (buff 34)) })))
  (fold check-err (map send-token recipients) (ok true))
)

(define-private (check-err (result (response bool uint)) (prior (response bool uint)))
  (match prior ok-value result err-value (err err-value))
)

(define-private (send-token (recipient { to: principal, amount: uint, memo: (optional (buff 34)) }))
  (send-token-with-memo (get amount recipient) (get to recipient) (get memo recipient))
)

(define-private (send-token-with-memo (amount uint) (to principal) (memo (optional (buff 34))))
  (let ((transferOk (try! (transfer amount tx-sender to memo))))
    (ok transferOk)
  )
)

;; --- Extension callback

(define-public (callback (sender principal) (memo (buff 34)))
	(ok true)
)