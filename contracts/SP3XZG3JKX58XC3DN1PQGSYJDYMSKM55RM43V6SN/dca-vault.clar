(use-trait ft 'SP2AKWJYC7BNY18W1XXKPGP0YVEK63QJG4793Z2D4.sip-010-trait-ft-standard.sip-010-trait)
(use-trait share-fee-to-trait 'SP1Y5YSTAHZ88XYK1VPDH24GY0HPX5J4JECTMY4A1.univ2-share-fee-to-trait.share-fee-to-trait)

(define-constant ERR-NOT-AUTHORIZED (err u1000))
(define-constant ERR-PAUSED (err u1001))
(define-constant ERR-INVALID-AMOUNT (err u2000))
(define-constant ERR-INVALID-PRICE (err u2006))

(define-data-var paused bool false)

(define-read-only (is-approved)
	(contract-call? .auth is-approved)
)

(define-read-only (is-paused) 
		(var-get paused)
)

(define-public (pause (new-paused bool))
	(begin
		(asserts! (is-approved) ERR-NOT-AUTHORIZED) 
		(ok (var-set paused new-paused))
))

(define-public (transfer-ft (token-trait <ft>) (amount uint) (recipient principal)) 
	(begin 
		(asserts! (is-approved) ERR-NOT-AUTHORIZED) 
		(asserts! (not (is-paused)) ERR-PAUSED) 
		(as-contract (contract-call? token-trait transfer amount tx-sender recipient none ))
))