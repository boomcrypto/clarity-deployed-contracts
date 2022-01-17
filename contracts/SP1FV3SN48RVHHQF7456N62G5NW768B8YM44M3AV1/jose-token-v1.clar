(impl-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)

(define-fungible-token jose-token)

(define-constant ERR-NOT-AUTHORIZED u401)
(define-constant ERR-SENDER-MISMATCH u4)

(define-constant CONTRACT-DEPLOYER tx-sender)

;; get the token balance of owner
(define-read-only (get-balance (owner principal))
  (begin
    (ok (ft-get-balance jose-token owner))))

;; returns the total number of tokens
(define-read-only (get-total-supply)
  (ok (ft-get-supply jose-token)))

;; returns the token name
(define-read-only (get-name)
  (ok "Jose Token"))

;; the symbol or "ticker" for this token
(define-read-only (get-symbol)
  (ok "JOSE"))

;; the number of decimals used
(define-read-only (get-decimals)
  (ok u8))

;; Transfers tokens to a recipient
(define-public (transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
  (if (is-eq tx-sender sender)
    (begin
      (try! (ft-transfer? jose-token amount sender recipient))
      (print memo)
      (ok true)
    )
    (err ERR-SENDER-MISMATCH)))

(define-public (get-token-uri)
  (ok (some u"https://josesoto.com/stacks-jose.json")))

(define-public (mint (amount uint) (recipient principal))
  (if (is-eq tx-sender CONTRACT-DEPLOYER)
    (ft-mint? jose-token amount recipient)
  (err ERR-NOT-AUTHORIZED))
)

(ft-mint? jose-token u1000000000000000 tx-sender)