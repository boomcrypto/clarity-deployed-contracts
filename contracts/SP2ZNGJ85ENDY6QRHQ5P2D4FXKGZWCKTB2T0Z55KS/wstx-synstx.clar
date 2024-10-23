;; wSTX-synSTX lp token

(impl-trait .dao-traits-v4.sip010-ft-trait)
(impl-trait .dao-traits-v4.ft-plus-trait)

;; no maximum supply
(define-fungible-token lp-token)

;; metadata variables
(define-data-var token-uri (optional (string-utf8 256)) (some u"https://charisma.rocks/sip10/wstx-synstx/metadata.json"))
(define-data-var token-name (string-ascii 32) "wSTX-synSTX")
(define-data-var token-symbol (string-ascii 10) "vSTX")
(define-data-var token-decimals uint u6)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; errors
(define-constant err-check-owner  (err u1))
(define-constant err-transfer     (err u2))
(define-constant err-unauthorized (err u3))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; ownership
(define-private (check-owner)
  (ok (asserts! (is-eq contract-caller .univ2-core) err-check-owner)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; ft-plus-trait
(define-public (mint (amt uint) (to principal))
  (begin
    (try! (check-owner))
    (ft-mint? lp-token amt to) ))

(define-public (burn (amt uint) (from principal))
  (begin
    (try! (check-owner))
    (ft-burn? lp-token amt from) ))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; ft-trait
(define-public
  (transfer
    (amt  uint)
    (from principal)
    (to   principal)
    (memo (optional (buff 34))))
	(begin
	 (asserts! (is-eq tx-sender from) err-transfer)
	 (ft-transfer? lp-token amt from to)))

(define-read-only (get-name)                   (ok (var-get token-name)))
(define-read-only (get-symbol)                 (ok (var-get token-symbol)))
(define-read-only (get-decimals)               (ok (var-get token-decimals)))
(define-read-only (get-balance (of principal)) (ok (ft-get-balance lp-token of)))
(define-read-only (get-total-supply)           (ok (ft-get-supply lp-token)))
(define-read-only (get-token-uri)              (ok (var-get token-uri)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; setters
(define-public (set-token-uri (new-uri (optional (string-utf8 256))))
	(begin
		(try! (check-owner))
		(var-set token-uri new-uri)
		(ok (print { notification: "token-metadata-update",	payload: { token-class: "ft", contract-id: (as-contract tx-sender) }}))))

(define-public (set-name (new-name (string-ascii 32)))
	(begin
		(try! (check-owner))
		(ok (var-set token-name new-name))))
    
(define-public (set-symbol (new-symbol (string-ascii 10)))
	(begin
		(try! (check-owner))
		(ok (var-set token-symbol new-symbol))))

(define-public (set-decimals (new-decimals uint))
	(begin
		(try! (check-owner))
		(ok (var-set token-decimals new-decimals))))

;;; eof