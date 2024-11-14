---
title: "Trait blocklist"
draft: true
---
```
(impl-trait 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.extension-trait.extension-trait)
(impl-trait 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.proposal-trait.proposal-trait)

(define-constant ERR-NOT-AUTHORIZED (err u1000))

(define-map approved-updaters principal bool)

;; read-only calls

(define-read-only (is-dao-or-extension)
  (ok (asserts! (or (is-eq tx-sender 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.executor-dao) (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.executor-dao is-extension contract-caller)) ERR-NOT-AUTHORIZED)))

(define-read-only (get-approved-updater-or-default (updater principal))
	(default-to false (map-get? approved-updaters updater)))

(define-read-only (is-blocklisted-or-default (sender principal))
	(or (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-registry-v2-01 is-blocklisted-or-default sender) (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.alex-staking-v2 is-blocklisted-or-default sender)))

(define-read-only (is-blocklisted-or-default-many (senders (list 5000 principal)))
	(map is-blocklisted-or-default senders))

;; priviliged calls

(define-public (add-to-blocklist-many (blocked-many (list 500 principal)))
	(begin 
		(asserts! (or (is-ok (is-dao-or-extension)) (get-approved-updater-or-default tx-sender)) ERR-NOT-AUTHORIZED) 
		(ok (map add-to-blocklist blocked-many))))

;; governance calls

(define-public (remove-from-blocklist-many (blocked-many (list 500 principal)))
	(begin 
		(try! (is-dao-or-extension))
		(ok (map remove-from-blocklist blocked-many))))

(define-public (approve-updater (updater principal) (approved bool))
	(begin
		(try! (is-dao-or-extension))
		(ok (map-set approved-updaters updater approved))))

;; internal calls

(define-private (add-to-blocklist (blocked principal))
	(set-blocklist { sender: blocked, blocked: true }))

(define-private (remove-from-blocklist (blocked principal))
	(set-blocklist { sender: blocked, blocked: false }))

(define-private (set-blocklist (blocked { sender: principal, blocked: bool }))
	(begin
		(print { notification: "set-blocklist", payload: blocked }) 
		(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.alex-staking-v2 set-blocklist-many (list blocked)))
		(contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.amm-registry-v2-01 set-blocklist-many (list blocked))))

(define-public (callback (sender principal) (payload (buff 2048)))
	(ok true))

(define-public (execute (sender principal))
	(begin 
		(try! (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.executor-dao set-extensions (list { extension: .blocklist, enabled: true } )))
		(ok true)))

```
