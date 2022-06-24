(impl-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)

(define-fungible-token chimi u100000000)

(define-constant err-owner-only (err u100))
(define-constant err-not-token-owner (err u101))
(define-constant err-max-supply (err u102))

;; supply constants
(define-constant dao-supply u70000000)
(define-constant team-supply u15000000)
(define-constant chimi-supply u15000000)

;; supply wallets
(define-constant dao-principal 'SP2BSV94A650WGZ2YZ5Y8HM93W01NGT4GY0W2BN3P)
(define-constant team-principal 'SPKPXQ0X3A4D1KZ4XTP1GABJX1N36VW10D02TK9X)
(define-constant chimi-principal 'SP1G6NBZ22B184MM26QY1DVH657K8KP01GW8RDRM1)

(define-data-var contract-owner principal tx-sender)

(define-data-var token-uri (optional (string-utf8 256)) none)

;; public functions
(define-public (transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
	(begin
		(asserts! (or (is-eq tx-sender sender) (is-eq contract-caller sender)) err-not-token-owner)
		(ft-transfer? chimi amount sender recipient)
	)
)

(define-read-only (get-name)
    (ok "Chimichanga")
)

(define-read-only (get-symbol)
    (ok "CHIMI")
)

(define-read-only (get-decimals)
    (ok u2)
)

(define-read-only (get-balance (who principal))
    (ok (ft-get-balance chimi who))
)

(define-read-only (get-total-supply)
    (ok (ft-get-supply chimi))
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
        (try! (ft-mint? chimi dao-supply dao-principal))
        (try! (ft-mint? chimi team-supply team-principal))
        (try! (ft-mint? chimi chimi-supply chimi-principal))
        (ok true)
    )
)
(begin
  (mint))