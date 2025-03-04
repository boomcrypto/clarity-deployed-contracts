;; SPDX-License-Identifier: BUSL-1.1

(impl-trait 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.trait-sip-010.sip-010-trait)

(define-fungible-token wpizza)

(define-data-var token-name (string-ascii 32) "Pizza Wrapper")
(define-data-var token-symbol (string-ascii 32) "wpizza")
(define-data-var token-uri (optional (string-utf8 256)) (some u"https://cdn.alexlab.co/metadata/token-wpizza.json"))

(define-data-var token-decimals uint u8)

;; errors
(define-constant ERR-NOT-AUTHORIZED (err u1000))
(define-constant ERR-MINT-FAILED (err u6002))
(define-constant ERR-BURN-FAILED (err u6003))
(define-constant ERR-TRANSFER-FAILED (err u3000))
(define-constant ERR-NOT-SUPPORTED (err u6004))

;; ------ 
(define-read-only (get-base-token)
  'SP256VGYK7ZFV6S2ZWHGE4PGMDDY8KWT3FD57H98G.pizza)

(define-read-only (get-base-decimals)
  (contract-call? 'SP256VGYK7ZFV6S2ZWHGE4PGMDDY8KWT3FD57H98G.pizza get-decimals))

(define-read-only (get-balance (who principal))
	(let (
			(base-balance (unwrap-panic (contract-call? 'SP256VGYK7ZFV6S2ZWHGE4PGMDDY8KWT3FD57H98G.pizza get-balance who))))
		(ok (if (is-eq (unwrap-panic (get-base-decimals)) (unwrap-panic (get-decimals))) base-balance (/ (* base-balance (pow-decimals)) (pow u10 (unwrap-panic (get-base-decimals))))))))

(define-public (transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
  (let (
			(base-amount (if (is-eq (unwrap-panic (get-base-decimals)) (unwrap-panic (get-decimals))) amount (/ (* amount (pow u10 (unwrap-panic (get-base-decimals)))) (pow-decimals)))))
		(asserts! (is-eq sender tx-sender) ERR-NOT-AUTHORIZED)
		(contract-call? 'SP256VGYK7ZFV6S2ZWHGE4PGMDDY8KWT3FD57H98G.pizza transfer base-amount sender recipient memo)))
;; ------

(define-read-only (is-dao-or-extension)
	(ok (asserts! (or (is-eq tx-sender 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.executor-dao) (contract-call? 'SP102V8P0F7JX67ARQ77WEA3D3CFB5XW39REDT0AM.executor-dao is-extension contract-caller)) ERR-NOT-AUTHORIZED)))

(define-public (set-name (new-name (string-ascii 32)))
	(begin
		(try! (is-dao-or-extension))
		(ok (var-set token-name new-name))))

(define-public (set-symbol (new-symbol (string-ascii 32)))
	(begin
		(try! (is-dao-or-extension))
		(ok (var-set token-symbol new-symbol))))

(define-public (set-decimals (new-decimals uint))
	(begin
		(try! (is-dao-or-extension))
		(ok (var-set token-decimals new-decimals))))

(define-public (set-token-uri (new-uri (optional (string-utf8 256))))
	(begin
		(try! (is-dao-or-extension))
		(ok (var-set token-uri new-uri))))

(define-read-only (get-total-supply)
    ERR-NOT-SUPPORTED)

(define-read-only (get-name)
    (ok (var-get token-name)))

(define-read-only (get-symbol)
    (ok (var-get token-symbol)))

(define-read-only (get-decimals)
    (ok (var-get token-decimals)))

(define-read-only (get-token-uri)
  (ok (var-get token-uri)))

(define-constant ONE_8 u100000000)

(define-private (pow-decimals)
  (pow u10 (unwrap-panic (get-decimals))))

(define-read-only (fixed-to-decimals (amount uint))
	(if (is-eq (unwrap-panic (get-decimals)) u8) amount (/ (* amount (pow-decimals)) ONE_8)))

(define-private (decimals-to-fixed (amount uint))
  (if (is-eq (unwrap-panic (get-decimals)) u8) amount (/ (* amount ONE_8) (pow-decimals))))

(define-read-only (get-total-supply-fixed)
  ERR-NOT-SUPPORTED)

(define-read-only (get-balance-fixed (account principal))
  (ok (decimals-to-fixed (unwrap-panic (get-balance account)))))

(define-public (transfer-fixed (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
  (transfer (fixed-to-decimals amount) sender recipient memo))

(define-public (mint (amount uint) (recipient principal))
  ERR-MINT-FAILED)

(define-public (burn (amount uint) (sender principal))
  ERR-BURN-FAILED)

(define-public (mint-fixed (amount uint) (recipient principal))
  (mint (fixed-to-decimals amount) recipient))

(define-public (burn-fixed (amount uint) (sender principal))
  (burn (fixed-to-decimals amount) sender))

(define-private (check-err (result (response bool uint)) (prior (response bool uint)))
  (match prior ok-value result err-value (err err-value)))

(define-private (transfer-from-tuple (recipient { to: principal, amount: uint }))
  (ok (unwrap! (transfer-fixed (get amount recipient) tx-sender (get to recipient) none) ERR-TRANSFER-FAILED)))

(define-public (send-many (recipients (list 200 { to: principal, amount: uint})))
  (fold check-err (map transfer-from-tuple recipients) (ok true)))
