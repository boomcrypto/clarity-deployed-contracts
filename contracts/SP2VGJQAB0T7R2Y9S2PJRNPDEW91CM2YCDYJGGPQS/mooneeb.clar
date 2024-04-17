;; ---------------------------------------------------------
;; SIP-10 Fungible Token Contract: Mooneeb
;; Destination: MOON
;; ---------------------------------------------------------

;; Implement the SIP-010 standard for fungible tokens
(impl-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)

(define-fungible-token mooneeb)

(define-constant contract-owner tx-sender)

(define-data-var token-uri (optional (string-utf8 256)) none)

(define-constant ERR_UNAUTHORIZED (err u100))

;; ---------------------------------------------------------
;; Core SIP-010 Functions
;; ---------------------------------------------------------
(define-public (transfer
  (amount uint)
  (sender principal)
  (recipient principal)
  (memo (optional (buff 34)))
)
  (begin
    ;; #[filter(amount, recipient)]
    (asserts! (is-eq tx-sender sender) ERR_UNAUTHORIZED)
    (try! (ft-transfer? mooneeb amount sender recipient))
    (match memo to-print (print to-print) 0x)
    (ok true)
  )
)

(define-read-only (get-balance (owner principal))
  (ok (ft-get-balance mooneeb owner))
)

(define-read-only (get-name)
  (ok "Mooneeb")
)

;; MOON, because where else are we going?
(define-read-only (get-symbol)
  (ok "MOON")
)

(define-read-only (get-decimals)
  (ok u6)
)

(define-read-only (get-total-supply)
  (ok (ft-get-supply mooneeb))
)

(define-read-only (get-token-uri)
    (ok (var-get token-uri)
    )
)

(define-public (set-token-uri (value (string-utf8 256)))
  ;; #[filter(value)]
  (if (is-eq tx-sender contract-owner)
    (ok (var-set token-uri (some value)))
    (err ERR_UNAUTHORIZED)
  )
)

;; ---------------------------------------------------------
;; Utility Functions
;; ---------------------------------------------------------

(define-public (send-many (recipients (list 200 { to: principal, amount: uint, memo: (optional (buff 34)) })))
  (fold check-err (map send-token recipients) (ok true))
)

(define-private (check-err (result (response bool uint)) (prior (response bool uint)))
  (match prior ok-value result err-value (err err-value))
)

(define-private (send-token (recipient { to: principal, amount: uint, memo: (optional (buff 34)) }))
  (send-token-with-memo (get amount recipient) (get to recipient) (get memo recipient))
)

(define-private (send-token-with-memo (amount uint) (to principal) (memo (optional (buff 34))))
  (let ((transferOk (try! (transfer amount tx-sender to memo))))
    (ok transferOk)
  )
)

;; ---------------------------------------------------------
;; Launch Sequence Initiated
;; ---------------------------------------------------------

(begin
  (try! (ft-mint? mooneeb u10000000000000000 contract-owner)) 
)