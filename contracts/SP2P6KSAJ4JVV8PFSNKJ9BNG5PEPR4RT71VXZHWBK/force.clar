(define-fungible-token force u10000000000)

(define-constant err-owner-only (err u100))
(define-constant err-not-token-owner (err u101))
(define-constant err-max-supply (err u102))
;; supply constants

(define-constant dao-supply u7000000000)
(define-constant team-supply u1500000000)
(define-constant tiger-force-supply u1500000000)
;; supply wallets
(define-constant dao-principal 'SP32T750WZBBC7FZ2ZTKWV61ZASSM2CVWRK861Z5S)
(define-constant team-principal 'SP1CMYQDPP9CMNYVZJV574FFY6ESSCHZP6PQ9JNB8)
(define-constant tiger-force-principal 'SP2DTD6SA45P22AGH7HRD8JDBM55CRP3MR6J06K6A)

(define-data-var contract-owner principal tx-sender)

(define-data-var token-uri (optional (string-utf8 256)) (some u"ipfs://ipfs/QmcTY9Au6C3tis3PVU7Votzzp2rwimDkvrPQXbf4No5wee"))

;; public functions
(define-public (transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
	(begin
		(asserts! (or (is-eq tx-sender sender) (is-eq contract-caller sender)) err-not-token-owner)
		(ft-transfer? force amount sender recipient)
	)
)

(define-read-only (get-name)
    (ok "Force")
)

(define-read-only (get-symbol)
    (ok "FORCE")
)

(define-read-only (get-decimals)
    (ok u2)
)

(define-read-only (get-balance (who principal))
    (ok (ft-get-balance force who))
)

(define-read-only (get-total-supply)
    (ok (ft-get-supply force))
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
        (try! (ft-mint? force dao-supply dao-principal))
        (try! (ft-mint? force team-supply team-principal))
        (try! (ft-mint? force tiger-force-supply tiger-force-principal))
        (ok true)
    )
)
(begin
  (mint))