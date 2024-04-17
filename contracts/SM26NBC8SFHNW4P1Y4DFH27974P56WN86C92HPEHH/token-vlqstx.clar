
;; SPDX-License-Identifier: BUSL-1.1

;; vlqstx

(define-fungible-token vlqstx)

(define-constant err-unauthorised (err u3000))

(define-data-var token-name (string-ascii 32) "vlqstx")
(define-data-var token-symbol (string-ascii 10) "vlqstx")
(define-data-var token-uri (optional (string-utf8 256)) (some u"https://cdn.alexlab.co/metadata/vlqstx.json"))

(define-data-var token-decimals uint u6)

;; governance functions

(define-public (set-name (new-name (string-ascii 32)))
	(begin
		(try! (is-dao-or-extension))
		(ok (var-set token-name new-name))))

(define-public (set-symbol (new-symbol (string-ascii 10)))
	(begin
		(try! (is-dao-or-extension))
		(ok (var-set token-symbol new-symbol))
	)
)

(define-public (set-decimals (new-decimals uint))
	(begin
		(try! (is-dao-or-extension))
		(ok (var-set token-decimals new-decimals))))

(define-public (set-token-uri (new-uri (optional (string-utf8 256))))
	(begin
		(try! (is-dao-or-extension))
		(ok (var-set token-uri new-uri))))

;; public functions

(define-public (transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 2048))))
	(begin
		(asserts! (or (is-eq tx-sender sender) (is-eq contract-caller sender)) err-unauthorised)
		(try! (ft-transfer? vlqstx amount sender recipient))
		(print { type: "transfer", amount: amount, sender: sender, recipient: recipient, memo: memo })
		(ok true)))

(define-public (mint (amount uint) (recipient principal))
	(begin 
		(asserts! (or (is-eq tx-sender recipient) (is-eq contract-caller recipient)) err-unauthorised)				
		(try! (ft-mint? vlqstx (get-tokens-to-shares amount) recipient))
		(contract-call? .token-lqstx transfer amount recipient (as-contract tx-sender) none)))

(define-public (burn (amount uint) (sender principal))
	(begin
		(asserts! (or (is-eq tx-sender sender) (is-eq contract-caller sender)) err-unauthorised)
		(as-contract (try! (contract-call? .token-lqstx transfer (get-shares-to-tokens amount) tx-sender sender none)))
		(ft-burn? vlqstx amount sender)))

;; read-only functions

(define-read-only (is-dao-or-extension)
	(ok (asserts! (or (is-eq tx-sender .lisa-dao) (contract-call? .lisa-dao is-extension contract-caller)) err-unauthorised)))
	
(define-read-only (get-name)
	(ok (var-get token-name)))

(define-read-only (get-symbol)
	(ok (var-get token-symbol)))

(define-read-only (get-token-uri)
	(ok (var-get token-uri)))

(define-read-only (get-decimals)
	(ok (var-get token-decimals)))

(define-read-only (get-balance (who principal))
	(ok (ft-get-balance vlqstx who)))

(define-read-only (get-total-supply)
	(ok (ft-get-supply vlqstx)))

(define-read-only (get-share (who principal))
	(ok (get-shares-to-tokens (unwrap-panic (get-balance who)))))

(define-read-only (get-total-shares)
	(contract-call? .token-lqstx get-balance (as-contract tx-sender)))

(define-read-only (get-tokens-to-shares (amount uint))
	(if (is-eq (get-total-supply) (ok u0))
		amount
		(/ (* amount (unwrap-panic (get-total-supply))) (unwrap-panic (get-total-shares)))))

(define-read-only (get-shares-to-tokens (shares uint))
	(if (is-eq (get-total-supply) (ok u0))
		shares
		(/ (* shares (unwrap-panic (get-total-shares))) (unwrap-panic (get-total-supply)))))

;; private functions
