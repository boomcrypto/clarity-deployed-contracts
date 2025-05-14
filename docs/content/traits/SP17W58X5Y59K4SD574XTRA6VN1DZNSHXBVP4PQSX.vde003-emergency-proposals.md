---
title: "Trait vde003-emergency-proposals"
draft: true
---
```

(impl-trait .extension-trait.extension-trait)
(use-trait proposal-trait .proposal-trait.proposal-trait)

(define-data-var emergency-proposal-duration uint u144) ;; ~1 day
(define-data-var emergency-team-sunset-height uint (+ burn-block-height u25920)) ;; ~6 months from deploy time

(define-constant err-unauthorised (err u4000))
(define-constant err-not-emergency-team-member (err u4001))
(define-constant err-sunset-height-reached (err u4002))
(define-constant err-sunset-height-in-past (err u4003))

(define-map emergency-team principal bool)

;; --- Authorisation check

(define-public (is-dao-or-extension)
	(ok (asserts! (or (is-eq tx-sender .vibeDAO) (contract-call? .vibeDAO is-extension contract-caller)) err-unauthorised))
)

;; --- Internal DAO functions

(define-public (set-emergency-proposal-duration (duration uint))
	(begin
		(try! (is-dao-or-extension))
		(ok (var-set emergency-proposal-duration duration))
	)
)

(define-public (set-emergency-team-sunset-height (height uint))
	(begin
		(try! (is-dao-or-extension))
		(asserts! (> height burn-block-height) err-sunset-height-in-past)
		(ok (var-set emergency-team-sunset-height height))
	)
)

(define-public (set-emergency-team-member (who principal) (member bool))
	(begin
		(try! (is-dao-or-extension))
		(ok (map-set emergency-team who member))
	)
)

;; --- Public functions

(define-read-only (is-emergency-team-member (who principal))
	(default-to false (map-get? emergency-team who))
)

(define-public (emergency-propose (proposal <proposal-trait>))
	(begin
		(asserts! (is-emergency-team-member tx-sender) err-not-emergency-team-member)
		(asserts! (< burn-block-height (var-get emergency-team-sunset-height)) err-sunset-height-reached)
		(contract-call? .vde001-proposal-voting add-proposal proposal
			{
				start-block-height: burn-block-height,
				end-block-height: (+ burn-block-height (var-get emergency-proposal-duration)),
				proposer: tx-sender
			}
		)
	)
)

;; --- Extension callback

(define-public (callback (sender principal) (memo (buff 34)))
	(ok true)
)
```
