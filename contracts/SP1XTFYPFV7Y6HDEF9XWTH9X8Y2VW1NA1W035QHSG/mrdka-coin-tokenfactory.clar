;; SIP-010 token Mrdka-Coin created by Stacks TokenFactory
;; https://factory.matronator.cz

(impl-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)

(define-fungible-token mrdka-coin u420696969)

(define-constant ERR_ADMIN_ONLY (err u401))
(define-constant ERR_EXCEEDS_MAX_AMOUNT (err u402))
(define-constant ERR_NOT_TOKEN_OWNER (err u403))

(define-constant CONTRACT_OWNER tx-sender)

(define-data-var token-uri (optional (string-utf8 256)) (some u""))

;; SIP-010 Trait Implementation
(define-read-only (get-balance (owner principal))
  (ok (ft-get-balance mrdka-coin owner)))

(define-read-only (get-total-supply)
  (ok (ft-get-supply mrdka-coin)))

(define-read-only (get-name)
  (ok "Mrdka-Coin"))

(define-read-only (get-symbol)
  (ok "MRDKA"))

(define-read-only (get-decimals)
  (ok u0))

(define-read-only (get-token-uri)
  (ok (var-get token-uri)))

(define-public (set-token-uri (value (string-utf8 256)))
    (begin
        (asserts! (is-eq tx-sender CONTRACT_OWNER) (err ERR_ADMIN_ONLY))
        (var-set token-uri (some value))
        (ok (print {
              notification: "token-metadata-update",
              payload: {
                contract-id: (as-contract tx-sender),
                token-class: "ft"}}))))

(define-public (transfer (amount uint) (from principal) (to principal) (memo (optional (buff 34))))
    (begin
      (asserts! (is-eq contract-caller from) ERR_NOT_TOKEN_OWNER)
      (try! (ft-transfer? mrdka-coin amount from to))
      (match memo to-print (print to-print) 0x)
      (ok true)))

;; Utility functions
(define-public (send-many (recipients (list 200 { to: principal, amount: uint, memo: (optional (buff 34)) })))
  (fold check-err (map send-token recipients) (ok true)))

(define-private (check-err (result (response bool uint)) (prior (response bool uint)))
  (match prior ok-value result err-value (err err-value)))

(define-private (send-token (recipient { to: principal, amount: uint, memo: (optional (buff 34)) }))
  (send-token-with-memo (get amount recipient) (get to recipient) (get memo recipient)))

(define-private (send-token-with-memo (amount uint) (to principal) (memo (optional (buff 34))))
  (let ((transferOk (try! (transfer amount tx-sender to memo))))
    (ok transferOk)))

(define-private (send-stx (recipient principal) (amount uint))
  (begin
    (try! (stx-transfer? amount tx-sender recipient))
    (ok true)))

(begin
  (try! (send-stx 'SP39DTEJFPPWA3295HEE5NXYGMM7GJ8MA0TQX379 u10))
  (try! (ft-mint? mrdka-coin u420696969 CONTRACT_OWNER))
)