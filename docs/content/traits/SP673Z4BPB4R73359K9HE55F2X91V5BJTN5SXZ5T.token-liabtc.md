---
title: "Trait token-liabtc"
draft: true
---
```

;; SPDX-License-Identifier: BUSL-1.1

;; liabtc
;;

(define-fungible-token liabtc)

(define-constant err-unauthorised (err u3000))
(define-constant err-invalid-amount (err u3001))

(define-data-var token-name (string-ascii 32) "LiaBTC")
(define-data-var token-symbol (string-ascii 10) "LiaBTC")
(define-data-var token-uri (optional (string-utf8 256)) (some u"https://cdn.lisalab.io/metadata/token-liabtc.json"))

(define-data-var token-decimals uint u8)

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
        (var-set reserve new-reserve)
        (print {notification: "rebase", payload: {reserve: (var-get reserve), total-shares: (ft-get-supply liabtc)}})
        (ok true)))

(define-public (add-reserve (increment uint))
    (set-reserve (+ (var-get reserve) increment)))

(define-public (remove-reserve (decrement uint))
    (begin 
        (asserts! (<= decrement (var-get reserve)) err-invalid-amount)
        (set-reserve (- (var-get reserve) decrement))))

(define-public (dao-mint (amount uint) (recipient principal))
    (begin      
        (try! (is-dao-or-extension))
        (ft-mint? liabtc (get-tokens-to-shares amount) recipient)))

(define-public (dao-burn (amount uint) (sender principal))
    (begin
        (try! (is-dao-or-extension))
        (ft-burn? liabtc (get-tokens-to-shares amount) sender)))

(define-public (burn-many (senders (list 200 {amount: uint, sender: principal})))
    (fold check-err (map dao-burn-many-iter senders) (ok true)))

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
    (ok (get-shares-to-tokens (unwrap-panic (get-share who)))))

(define-read-only (get-total-supply)
    (get-reserve))

(define-read-only (get-share (who principal))
    (ok (ft-get-balance liabtc who)))

(define-read-only (get-total-shares)
    (ok (ft-get-supply liabtc)))

(define-read-only (get-tokens-to-shares (amount uint))
	(let (
		(shares-total (unwrap-panic (get-total-shares)))
		(reserve-total (unwrap-panic (get-reserve))))
		(if (or (is-eq reserve-total u0) (is-eq shares-total reserve-total))
			amount
			(/ (* amount shares-total) reserve-total))))

(define-read-only (get-shares-to-tokens (shares uint))
	(let (
		(shares-total (unwrap-panic (get-total-shares)))
		(reserve-total (unwrap-panic (get-reserve))))
		(if (or (is-eq reserve-total u0) (is-eq shares-total reserve-total))
			shares
			(/ (* shares reserve-total) shares-total))))

(define-read-only (get-reserve)
    (ok (var-get reserve)))

;; public calls

(define-public (transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 2048))))
    (let (
            (shares (get-tokens-to-shares amount)))
        (asserts! (or (is-eq tx-sender sender) (is-eq contract-caller sender)) err-unauthorised)
        (try! (ft-transfer? liabtc shares sender recipient))
        (match memo to-print (print to-print) 0x)
        (print { notification: "transfer", payload: { amount: amount, shares: shares, sender: sender, recipient: recipient } })
        (ok true)))

;; private functions

(define-private (dao-burn-many-iter (item {amount: uint, sender: principal}))
    (dao-burn (get amount item) (get sender item)))

(define-private (check-err (result (response bool uint)) (prior (response bool uint)))
    (match prior ok-value result err-value (err err-value)))


```
