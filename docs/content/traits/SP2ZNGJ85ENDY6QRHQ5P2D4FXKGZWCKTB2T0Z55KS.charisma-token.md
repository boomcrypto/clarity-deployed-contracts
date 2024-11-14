---
title: "Trait charisma-token"
draft: true
---
```
;; The Charisma Token
;; https://charisma.rocks

(impl-trait .dao-traits-v4.sip010-ft-trait)

(define-constant err-unauthorized (err u401))
(define-constant err-liquidity-lock (err u402))
(define-constant err-not-red-pilled (err u403))
(define-constant err-not-token-owner (err u404))
(define-constant err-invalid-input (err u405))

(define-constant contract (as-contract tx-sender))
(define-constant unlock-block block-height)

(define-fungible-token charisma)

(define-data-var token-name (string-ascii 32) "Charisma")
(define-data-var token-symbol (string-ascii 10) "CHA")
(define-data-var token-uri (optional (string-utf8 256)) (some u"https://charisma.rocks/api/metadata/SP2ZNGJ85ENDY6QRHQ5P2D4FXKGZWCKTB2T0Z55KS.charisma-token.json"))
(define-data-var token-decimals uint u6)

(define-data-var block-counter uint u0)

(define-data-var blocks-per-tx uint u1)
(define-constant min-blocks-per-tx u1)
(define-constant max-blocks-per-tx u100000)

(define-data-var max-liquidity-flow uint (* u1000000 u100)) ;; 100 tokens 
(define-constant min-max-liquidity-flow (* u1000000 u1)) ;; 1 token
(define-constant max-max-liquidity-flow (* u1000000 u1000)) ;; 10k tokens

;; --- Authorization checks

(define-read-only (is-dao-or-extension)
    (or (is-eq tx-sender 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.dungeon-master) (contract-call? 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.dungeon-master is-extension contract-caller))
)

(define-read-only (is-authorized)
	(ok (asserts! (is-dao-or-extension) err-unauthorized))
)

(define-read-only (is-red-pilled)
    (ok (asserts! (contract-call? .red-pill-nft has-balance tx-sender) err-not-red-pilled))
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
        (asserts! (and (>= new-blocks-per-tx min-blocks-per-tx) (<= new-blocks-per-tx max-blocks-per-tx)) err-invalid-input)
        (ok (var-set blocks-per-tx new-blocks-per-tx))
    )
)

(define-public (set-max-liquidity-flow (new-max-liquidity-flow uint))
	(begin
		(try! (is-authorized))
        (asserts! (and (>= new-max-liquidity-flow min-max-liquidity-flow) (<= new-max-liquidity-flow max-max-liquidity-flow)) err-invalid-input)
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

(define-public (wrap (amount uint))
    (let
        (
            (sender tx-sender)
            (red-pilled (try! (is-red-pilled)))
            (max-amount (var-get max-liquidity-flow))
            (amount-in (if (> amount max-amount) max-amount amount))
        )
        (try! (is-unlocked))
        (var-set block-counter (+ (var-get block-counter) (var-get blocks-per-tx)))
        (try! (contract-call? 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.dme000-governance-token transfer amount-in sender contract none))
        (try! (ft-mint? charisma amount-in sender))
        (ok {
            block-counter: (var-get block-counter),
            max-liquidity-flow: max-amount,
            token-amount: amount-in
        })
    )
)

(define-public (unwrap (amount uint))
    (let
        (
            (sender tx-sender)
            (red-pilled (try! (is-red-pilled)))
            (max-amount (var-get max-liquidity-flow))
            (amount-out (if (and (not red-pilled) (> amount max-amount)) max-amount amount))
        )
        (try! (is-unlocked))
        (var-set block-counter (+ (var-get block-counter) (var-get blocks-per-tx)))
        (try! (ft-burn? charisma amount-out tx-sender))
        (try! (as-contract (contract-call? 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.dme000-governance-token transfer amount-out contract sender none)))
        (ok {
            block-counter: (var-get block-counter),
            max-liquidity-flow: max-amount,
            token-amount: amount-out
        })
    )
)

(define-public (burn (amount uint))
  (ft-burn? charisma amount tx-sender)
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

(define-read-only (get-max-liquidity-flow)
	(ok (var-get max-liquidity-flow))
)

;; --- SIP-010 FT Trait

(define-public (transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
	(begin
		(asserts! (or (is-eq tx-sender sender) (is-eq contract-caller sender)) err-not-token-owner)
		(ft-transfer? charisma amount sender recipient)
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
	(ok (ft-get-balance charisma who))
)

(define-read-only (get-total-supply)
	(ok (ft-get-supply charisma))
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
```
