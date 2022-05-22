(impl-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)


(define-fungible-token mega u100000000)

(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-token-owner (err u101))
(define-constant err-max-supply (err u102))
;; supply constants
(define-constant dao-supply u48000000)
(define-constant team-supply u10000000)
(define-constant distribution-supply u42000000)
;; supply wallets
(define-constant dao-principal 'SP58N7DXQ2NJBBJWDV77BVR0M96BXFGXNYVQ0V4P)
(define-constant team-principal 'SP1B6HQ59YNKEA5S8V3B6QB97VQMETMWV7WQGJCKE)
(define-constant distribution-principal 'SP2CB60BC6ZMA44DCD1A9W4NAV8HTEFZHD0XBNFA4)

(define-data-var token-uri (optional (string-utf8 256)) (some u"ipfs://QmegBfV56VVh5XjgwMi3CoshLoLHRuR5kGDJNNge368oWW"))

;; public functions
(define-public (transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
	(begin
		(asserts! (or (is-eq tx-sender sender) (is-eq contract-caller sender)) err-not-token-owner)
		(ft-transfer? mega amount sender recipient)
	)
)

(define-read-only (get-name)
    (ok "Mega")
)

(define-read-only (get-symbol)
    (ok "MEGA")
)

(define-read-only (get-decimals)
    (ok u2)
)

(define-read-only (get-balance (who principal))
    (ok (ft-get-balance mega who))
)

(define-read-only (get-total-supply)
    (ok (ft-get-supply mega))
)

(define-read-only (get-token-uri)
    (ok (var-get token-uri))
)

(define-public (mint)
    (begin
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        (try! (ft-mint? mega dao-supply dao-principal))
        (try! (ft-mint? mega team-supply team-principal))
        (try! (ft-mint? mega distribution-supply distribution-principal))
        (ok true)
    )
)

(begin
  (mint))
