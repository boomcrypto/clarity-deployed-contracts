;; lqstx
;;

(define-fungible-token lqstx)

(define-constant err-unauthorised (err u3000))
(define-constant err-invalid-amount (err u3001))

(define-data-var token-name (string-ascii 32) "lqstx")
(define-data-var token-symbol (string-ascii 10) "lqstx")
(define-data-var token-uri (optional (string-utf8 256)) (some u"https://cdn.alexlab.co/metadata/token-lqstx.json"))

(define-data-var token-decimals uint u6)

(define-data-var reserve uint u0)

;; governance functions

(define-public (dao-set-name (new-name (string-ascii 32)))
	(begin
		(try! (is-dao-or-extension))
		(ok (var-set token-name new-name))))

(define-public (dao-set-symbol (new-symbol (string-ascii 10)))
	(begin
		(try! (is-dao-or-extension))
		(ok (var-set token-symbol new-symbol))))

(define-public (dao-set-decimals (new-decimals uint))
	(begin
		(try! (is-dao-or-extension))
		(ok (var-set token-decimals new-decimals))))

(define-public (dao-set-token-uri (new-uri (optional (string-utf8 256))))
	(begin
		(try! (is-dao-or-extension))
		(ok (var-set token-uri new-uri))))

;; privileged calls

(define-public (set-reserve (new-reserve uint))
	(begin 
		(try! (is-dao-or-extension))
		(ok (var-set reserve new-reserve))))

(define-public (add-reserve (increment uint))
	(set-reserve (+ (var-get reserve) increment)))

(define-public (remove-reserve (decrement uint))
	(begin 
		(asserts! (<= decrement (var-get reserve)) err-invalid-amount)
		(set-reserve (- (var-get reserve) decrement))))

(define-public (dao-mint (amount uint) (recipient principal))
	(begin		
		(try! (is-dao-or-extension))
		(ft-mint? lqstx (get-tokens-to-shares amount) recipient)))

(define-public (dao-burn (amount uint) (sender principal))
	(begin
		(try! (is-dao-or-extension))
		(ft-burn? lqstx (get-tokens-to-shares amount) sender)))

(define-public (burn-many (senders (list 200 {amount: uint, sender: principal})))
	(fold check-err (map dao-burn-many-iter senders) (ok true)))

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
	(ok (get-shares-to-tokens (unwrap-panic (get-share who)))))

(define-read-only (get-total-supply)
	(get-reserve))

(define-read-only (get-share (who principal))
	(ok (ft-get-balance lqstx who)))

(define-read-only (get-total-shares)
	(ok (ft-get-supply lqstx)))

(define-read-only (get-tokens-to-shares (amount uint))
	(if (is-eq (get-reserve) (ok u0))
		amount
		(/ (* amount (unwrap-panic (get-total-shares))) (unwrap-panic (get-reserve)))))

(define-read-only (get-shares-to-tokens (shares uint))
	(if (is-eq (get-total-shares) (ok u0))
		shares
		(/ (* shares (unwrap-panic (get-reserve))) (unwrap-panic (get-total-shares)))))

(define-read-only (get-reserve)
	(ok (var-get reserve)))

;; public calls

(define-public (transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 2048))))
	(begin
		(asserts! (or (is-eq tx-sender sender) (is-eq contract-caller sender)) err-unauthorised)
		(try! (ft-transfer? lqstx (get-tokens-to-shares amount) sender recipient))
		(print { type: "transfer", amount: amount, sender: sender, recipient: recipient, memo: memo })
		(ok true)))

;; private functions

(define-private (dao-burn-many-iter (item {amount: uint, sender: principal}))
	(dao-burn (get amount item) (get sender item)))

(define-private (check-err (result (response bool uint)) (prior (response bool uint)))
    (match prior ok-value result err-value (err err-value)))
