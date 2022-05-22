(impl-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)

(define-fungible-token megacoin u1000000)

(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-token-owner (err u101))
(define-constant err-max-supply (err u102))
;; supply constants
(define-constant dao-supply u480000)
(define-constant team-supply u100000)
(define-constant distribution-supply u420000)
;; supply wallets
(define-constant dao-principal 'SP58N7DXQ2NJBBJWDV77BVR0M96BXFGXNYVQ0V4P)
(define-constant team-principal 'SP1B6HQ59YNKEA5S8V3B6QB97VQMETMWV7WQGJCKE)
(define-constant distribution-principal 'SP2CB60BC6ZMA44DCD1A9W4NAV8HTEFZHD0XBNFA4)

(define-data-var token-uri (optional (string-utf8 256)) (some u""))

;; public functions
(define-public (transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
	(begin
		(asserts! (or (is-eq tx-sender sender) (is-eq contract-caller sender)) err-not-token-owner)
		(ft-transfer? megacoin amount sender recipient)
	)
)

(define-read-only (get-name)
    (ok "MegaCoin")
)

(define-read-only (get-symbol)
    (ok "MEGA")
)

(define-read-only (get-decimals)
    (ok u6)
)

(define-read-only (get-balance (who principal))
    (ok (ft-get-balance megacoin who))
)

(define-read-only (get-total-supply)
    (ok (ft-get-supply megacoin))
)

(define-read-only (get-token-uri)
    (ok (var-get token-uri))
)

(define-public (mint)
    (begin
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        (try! (ft-mint? megacoin dao-supply dao-principal))
        (try! (ft-mint? megacoin team-supply team-principal))
        (try! (ft-mint? megacoin distribution-supply distribution-principal))
        (ok true)
    )
)

(define-public (set-token-uri (new-uri (optional (string-utf8 256))))
	(begin
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
		(ok (var-set token-uri new-uri))
	)
)
