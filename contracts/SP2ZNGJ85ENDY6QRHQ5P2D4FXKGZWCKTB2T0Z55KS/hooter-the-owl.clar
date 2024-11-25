;; Hooter the Owl

(impl-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)
(define-constant TOTAL-SUPPLY u10000000000000000)
(define-constant ERR-UNAUTHORIZED (err u403))
(define-constant deployer tx-sender)

(define-fungible-token hooter TOTAL-SUPPLY)
(define-data-var token-uri (optional (string-utf8 256)) 
  (some u"https://charisma.rocks/sip10/hooter/metadata.json"))

;; --- Fungible Token Traits

(define-public (transfer (amount uint) (from principal) (to principal) (memo (optional (buff 34))))
	(begin
    (asserts! (or (is-eq tx-sender from) (is-eq contract-caller from)) ERR-UNAUTHORIZED)
    (ft-transfer? hooter amount from to)))

(define-public (burn (amount uint))
  (ft-burn? hooter amount tx-sender))

(define-public (set-token-uri (value (string-utf8 256)))
  (if (is-eq tx-sender deployer) 
    (ok (var-set token-uri (some value))) 
    ERR-UNAUTHORIZED))

(define-read-only (get-name) (ok "Hooter the Owl"))

(define-read-only (get-symbol) (ok "HOOT"))

(define-read-only (get-decimals) (ok u6))

(define-read-only (get-balance (who principal))
	(ok (ft-get-balance hooter who)))

(define-read-only (get-total-supply)
	(ok (ft-get-supply hooter)))

(define-read-only (get-token-uri)
  (ok (var-get token-uri)))

;; --- Batch Transfer

(define-public (send-many (recipients (list 200 { to: principal, amount: uint, memo: (optional (buff 34)) })))
  (fold check-err (map send-token recipients) (ok true)))

(define-private (check-err (result (response bool uint)) (prior (response bool uint)))
  (match prior ok-value result err-value (err err-value)))

(define-private (send-token (recipient { to: principal, amount: uint, memo: (optional (buff 34)) }))
  (send-token-with-memo (get amount recipient) (get to recipient) (get memo recipient)))

(define-private (send-token-with-memo (amount uint) (to principal) (memo (optional (buff 34))))
  (let ((transferOk (try! (transfer amount tx-sender to memo))))
    (ok transferOk)))

;; --- Initial Mint

(ft-mint? hooter TOTAL-SUPPLY deployer)