;; 																----------------------
;; 																-------- AUTH --------
;; 																----------------------

(define-constant ERR-NOT-AUTHORIZED (err u1000))


(define-data-var contract-owner principal tx-sender)
(define-map approved-contracts principal bool)
(map-set approved-contracts (as-contract tx-sender) true)

(define-read-only (is-owner)
  (is-eq tx-sender (var-get contract-owner))
)
(define-read-only (is-approved)
  (default-to false (map-get? approved-contracts tx-sender))
)

(define-public (change-owner (new-owner principal)) 
(begin 
	(asserts! (is-owner) ERR-NOT-AUTHORIZED) 
	(ok (var-set contract-owner new-owner))
))

(define-public (add-approved-contract (new-approved-contract principal))
	(begin
	(asserts! (is-owner) ERR-NOT-AUTHORIZED) 
		(ok (map-set approved-contracts new-approved-contract true))
))

(define-public (remove-approved-contract (approved-contract principal))
	(begin
		(asserts! (is-owner) ERR-NOT-AUTHORIZED) 
		(ok (map-set approved-contracts approved-contract false))
))