(define-constant err-unauthorized (err u2000))

(define-data-var contract-owner principal tx-sender)
(define-map approved-operators principal bool)
(define-map approved-peg-in-address (buff 128) bool)
(define-map peg-in-sent { tx: (buff 4096), output: uint } bool)

;; peg-in data
(define-read-only (is-peg-in-address-approved (address (buff 128)))
	(default-to false (map-get? approved-peg-in-address address)))

(define-read-only (get-peg-in-sent (tx (buff 4096)) (output uint))
	(default-to false (map-get? peg-in-sent { tx: tx, output: output })))

;; permission data
(define-read-only (get-approved-operator (operator principal))
	(default-to false (map-get? approved-operators operator)))

(define-read-only (is-contract-owner)
	(ok (asserts! (is-eq (var-get contract-owner) contract-caller) err-unauthorized)))

(define-read-only (is-approved-operator)
	(ok (asserts! (or (get-approved-operator contract-caller) (is-ok (is-contract-owner))) err-unauthorized)))

(define-public (approve-operator (operator principal) (approved bool))
	(begin
		(try! (is-contract-owner))
		(print { action: "approve-operator", data: { operator: operator, approved: approved } })
		(ok (map-set approved-operators operator approved))))

(define-public (set-contract-owner (new-contract-owner principal))
	(begin
		(try! (is-contract-owner))
		(print { action: "set-contract-owner", data: { new-contract-owner: new-contract-owner } })
		(ok (var-set contract-owner new-contract-owner))))

(define-public (approve-peg-in-address (address (buff 128)) (approved bool))
	(begin
		(try! (is-contract-owner))
		(print { action: "approve-peg-in-address", data: { address: address, approved: approved } })
		(ok (map-set approved-peg-in-address address approved))))

(define-public (set-peg-in-sent (tx (buff 4096)) (output uint) (sent bool))
	(begin
		(try! (is-approved-operator))
		(print { action: "set-peg-in-sent", data: { tx: tx, output: output, sent: sent } })
		(ok (map-set peg-in-sent { tx: tx, output: output } sent))))
