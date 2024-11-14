;; Title: Leo Unchained
;; Author: SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS
;; Created With Charisma
;; https://charisma.rocks
;; Description:
;; An index token composed of sLEO and sCHA at a fixed 1k:1 ratio.

(impl-trait 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.dao-traits-v2.sip010-ft-trait)
(impl-trait 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.dao-traits-v2.extension-trait)

(define-constant err-unauthorized (err u401))
(define-constant err-liquidity-lock (err u402))
(define-constant err-forbidden (err u403))
(define-constant err-not-token-owner (err u4))

(define-constant contract (as-contract tx-sender))
(define-constant unlock-block u158580)
(define-constant token-a-ratio u1000)
(define-constant token-b-ratio u1)
(define-constant index-token-ratio u1)

(define-fungible-token index-token)

(define-data-var token-name (string-ascii 32) "Leo Unchained")
(define-data-var token-symbol (string-ascii 10) "iLU")
(define-data-var token-uri (optional (string-utf8 256)) (some u"https://charisma.rocks/api/metadata/SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.leo-unchained.json"))
(define-data-var token-decimals uint u6)

(define-data-var blocks-per-tx uint u80)
(define-data-var block-counter uint u0)

(define-data-var required-exp-percentage uint (/ u100000 u1)) ;; 1% of total supply
(define-data-var max-liquidity-flow uint (* u1000000 u1000)) ;; 1k tokens 

;; --- Authorization checks

(define-read-only (is-dao-or-extension)
    (or (is-eq tx-sender 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.dungeon-master) (contract-call? 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.dungeon-master is-extension contract-caller))
)

(define-read-only (has-required-experience (who principal))
    (unwrap-panic (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.experience has-percentage-balance who (var-get required-exp-percentage)))
)

(define-read-only (is-authorized)
	(ok (asserts! (is-dao-or-extension) err-unauthorized))
)

(define-read-only (is-privileged)
	(ok (asserts! (or (is-dao-or-extension) (has-required-experience tx-sender)) err-forbidden))
)

(define-read-only (is-unlocked)
	(ok (asserts! (>= block-height (+ unlock-block (var-get block-counter))) err-liquidity-lock))
)

;; --- Internal DAO functions

(define-public (set-name (new-name (string-ascii 32)))
	(begin
		(try! (is-authorized))
		(ok (var-set token-name new-name))
	)
)

(define-public (set-symbol (new-symbol (string-ascii 10)))
	(begin
		(try! (is-authorized))
		(ok (var-set token-symbol new-symbol))
	)
)

(define-public (set-decimals (new-decimals uint))
	(begin
		(try! (is-authorized))
		(ok (var-set token-decimals new-decimals))
	)
)

(define-public (set-blocks-per-tx (new-blocks-per-tx uint))
	(begin
		(try! (is-authorized))
		(ok (var-set blocks-per-tx new-blocks-per-tx))
	)
)

(define-public (set-required-exp-percentage (new-required-exp-percentage uint))
	(begin
		(try! (is-authorized))
		(ok (var-set required-exp-percentage new-required-exp-percentage))
	)
)

(define-public (set-max-liquidity-flow (new-max-liquidity-flow uint))
	(begin
		(try! (is-authorized))
		(ok (var-set max-liquidity-flow new-max-liquidity-flow))
	)
)

(define-public (set-token-uri (new-uri (optional (string-utf8 256))))
	(begin
		(try! (is-authorized))
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
            (privileged (try! (is-privileged)))
            (max-flow (var-get max-liquidity-flow))
            (amount-in (if (and (not privileged) (> amount max-flow)) max-flow amount))
            (amount-a (* amount-in token-a-ratio))
            (amount-b (* amount-in token-b-ratio))
            (amount-index (* amount-in index-token-ratio))
        )
        (if 
            privileged
            true
            (begin
                (try! (is-unlocked))
                (var-set block-counter (+ (var-get block-counter) (var-get blocks-per-tx)))
                false
            )
        )
        (try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.liquid-staked-leo transfer amount-a tx-sender contract none))
        (try! (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.liquid-staked-charisma transfer amount-b tx-sender contract none))
        (try! (ft-mint? index-token amount-index tx-sender))
        (ok {
            a: amount-a,
            b: amount-b,
            x: amount-index
        })
    )
)

(define-public (remove-liquidity (amount uint))
    (let
        (
            (sender tx-sender)
            (privileged (try! (is-privileged)))
            (max-flow (var-get max-liquidity-flow))
            (amount-in (if (and (not privileged) (> amount max-flow)) max-flow amount))
            (amount-a (* amount-in token-a-ratio))
            (amount-b (* amount-in token-b-ratio))
            (amount-index (* amount-in index-token-ratio))
        )
        (if 
            privileged
            true
            (begin
                (try! (is-unlocked))
                (var-set block-counter (+ (var-get block-counter) (var-get blocks-per-tx)))
                false
            )
        )
        (try! (ft-burn? index-token amount-index tx-sender))
        (try! (as-contract (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.liquid-staked-leo transfer amount-a contract sender none)))
        (try! (as-contract (contract-call? 'SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.liquid-staked-charisma transfer amount-b contract sender none)))
        (ok {
            a: amount-a,
            b: amount-b,
            x: amount-index
        })
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

(define-read-only (get-required-exp-percentage)
	(ok (var-get required-exp-percentage))
)

(define-read-only (get-max-liquidity-flow)
	(ok (var-get max-liquidity-flow))
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