;; title: sip010-ft
;; description: fungible token contract for test

;; traits
;; (impl-trait .sip010-ft-trait.sip-010-trait)

;; token definitions
;; no max total supply
(define-fungible-token test)

;; constants
(define-constant CONTRACT_OWNER tx-sender)

;; errors
(define-constant ERR_OWNER_ONLY (err u100))
(define-constant ERR_NOT_TOKEN_OWNER (err u101))
(define-constant ERR_TOKEN_ID_FAILURE (err u102))

;; public functions
(define-public (transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
  (begin
    (asserts! (is-eq tx-sender sender) ERR_NOT_TOKEN_OWNER)
    (try! (ft-transfer? test amount sender recipient))
    (match memo
      memo-value (print memo-value)
      0x
    )
    (ok true)
  )
)

(define-public (mint (amount uint) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_OWNER_ONLY)
    (ft-mint? test amount recipient)
  )
)

;; read only functions
(define-read-only (get-name)
  (ok "test")
)

(define-read-only (get-symbol)
  (ok "TST")
)

(define-read-only (get-decimals)
  (ok u6)
)

(define-read-only (get-balance (who principal))
  (ok (ft-get-balance test who))
)

(define-read-only (get-total-supply)
  (ok (ft-get-supply test))
)

(define-read-only (get-token-uri)
  (ok none)
)