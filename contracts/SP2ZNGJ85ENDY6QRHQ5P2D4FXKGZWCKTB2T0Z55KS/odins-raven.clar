;; Title: Odin's Raven
;; Author: rozar.btc
;; 
;; Odin's raven, often depicted as a pair named Huginn and Muninn, which translate to "thought" and "memory" respectively, 
;; are more than mere birds in Norse mythology. These ravens are extensions of Odin himself, serving as his eyes and ears across the Nine Worlds. 
;; Each morning, they are dispatched from Odin's shoulders to fly throughout the realms, gathering news and secrets from the earth below. 
;; By evening, they return to whisper all they have seen and heard directly into Odin's ear.
;;
;; These creatures are not only symbols of the god's intellectual and psychic powers but also embody the deep connection Odin maintains 
;; with his realm and its inhabitants. They are portrayed as sleek and black, mirroring the enigmatic and wise nature of their master. 
;; The ravens' daily flights underscore their crucial role in keeping Odin well-informed and several steps ahead of his adversaries, 
;; reinforcing his stature as the god of wisdom and knowledge.

(impl-trait .dao-traits-v2.extension-trait)
(impl-trait .dao-traits-v2.nft-trait)

(use-trait sip010-ft-trait .dao-traits-v2.sip010-ft-trait)

(define-constant err-unauthorized (err u3000))
(define-constant err-not-token-owner (err u4))
(define-constant err-balance-not-found (err u404))
(define-constant err-need-more-tokens (err u3103))
(define-constant err-messy-recipe (err u4024))

(define-constant ONE_6 (pow u10 u6)) ;; 6 decimal places

(define-constant contract (as-contract tx-sender))

(define-non-fungible-token raven uint)

(define-data-var token-uri (string-ascii 80) "https://charisma.rocks/odins-raven/json/")
(define-data-var required-token-to-mint principal .fenrir-corgi-of-ragnarok)
(define-data-var required-token-balance uint u10000000000)
(define-data-var metadata-frozen bool false)
(define-data-var mint-limit uint u100)
(define-data-var last-id uint u1)

;; --- Authorization check

(define-read-only (is-dao-or-extension)
	(ok (asserts! (or (is-eq tx-sender 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.dungeon-master) (contract-call? 'SP2D5BGGJ956A635JG7CJQ59FTRFRB0893514EZPJ.dungeon-master is-extension contract-caller)) err-unauthorized))
)

;; --- Requirements

(define-public (set-required-token-to-mint (new-required-token-to-mint <sip010-ft-trait>))
	(begin
		(try! (is-dao-or-extension))
		(ok (var-set required-token-to-mint (contract-of new-required-token-to-mint)))
	)
)

(define-read-only (get-required-token-to-mint)
	(ok (var-get required-token-to-mint))
)

(define-public (set-required-token-balance (new-required-token-balance uint))
	(begin
		(try! (is-dao-or-extension))
		(ok (var-set required-token-balance new-required-token-balance))
	)
)

(define-read-only (get-required-token-balance)
	(ok (var-get required-token-balance))
)

;; --- NFT Traits

(define-public (set-token-uri (new-uri (string-ascii 80)))
	(begin
		(try! (is-dao-or-extension))
		(asserts! (not (var-get metadata-frozen)) err-unauthorized)
		(var-set token-uri new-uri)
		(ok 
			(print {
				notification: "token-metadata-update",
				payload: {
					token-class: "nft",
					contract-id: contract
				}
			})
		)
	)
)

(define-read-only (get-last-token-id)
  	(ok (- (var-get last-id) u1))
)

(define-read-only (get-token-uri (token-id uint))
  	(ok (some (concat (concat (var-get token-uri) "{id}") ".json")))
)

(define-read-only (get-owner (id uint))
    (ok (nft-get-owner? raven id))
)

(define-public (transfer (id uint) (sender principal) (recipient principal))
    (begin
        (asserts! (or (is-eq tx-sender sender) (is-eq contract-caller sender)) err-not-token-owner)
        (nft-transfer? raven id sender recipient)
    )
)

(define-public (mint (required-token <sip010-ft-trait>))
	(let (
    (last-nft-id (var-get last-id))
		(assigned-required-token (var-get required-token-to-mint))
		(required-balance (* (var-get required-token-balance) last-nft-id))
	)
    (asserts! (<= last-nft-id (var-get mint-limit)) err-unauthorized)
    (asserts! (is-eq (contract-of required-token) assigned-required-token) err-messy-recipe)
    (asserts! (>= (unwrap-panic (contract-call? required-token get-balance tx-sender)) required-balance) err-need-more-tokens)
    (var-set last-id (+ last-nft-id u1))
    (nft-mint? raven last-nft-id tx-sender)
	)
)

(define-private (is-owner (id uint) (user principal))
    (is-eq user (unwrap! (nft-get-owner? raven id) false))
)

(define-public (burn (id uint))
  	(begin 
    	(asserts! (is-owner id tx-sender) err-not-token-owner)
    	(nft-burn? raven id tx-sender)
	)
)

(define-public (freeze-metadata)
	(begin
		(try! (is-dao-or-extension))
		(var-set metadata-frozen true)
		(ok true)
	)
)

;; --- Extension callback

(define-public (callback (sender principal) (memo (buff 34)))
	(ok true)
)

;; --- Init

(print {
	notification: "token-metadata-update",
	payload: {
		token-class: "nft",
		contract-id: contract
	}
})