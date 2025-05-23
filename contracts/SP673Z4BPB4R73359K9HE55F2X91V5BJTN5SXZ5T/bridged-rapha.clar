;; SPDX-License-Identifier: BUSL-1.1

(impl-trait 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.trait-sip-010.sip-010-trait)

(define-fungible-token bridged-rapha)

(define-data-var token-name (string-ascii 32) "RAPHA TOKEN")
(define-data-var token-symbol (string-ascii 32) "RAPHA TOKEN")
(define-data-var token-uri (optional (string-utf8 256)) (some u"https://cdn.xlink.network/metadata/bridged-rapha.json"))

(define-data-var token-decimals uint u8)

;; errors
(define-constant ERR-NOT-AUTHORIZED (err u1000))
(define-constant ERR-MINT-FAILED (err u6002))
(define-constant ERR-BURN-FAILED (err u6003))
(define-constant ERR-TRANSFER-FAILED (err u3000))
(define-constant ERR-NOT-SUPPORTED (err u6004))

;; ------ 
(define-read-only (get-base-token)
  'SP14ZYP25NW67XZQWMCDQCGH9S178JT78QJYE6K37.rapha-faktory)

(define-read-only (get-base-decimals)
  (contract-call? 'SP14ZYP25NW67XZQWMCDQCGH9S178JT78QJYE6K37.rapha-faktory get-decimals))

(define-read-only (get-balance (who principal))
  (ok (/ (* (unwrap-panic (contract-call? 'SP14ZYP25NW67XZQWMCDQCGH9S178JT78QJYE6K37.rapha-faktory get-balance who)) (pow-decimals)) (pow u10 (unwrap-panic (get-base-decimals))))))

(define-public (transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
  (begin
    (asserts! (is-eq sender tx-sender) ERR-NOT-AUTHORIZED)
    (contract-call? 'SP14ZYP25NW67XZQWMCDQCGH9S178JT78QJYE6K37.rapha-faktory transfer (/ (* amount (pow u10 (unwrap-panic (get-base-decimals)))) (pow-decimals)) sender recipient memo)))
;; ------

(define-read-only (is-dao-or-extension)
	(ok (asserts! (or (is-eq tx-sender 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.executor-dao) (contract-call? 'SP2XD7417HGPRTREMKF748VNEQPDRR0RMANB7X1NK.executor-dao is-extension contract-caller)) ERR-NOT-AUTHORIZED)))

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
  (/ (* amount (pow-decimals)) ONE_8))

(define-private (decimals-to-fixed (amount uint))
  (/ (* amount ONE_8) (pow-decimals)))

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
