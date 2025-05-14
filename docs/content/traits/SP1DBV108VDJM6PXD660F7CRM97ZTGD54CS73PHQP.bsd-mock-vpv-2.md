---
title: "Trait bsd-mock-vpv-2"
draft: true
---
```

;; title: bsd Token Contract

;; Explicit SIP-010 conformity
(impl-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)

;; BSD Protocol 
(impl-trait .bsd-trait-vpv-2.bsd-trait)

;; Defines the bsd fungible token
(define-fungible-token bsd)

(define-constant contract-deployer tx-sender)

(define-constant TOKEN_NAME "BSD")
(define-constant TOKEN_SYMBOL "BSD")
(define-constant TOKEN_DECIMALS u8)

(define-constant ERR_NOT_AUTH (err u4))

(define-data-var token-uri (string-utf8 256) u"")

;; Protocol contract principals
(define-map authorized-protocol-callers principal bool)

;; Owner
(define-data-var owner principal contract-deployer)

(define-read-only (is-authorized-protocol-caller (who principal))
	(ok (asserts! (default-to false (map-get? authorized-protocol-callers who)) ERR_NOT_AUTH))
)

(define-read-only (is-owner (who principal))
  (ok (asserts! (is-eq who (var-get owner)) ERR_NOT_AUTH))
)

;; ---------------------------------------------------------
;; SIP-10 Functions - BEGIN
;; ---------------------------------------------------------

(define-public (transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
  (begin
    (asserts! (is-eq tx-sender sender) ERR_NOT_AUTH)

    (match (ft-transfer? bsd amount sender recipient)
      response (begin
        (print memo)
        (ok response)
      )
      error (err error)
    )
  )
)

(define-read-only (get-name)
  (ok TOKEN_NAME)
)

(define-read-only (get-symbol)
  (ok TOKEN_SYMBOL)
)

(define-read-only (get-decimals)
  (ok TOKEN_DECIMALS)
)

(define-read-only (get-balance (account principal))
  (ok (ft-get-balance bsd account))
)

(define-read-only (get-total-supply)
  (ok (ft-get-supply bsd))
)

(define-read-only (get-token-uri)
  (ok (some (var-get token-uri)))
)

;; ---------------------------------------------------------
;; SIP-10 Functions - END
;; ---------------------------------------------------------

;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;
;;;; Admin  ;;;;
;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;

(define-public (set-token-uri (value (string-utf8 256)))
  (begin
    (try! (is-owner tx-sender))
    (ok (var-set token-uri value))
  )
)

(define-public (set-owner (new-owner principal))
	(begin 
		(try! (is-owner tx-sender))
		(ok (var-set owner new-owner))
	)
)

(define-public (add-privileged-protocol-principal (new-protocol-principal principal))
	(begin 
		(try! (is-owner tx-sender))
		(ok (map-set authorized-protocol-callers new-protocol-principal true))
	)
)

(define-public (remove-privileged-protocol-principal (protocol-principal principal))
	(begin 
		(try! (is-owner tx-sender))
		(ok (map-delete authorized-protocol-callers protocol-principal))
	)
)

;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;
;;; Protocol ;;;
;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;

(define-public (protocol-burn (user principal) (bsd-amount uint))
  (begin
    (try! (is-authorized-protocol-caller contract-caller))
    (ft-burn? bsd bsd-amount user)
  )
)

(define-public (protocol-transfer (bsd-amount uint) (sender principal) (recipient principal))
  (begin
    (try! (is-authorized-protocol-caller contract-caller))
    (ft-transfer? bsd bsd-amount sender recipient)
  )
)

(define-public (protocol-mint (user principal) (bsd-amount uint))
  (begin
    (try! (is-authorized-protocol-caller contract-caller))
    (ft-mint? bsd bsd-amount user)
  )
)

;; Initialization 
(map-set authorized-protocol-callers (var-get owner) true)
(map-set authorized-protocol-callers .registry-vpv-2 true)
(map-set authorized-protocol-callers .vault-vpv-2 true)
(map-set authorized-protocol-callers .redeem-vpv-2 true)
(map-set authorized-protocol-callers .stability-vpv-2 true)
```
