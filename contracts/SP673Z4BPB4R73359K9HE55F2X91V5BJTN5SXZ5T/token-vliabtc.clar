
;; SPDX-License-Identifier: BUSL-1.1

;; vliabtc

(define-fungible-token vliabtc)

(define-constant err-unauthorised (err u3000))

(define-data-var token-name (string-ascii 32) "vLiaBTC")
(define-data-var token-symbol (string-ascii 10) "vLiaBTC")
(define-data-var token-uri (optional (string-utf8 256)) (some u"https://cdn.lisalab.io/metadata/token-vliabtc.json"))

(define-data-var token-decimals uint u8)

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
        (try! (ft-transfer? vliabtc amount sender recipient))
        (print { type: "transfer", amount: amount, sender: sender, recipient: recipient, memo: memo })
        (ok true)))

(define-public (mint (amount uint) (recipient principal))
    (begin 
        (asserts! (or (is-eq tx-sender recipient) (is-eq contract-caller recipient)) err-unauthorised)              
        (try! (ft-mint? vliabtc (get-tokens-to-shares amount) recipient))
        (contract-call? .token-liabtc transfer amount recipient (as-contract tx-sender) none)))

(define-public (burn (amount uint) (sender principal))
    (begin
        (asserts! (or (is-eq tx-sender sender) (is-eq contract-caller sender)) err-unauthorised)
        (as-contract (try! (contract-call? .token-liabtc transfer (get-shares-to-tokens amount) tx-sender sender none)))
        (ft-burn? vliabtc amount sender)))

;; read-only functions

(define-read-only (is-dao-or-extension)
    (ok (asserts! (or (is-eq tx-sender 'SM26NBC8SFHNW4P1Y4DFH27974P56WN86C92HPEHH.lisa-dao) (contract-call? 'SM26NBC8SFHNW4P1Y4DFH27974P56WN86C92HPEHH.lisa-dao is-extension contract-caller)) err-unauthorised)))
    
(define-read-only (get-name)
    (ok (var-get token-name)))

(define-read-only (get-symbol)
    (ok (var-get token-symbol)))

(define-read-only (get-token-uri)
    (ok (var-get token-uri)))

(define-read-only (get-decimals)
    (ok (var-get token-decimals)))

(define-read-only (get-balance (who principal))
    (ok (ft-get-balance vliabtc who)))

(define-read-only (get-total-supply)
    (ok (ft-get-supply vliabtc)))

(define-read-only (get-share (who principal))
    (ok (get-shares-to-tokens (unwrap-panic (get-balance who)))))

(define-read-only (get-total-shares)
    (contract-call? .token-liabtc get-balance (as-contract tx-sender)))

(define-read-only (get-tokens-to-shares (amount uint))
	(let (
		(shares-total (unwrap-panic (get-total-shares)))
		(supply-total (unwrap-panic (get-total-supply))))
		(if (or (is-eq supply-total u0) (is-eq shares-total supply-total))
			amount
			(/ (* amount supply-total) shares-total))))

(define-read-only (get-shares-to-tokens (shares uint))
	(let (
		(shares-total (unwrap-panic (get-total-shares)))
		(supply-total (unwrap-panic (get-total-supply))))
		(if (or (is-eq supply-total u0) (is-eq shares-total supply-total))
			shares
			(/ (* shares shares-total) supply-total))))

;; private functions

