(use-trait sip-010-token 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)
(impl-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)

(define-fungible-token mtb21)
(define-constant unauthorized u4001)
(define-constant only-owner u4002)
(define-constant token-name "MikeTangoBravo21")
(define-constant token-symbol "MTB21")
(define-constant decimals u0)
(define-data-var uri (string-utf8 256) u"")
(define-data-var owner principal tx-sender)

(define-read-only (get-name) 
    (ok token-name)
)

(define-read-only (get-symbol)
    (ok token-symbol)
)

(define-read-only (get-decimals) 
    (ok decimals)
)


(define-public (set-token-uri (updated-uri (string-utf8 256)))
  (begin
    (ok (var-set uri updated-uri)))
)

(define-read-only (get-balance (address principal) )
    (ok (ft-get-balance mtb21 address))
)

(define-read-only (get-total-supply)
    (ok (ft-get-supply mtb21))
)

(define-read-only (get-token-uri)
  (ok (some (var-get uri)))
)

(define-public (change-owner-to-contract (contract <sip-010-token>))
	(begin
		(asserts! (is-eq (var-get owner) contract-caller) (err only-owner))
		(var-set owner (contract-of contract))
		(ok true)
	)
)

(define-public (transfer (amount uint) (from principal) (to principal) (memo (optional (buff 34))))
  (begin
    (asserts! (is-eq tx-sender from)  (err unauthorized))
    (ft-transfer? mtb21 amount from to)
  )
)

(define-public (mint (recipient principal) (amount uint)) 
    (begin  
        (asserts! (is-eq (var-get owner) contract-caller) (err only-owner))
        (ft-mint? mtb21 amount recipient)
    )
)

(define-public (burn (recipient principal) (amount uint)) 
    (begin  
        (asserts! (is-eq (var-get owner) contract-caller) (err only-owner))
        (ft-burn? mtb21 amount recipient)
    )
)