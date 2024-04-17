;; ---------------------------------------------------------
;; SIP-10 Fungible Token Contract
;; ---------------------------------------------------------
(impl-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)

(define-fungible-token goat)
(define-constant contract-creator tx-sender)

;; ---------------------------------------------------------
;; Errors
;; ---------------------------------------------------------
(define-constant ERR-UNAUTHORIZED (err u101))

;; ---------------------------------------------------------
;; Constants/Variables
;; ---------------------------------------------------------
(define-data-var token-uri (optional (string-utf8 256)) none)

;; ---------------------------------------------------------
;; SIP-10 Functions
;; ---------------------------------------------------------
(define-public (transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
    (begin
        (asserts! (is-eq tx-sender sender) ERR-UNAUTHORIZED)
        (try! (ft-transfer? goat amount sender recipient))
        (match memo to-print (print to-print) 0x)
        (ok true)))

(define-read-only (get-name)
    (ok "Goat"))

(define-read-only (get-symbol)
    (ok "GOAT"))

(define-read-only (get-decimals)
    (ok u6))

(define-read-only (get-balance (who principal))
    (ok (ft-get-balance goat who)))

(define-read-only (get-total-supply)
    (ok (ft-get-supply goat)))


(define-public (set-token-uri (value (string-utf8 256)))
  (if 
    (is-eq tx-sender contract-creator) 
        (ok (var-set token-uri (some value))) 
    (err ERR-UNAUTHORIZED)
  )
)

(define-read-only (get-token-uri)
  (ok (var-get token-uri))
)

;; ---------------------------------------------------------
;; Utility Functions
;; ---------------------------------------------------------
(define-public (send-many (recipients (list 200 { to: principal, amount: uint, memo: (optional (buff 34)) })))
  (fold check-err
    (map send-token recipients)
    (ok true)
  )
)

(define-private (check-err (result (response bool uint)) (prior (response bool uint)))
  (match prior ok-value result
               err-value (err err-value)
  )
)

(define-private (send-token (recipient { to: principal, amount: uint, memo: (optional (buff 34)) }))
  (send-token-with-memo (get amount recipient) (get to recipient) (get memo recipient))
)

(define-private (send-token-with-memo (amount uint) (to principal) (memo (optional (buff 34))))
  (let
    ((transferOk (try! (transfer amount tx-sender to memo))))
    (ok transferOk)
  )
)

;; ---------------------------------------------------------
;; Mint Supply 10B
;; --------------------------------------------------------- 
(begin
  (try! (ft-mint? goat u10000000000000000 contract-creator)) 
)
