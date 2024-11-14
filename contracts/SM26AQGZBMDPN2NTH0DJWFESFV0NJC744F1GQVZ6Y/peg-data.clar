(define-constant err-unauthorized (err u3000))
(define-constant err-invalid-fee (err u3001))

(define-constant one-12 u1000000000000)

(define-data-var contract-owner principal tx-sender)
(define-data-var peg-in-paused bool true)
(define-data-var peg-out-paused bool true)
;; 8 decimals
(define-data-var peg-in-fee uint u0)
(define-data-var peg-out-fee uint u0)
(define-data-var peg-out-gas-fee uint u0)

(define-read-only (is-peg-in-paused)
	(var-get peg-in-paused))

(define-read-only (is-peg-out-paused)
	(var-get peg-out-paused))

(define-read-only (get-peg-in-fee)
	(var-get peg-in-fee))

(define-read-only (get-peg-out-fee)
	(var-get peg-out-fee))

(define-read-only (get-peg-out-gas-fee)
	(var-get peg-out-gas-fee))

(define-read-only (is-contract-owner)
	(ok (asserts! (is-eq (var-get contract-owner) contract-caller) err-unauthorized)))

(define-public (set-contract-owner (new-contract-owner principal))
	(begin
		(try! (is-contract-owner))
		(print { action: "set-contract-owner", data: { new-contract-owner: new-contract-owner } })
		(ok (var-set contract-owner new-contract-owner))))

(define-public (pause-peg-in (paused bool))
	(begin
		(try! (is-contract-owner))
		(print { action: "pause-peg-in", data: { paused: paused } })
		(ok (var-set peg-in-paused paused))))

(define-public (pause-peg-out (paused bool))
	(begin
		(try! (is-contract-owner))
		(print { action: "pause-peg-out", data: { paused: paused } })
		(ok (var-set peg-out-paused paused))))

(define-public (set-peg-in-fee (fee uint))
	(begin
		(try! (is-contract-owner))
		(asserts! (< fee one-12) err-invalid-fee)
		(print { action: "set-peg-in-fee", data: { fee: fee } })
		(ok (var-set peg-in-fee fee))))

(define-public (set-peg-out-fee (fee uint))
	(begin
		(try! (is-contract-owner))
		(asserts! (< fee one-12) err-invalid-fee)
		(print { action: "set-peg-out-fee", data: { fee: fee } })
		(ok (var-set peg-out-fee fee))))

(define-public (set-peg-out-gas-fee (fee uint))
	(begin
		(try! (is-contract-owner))
		(print { action: "set-peg-out-gas-fee", data: { fee: fee } })
		(ok (var-set peg-out-gas-fee fee))))
