(impl-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)


(define-fungible-token testvoin u100000000)

(define-constant err-owner-only (err u100))
(define-constant err-not-token-owner (err u101))
(define-constant err-max-supply (err u102))
;; supply constants

(define-constant dao-supply u70000000)
(define-constant team-supply u15000000)
(define-constant test-supply u15000000)
;; supply wallets
(define-constant dao-principal 'SP1RN1REQMGNNGEEDEWR8F7DWYH8W2BPFXVTNZJ3W)
(define-constant team-principal 'SP1RN1REQMGNNGEEDEWR8F7DWYH8W2BPFXVTNZJ3W)
(define-constant test-principal 'SP1RN1REQMGNNGEEDEWR8F7DWYH8W2BPFXVTNZJ3W)

(define-data-var contract-owner principal tx-sender)

(define-data-var token-uri (optional (string-utf8 256)) (some u"ipfs://ipfs/test"))

;; public functions
(define-public (transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
	(begin
		(asserts! (or (is-eq tx-sender sender) (is-eq contract-caller sender)) err-not-token-owner)
		(ft-transfer? testvoin amount sender recipient)
	)
)

(define-read-only (get-name)
    (ok "TestVoin")
)

(define-read-only (get-symbol)
    (ok "TESTVOIN")
)

(define-read-only (get-decimals)
    (ok u2)
)

(define-read-only (get-balance (who principal))
    (ok (ft-get-balance testvoin who))
)

(define-read-only (get-total-supply)
    (ok (ft-get-supply testvoin))
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
        (try! (ft-mint? testvoin dao-supply dao-principal))
        (try! (ft-mint? testvoin team-supply team-principal))
        (try! (ft-mint? testvoin test-supply test-principal))
        (ok true)
    )
)
(begin
  (mint))