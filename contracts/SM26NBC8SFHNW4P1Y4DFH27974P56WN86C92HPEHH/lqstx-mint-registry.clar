
;; SPDX-License-Identifier: BUSL-1.1

;;
;; lqstx-mint-registry
;;

(use-trait sip-010-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)

(define-constant err-unauthorised (err u1000))
(define-constant err-unknown-request-id (err u1008))

(define-constant PENDING 0x00)
(define-constant FINALIZED 0x01)
(define-constant REVOKED 0x02)

(define-data-var mint-request-nonce uint u0)
(define-data-var burn-request-nonce uint u0)

(define-map mint-requests uint { requested-by: principal, amount: uint, requested-at: uint, status: (buff 1) })
(define-map burn-requests uint { requested-by: principal, amount: uint, wrapped-amount: uint, requested-at: uint, status: (buff 1) })

(define-map mint-requests-pending principal (list 1000 uint))
(define-map burn-requests-pending principal (list 1000 uint))

(define-data-var mint-requests-pending-amount uint u0)

;; read-only calls

(define-read-only (is-dao-or-extension)
	(ok (asserts! (or (is-eq tx-sender .lisa-dao) (contract-call? .lisa-dao is-extension contract-caller)) err-unauthorised)))
	
(define-read-only (get-mint-request-nonce)
	(var-get mint-request-nonce))

(define-read-only (get-burn-request-nonce)
	(var-get burn-request-nonce))

(define-read-only (get-mint-request-or-fail (request-id uint))
	(ok (unwrap! (map-get? mint-requests request-id) err-unknown-request-id)))

(define-read-only (get-burn-request-or-fail (request-id uint))
	(ok (unwrap! (map-get? burn-requests request-id) err-unknown-request-id)))	

(define-read-only (get-mint-requests-pending-or-default (user principal))
    (default-to (list ) (map-get? mint-requests-pending user)))

(define-read-only (get-burn-requests-pending-or-default (user principal))
    (default-to (list ) (map-get? burn-requests-pending user)))

(define-read-only (get-mint-requests-pending-amount)
    (var-get mint-requests-pending-amount))

;; governance calls

(define-public (set-mint-request (request-id uint) (details { requested-by: principal, amount: uint, requested-at: uint, status: (buff 1) }))
	(let
		(
			(next-nonce (+ (var-get mint-request-nonce) u1))
			(id (if (is-some (map-get? mint-requests request-id)) request-id (begin (var-set mint-request-nonce next-nonce) next-nonce)))
		)
		(try! (is-dao-or-extension))
		(map-set mint-requests id details)
		(ok id)))

(define-public (set-burn-request (request-id uint) (details { requested-by: principal, amount: uint, wrapped-amount: uint, requested-at: uint, status: (buff 1) }))
	(let
		(
			(next-nonce (+ (var-get burn-request-nonce) u1))
			(id (if (is-some (map-get? burn-requests request-id)) request-id (begin (var-set burn-request-nonce next-nonce) next-nonce)))
		)
		(try! (is-dao-or-extension))
		(map-set burn-requests id details)
		(ok id)))	

(define-public (set-mint-requests-pending (requested-by principal) (new-list (list 1000 uint)))
	(begin 
		(try! (is-dao-or-extension))
		(ok (map-set mint-requests-pending requested-by new-list))))

(define-public (set-burn-requests-pending (requested-by principal) (new-list (list 1000 uint)))
	(begin 
		(try! (is-dao-or-extension))
		(ok (map-set burn-requests-pending requested-by new-list))))

(define-public (set-mint-requests-pending-amount (new-amount uint))
	(begin 
		(try! (is-dao-or-extension))
		(ok (var-set mint-requests-pending-amount new-amount))))

(define-public (transfer (amount uint) (recipient principal) (token-trait <sip-010-trait>))
    (begin 
        (try! (is-dao-or-extension))
        (as-contract (contract-call? token-trait transfer amount tx-sender recipient none))))

(define-public (stx-transfer (amount uint) (recipient principal))
	(begin 
		(try! (is-dao-or-extension))
		(as-contract (stx-transfer? amount tx-sender recipient))))