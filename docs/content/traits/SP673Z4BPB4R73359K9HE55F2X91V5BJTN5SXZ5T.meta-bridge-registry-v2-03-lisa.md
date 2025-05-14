---
title: "Trait meta-bridge-registry-v2-03-lisa"
draft: true
---
```
(define-constant err-unauthorised (err u1000))
(define-constant err-invalid-request (err u1001))

(define-map burn-requests { pay: (buff 128), inscribe: (buff 128), token: principal, request-id: uint } (buff 1))
(define-map inscribe-request-ids (buff 128) (list 2000 uint))

;; read-only calls

(define-read-only (is-dao-or-extension)
	(ok (asserts! (or (is-eq tx-sender 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.executor-dao) (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.executor-dao is-extension contract-caller)) err-unauthorised)))

(define-read-only (get-burn-request-or-fail (key { pay: (buff 128), inscribe: (buff 128), token: principal, request-id: uint }))
	(ok (unwrap! (map-get? burn-requests key) err-invalid-request)))

(define-read-only (get-inscribe-request-ids (inscribe (buff 128)))
	(default-to (list ) (map-get? inscribe-request-ids inscribe)))

;; priviliged functions

(define-public (update-burn-request (key { pay: (buff 128), inscribe: (buff 128), token: principal, request-id: uint }) (status (buff 1)))
	(begin
		(try! (is-dao-or-extension))
		(ok (map-set burn-requests key status))))
		
(define-public (add-inscribe-request-id (inscribe (buff 128)) (request-id uint))
	(begin
		(try! (is-dao-or-extension))
		(ok (map-set inscribe-request-ids inscribe (unwrap-panic (as-max-len? (append (get-inscribe-request-ids inscribe) request-id) u2000))))))
;; internal functions



```
