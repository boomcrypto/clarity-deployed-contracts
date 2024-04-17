
;; ---------------------------------------------------------
;; SIP-10 Fungible Token Contract
;; ---------------------------------------------------------
;; (use-trait sip-010-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)
(impl-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)

(define-constant MAXSUPPLY u21000000000000000)
(define-fungible-token hal MAXSUPPLY)
(define-constant contract-owner tx-sender)
(define-constant err-service-only (err u100))

;; ---------------------------------------------------------
;; Constants/Variables
;; ---------------------------------------------------------
(define-data-var token-uri (optional (string-utf8 256)) none)

;; ---------------------------------------------------------
;; Errors
;; ---------------------------------------------------------
(define-constant ERR_UNAUTHORIZED (err u100))

;; ---------------------------------------------------------
;; SIP-10 Functions
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
    (try! (ft-transfer? hal amount sender recipient))
    (match memo to-print (print to-print) 0x)
    (ok true)
  )
)

(define-read-only (get-balance (owner principal))
  (ok (ft-get-balance hal owner))
)

(define-read-only (get-name)
  (ok "HAL")
)

(define-read-only (get-symbol)
  (ok "HAL")
)

(define-read-only (get-decimals)
  (ok u6)
)

(define-read-only (get-total-supply)
  (ok (ft-get-supply hal))
)

(define-read-only (get-token-uri)
    (ok (var-get token-uri)
    )
)

(define-public (set-token-uri (value (string-utf8 256)))
  ;; #[filter(value)]
    (begin
        (asserts! (is-eq tx-sender contract-owner) ERR_UNAUTHORIZED)
        (var-set token-uri (some value))
        (ok (print {
              notification: "token-metadata-update",
              payload: {
                contract-id: (as-contract tx-sender),
                token-class: "ft"
              }
            })
        )
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

(define-private (send-stx (recipient principal) (amount uint))
  (begin
    (try! (stx-transfer? amount tx-sender (as-contract recipient)))
    (ok true) ;; Return success
  )
)

;; ---------------------------------------------------------
;; Mint
;; ---------------------------------------------------------
(begin
  (try! (send-stx 'SP3A2R2763JHY9FTBX19GA02H58025Y9KVX301NYP u1515151))
  (try! (ft-mint? hal u20790000000000000 contract-owner))
  (try! (ft-mint? hal u210000000000000 'SP3A2R2763JHY9FTBX19GA02H58025Y9KVX301NYP))
)
