---
title: "Trait treasury-grant-v3"
draft: true
---
```
;; treasury-grant-v3

(use-trait ft-trait 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.trait-sip-010.sip-010-trait)

(define-constant err-not-authorized (err u1000))
(define-constant err-invalid-amount (err u1001))
(define-constant err-treasury-grant-v2-not-paused (err u1002))
(define-constant err-paused (err u1003))

(define-constant ONE_8 u100000000)
(define-constant total-stx u1328392261866610)
(define-constant multiplier u10)

(define-map claimed uint { stx-claimed: uint, alex-returned: uint })
(define-data-var claim-base uint u0)
(define-data-var paused bool true)

;; read-only calls

(define-read-only (is-dao-or-extension)
  (ok (asserts! (or (is-eq tx-sender 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.executor-dao) (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.executor-dao is-extension contract-caller)) err-not-authorized)))

(define-read-only (get-claim-base)
	(var-get claim-base))

(define-read-only (get-claimed-details-or-default (token-id uint))
	(default-to { stx-claimed: u0, alex-returned: u0 } (map-get? claimed token-id)))

(define-read-only (get-claim-details-or-fail (token-id uint))
	(let (
			(stats (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.treasury-grant-v2 get-stats token-id)))
			(max-stx-claim (- (/ (div-down (mul-down (get-claim-base) (+ (get available stats) (get claimed stats))) total-stx) multiplier) (get stx-claimed (get-claimed-details-or-default token-id)))))
		(ok (merge stats { max-stx-claim: max-stx-claim }))))

(define-read-only (is-paused)
  (var-get paused))

;; governance calls

(define-public (add-to-claim-base (amount uint))
	(begin
		(asserts! (>= total-stx (+ (get-claim-base) amount)) err-invalid-amount)
		(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2 transfer-fixed amount tx-sender (as-contract tx-sender) none))
		(ok (var-set claim-base (+ (get-claim-base) amount)))))

(define-public (transfer-token (token-trait <ft-trait>) (amount uint) (recipient principal))
	(begin 
		(try! (is-dao-or-extension))
		(as-contract (contract-call? token-trait transfer-fixed amount tx-sender recipient none))))

(define-public (pause (new-paused bool))
  (begin
    (try! (is-dao-or-extension))
    (ok (var-set paused new-paused))))

(define-public (callback (sender principal) (payload (buff 2048)))
	(ok true))

(define-public (execute (sender principal))
	(begin
		(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.executor-dao set-extensions (list { extension: .treasury-grant-v3, enabled: true } )))
		(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.treasury-grant-v2 pause true))
		(try! (pause false))		
		(ok true)))

;; public calls

(define-public (claim-stx-v2 (token-id uint))
	(begin
		(asserts! (not (is-paused)) err-paused)
		(asserts! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.treasury-grant-v2 is-paused) err-treasury-grant-v2-not-paused)	
		(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.treasury-grant-v2 pause false))
		(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.treasury-grant-v2 claim-stx token-id))
		(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.treasury-grant-v2 pause true))
		(ok true)))

(define-public (claim-stx-v3 (token-id uint))
	(let (
			(sender tx-sender)
			(claimed-details (get-claimed-details-or-default token-id))
			(claim-details (try! (get-claim-details-or-fail token-id)))
			(alex-to-return (min (* (get max-stx-claim claim-details) multiplier) (- (get claimed claim-details) (get alex-returned claimed-details))))
			(updated-claimed { stx-claimed: (+ (get stx-claimed claimed-details) (get max-stx-claim claim-details)), alex-returned: (+ (get alex-returned claimed-details) alex-to-return) }))
		(asserts! (not (is-paused)) err-paused)
		(asserts! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.treasury-grant-v2 is-paused) err-treasury-grant-v2-not-paused)
		(asserts! (is-eq (some sender) (unwrap-panic (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.treasury-grant-v2 get-owner token-id))) err-not-authorized)

		(map-set claimed token-id updated-claimed)
		(and (> alex-to-return u0) (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex transfer-fixed alex-to-return sender (as-contract tx-sender) none)))
		(as-contract (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-wstx-v2 transfer-fixed (get max-stx-claim claim-details) tx-sender sender none)))
		
		(print { notification: "claim-stx", payload: { token-id: token-id, owner: sender, claimed: (get max-stx-claim claim-details), returned: alex-to-return } })
		(ok true)))

(define-public (claim-alex (token-id uint))
	(let (
			(sender tx-sender)
			(claimed-details (get-claimed-details-or-default token-id))
			(claim-details (try! (get-claim-details-or-fail token-id)))
			(alex-to-return (min (get available claim-details) (- (* (get stx-claimed claimed-details) multiplier) (get alex-returned claimed-details))))
			(updated-claimed (merge claimed-details { alex-returned: (+ (get alex-returned claimed-details) alex-to-return) })))
		(asserts! (not (is-paused)) err-paused)
		(asserts! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.treasury-grant-v2 is-paused) err-treasury-grant-v2-not-paused)
		(asserts! (is-eq (some sender) (unwrap-panic (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.treasury-grant-v2 get-owner token-id))) err-not-authorized)

		(map-set claimed token-id updated-claimed)		
		(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.treasury-grant-v2 pause false))
		(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.treasury-grant-v2 claim-alex token-id))
		(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.treasury-grant-v2 pause true))
		(and (> alex-to-return u0) (try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.token-alex transfer-fixed alex-to-return sender (as-contract tx-sender) none)))

		(print { notification: "claim-alex", payload: { token-id: token-id, owner: sender, claimed: (get available claim-details), returned: alex-to-return } })
		(ok true)))				

(define-public (claim-stx (token-id uint))
	(begin
		(try! (claim-stx-v2 token-id))
		(claim-stx-v3 token-id)))

(define-public (claim (token-id uint))
	(begin 
		(try! (claim-stx token-id))
		(claim-alex token-id)))

(define-public (claim-many (token-ids (list 1000 uint)))
  (ok (map claim token-ids)))

;; private calls

(define-private (mul-down (a uint) (b uint))
    (/ (* a b) ONE_8))

(define-private (div-down (a uint) (b uint))
  (if (is-eq a u0) u0 (/ (* a ONE_8) b)))

(define-private (min (a uint) (b uint))
    (if (<= a b) a b))

(define-private (max (a uint) (b uint))
    (if (>= a b) a b))

```
