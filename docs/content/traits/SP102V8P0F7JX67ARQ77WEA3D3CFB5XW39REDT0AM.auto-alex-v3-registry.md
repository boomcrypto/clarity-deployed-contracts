---
title: "Trait auto-alex-v3-registry"
draft: true
---
```
(define-constant err-unauthorised (err u1000))
(define-constant err-request-id-not-found (err u10019))
(define-constant PENDING 0x00)
(define-constant FINALIZED 0x01)
(define-constant REVOKED 0x02)
(define-data-var start-cycle uint u340282366920938463463374607431768211455)
(define-data-var redeem-request-nonce uint u0)
(define-map staked-cycle uint bool)
(define-map redeem-requests uint { requested-by: principal, amount: uint, redeem-cycle: uint, status: (buff 1) })
(define-map redeem-shares-per-cycle uint uint)
(define-map shares-to-token-per-cycle uint uint)
(define-read-only (is-dao-or-extension)
	(ok (asserts! (or (is-eq tx-sender 'SM26NBC8SFHNW4P1Y4DFH27974P56WN86C92HPEHH.lisa-dao) (contract-call? 'SM26NBC8SFHNW4P1Y4DFH27974P56WN86C92HPEHH.lisa-dao is-extension contract-caller)) err-unauthorised)))
(define-read-only (get-start-cycle)
  (var-get start-cycle))
(define-read-only (is-cycle-staked (reward-cycle uint))
  (is-some (map-get? staked-cycle reward-cycle)))
(define-read-only (get-shares-to-tokens-per-cycle-or-default (reward-cycle uint))
  (default-to u0 (map-get? shares-to-token-per-cycle reward-cycle)))
(define-read-only (get-redeem-shares-per-cycle-or-default (reward-cycle uint))
  (default-to u0 (map-get? redeem-shares-per-cycle reward-cycle)))
(define-read-only (get-redeem-request-or-fail (request-id uint))
  (ok (unwrap! (map-get? redeem-requests request-id) err-request-id-not-found)))
(define-public (set-start-cycle (new-start-cycle uint))
  (begin 
    (try! (is-dao-or-extension))
    (map-set staked-cycle new-start-cycle true)
    (ok (var-set start-cycle new-start-cycle))))
(define-public (set-staked-cycle (cycle uint) (staked bool))
  (begin 
    (try! (is-dao-or-extension))
    (ok (map-set staked-cycle cycle staked))))
(define-public (set-shares-to-tokens-per-cycle (cycle uint) (shares-to-tokens uint))
  (begin 
    (try! (is-dao-or-extension))
    (ok (map-set shares-to-token-per-cycle cycle shares-to-tokens))))
(define-public (set-redeem-request (request-id uint) (request-details { requested-by: principal, amount: uint, redeem-cycle: uint, status: (buff 1) }))
  (let (
      (next-nonce (+ (var-get redeem-request-nonce) u1))
      (id (if (> request-id u0) request-id (begin (var-set redeem-request-nonce next-nonce) next-nonce))))
    (try! (is-dao-or-extension))
    (map-set redeem-requests id request-details)
    (ok id)))
(define-public (set-redeem-shares-per-cycle (reward-cycle uint) (shares uint))
  (begin 
    (try! (is-dao-or-extension))
    (ok (map-set redeem-shares-per-cycle reward-cycle shares))))
```
