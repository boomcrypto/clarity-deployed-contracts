(impl-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)


(define-fungible-token testdoin u100000000)

(define-constant err-owner-only (err u100))
(define-constant err-not-token-owner (err u101))
(define-constant err-max-supply (err u102))
;; supply constants

(define-constant dao-supply u70000000)
(define-constant team-supply u15000000)
(define-constant test-supply u15000000)
;; supply wallets
(define-constant dao-principal 'SP3BT9AEHQ82QEGQVY0WCW3QD8HGVYDG3Y1B3CP4S)
(define-constant team-principal 'SP3BT9AEHQ82QEGQVY0WCW3QD8HGVYDG3Y1B3CP4S)
(define-constant test-principal 'SP1RN1REQMGNNGEEDEWR8F7DWYH8W2BPFXVTNZJ3W)

(define-data-var contract-owner principal tx-sender)

(define-data-var token-uri (optional (string-utf8 256)) (some u"ipfs://ipfs/test"))

;; public functions
(define-public (transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
	(begin
		(asserts! (or (is-eq tx-sender sender) (is-eq contract-caller sender)) err-not-token-owner)
		(ft-transfer? testdoin amount sender recipient)
	)
)

(define-read-only (get-name)
    (ok "TestDoin")
)

(define-read-only (get-symbol)
    (ok "TESTDOIN")
)

(define-read-only (get-decimals)
    (ok u2)
)

(define-read-only (get-balance (who principal))
    (ok (ft-get-balance testdoin who))
)

(define-read-only (get-total-supply)
    (ok (ft-get-supply testdoin))
)

(define-read-only (get-token-uri)
    (ok (var-get token-uri))
)


(define-public (set-token-uri (new-token-uri (optional (string-utf8 256))))
   
    (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) err-owner-only)
    (var-set token-uri new-token-uri)
    (ok true)
    )
  )




(define-public (set-contract-owner (new-owner principal))
 
    (begin
    
        (asserts! (is-eq contract-caller (var-get contract-owner)) err-owner-only)
         (var-set contract-owner new-owner)
           (ok true)
    )
  )



(define-public (mint)
        (begin
        (asserts! (is-eq tx-sender (var-get contract-owner)) err-owner-only)
        (try! (ft-mint? testdoin dao-supply dao-principal))
        (try! (ft-mint? testdoin team-supply team-principal))
        (try! (ft-mint? testdoin test-supply test-principal))
        (ok true)
    )
)
(begin
  (mint))