
;; SPDX-License-Identifier: BUSL-1.1

(use-trait sip-010-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)

(define-constant err-unauthorised (err u1000))
(define-constant err-unknown-request-id (err u1008))

(define-constant PENDING 0x00)
(define-constant FINALIZED 0x01)
(define-constant REVOKED 0x02)

(define-data-var burn-request-nonce uint u0)
(define-map burn-requests uint { requested-by: principal, amount: uint, requested-at: uint, status: (buff 1) })

;; read-only calls

(define-read-only (is-dao-or-extension)
	(ok (asserts! (or (is-eq tx-sender 'SM26NBC8SFHNW4P1Y4DFH27974P56WN86C92HPEHH.lisa-dao) (contract-call? 'SM26NBC8SFHNW4P1Y4DFH27974P56WN86C92HPEHH.lisa-dao is-extension contract-caller)) err-unauthorised)))

(define-read-only (get-burn-request-nonce)
	(var-get burn-request-nonce))

(define-read-only (get-burn-request-or-fail (request-id uint))
	(ok (unwrap! (map-get? burn-requests request-id) err-unknown-request-id)))

;; governance calls

(define-public (set-burn-request (request-id uint) (details { requested-by: principal, amount: uint, requested-at: uint, status: (buff 1) }))
	(let (
			(next-nonce (+ (var-get burn-request-nonce) u1))
			(id (if (is-some (map-get? burn-requests request-id)) request-id (begin (var-set burn-request-nonce next-nonce) next-nonce))))
		(try! (is-dao-or-extension))
		(map-set burn-requests id details)
		(ok id)))

(define-public (transfer (amount uint) (recipient principal) (token-trait <sip-010-trait>))
    (begin
        (try! (is-dao-or-extension))
        (as-contract (contract-call? token-trait transfer amount tx-sender recipient none))))
