(impl-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)

(define-fungible-token friedger)
(define-constant ctr-dplyr tx-sender)

;; get the token balance of owner
(define-read-only (get-balance (owner principal))
  (ok (ft-get-balance friedger owner)))

;; returns the total number of tokens
(define-read-only (get-total-supply)
  (ok (ft-get-supply friedger)))

;; returns the token name
(define-read-only (get-name)
  (ok "Friedger Token"))

;; the symbol or "ticker" for this token
(define-read-only (get-symbol)
  (ok "FRIE"))

;; the number of decimals used
(define-read-only (get-decimals)
  (ok u6))

;; Transfers tokens to a recipient
(define-public (transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
  (if (is-eq tx-sender sender)
    (begin
      (try! (ft-transfer? friedger amount sender recipient))
      (print memo)
      (ok true)
    )
    (err u4)))

(define-public (get-token-uri)
  (ok (some u"https://friedger.de/stacks-frie.json")))

;; Mint 1 micro FRIE for 1 uSTX
(define-public (mint (ufriedger uint))
  (begin
    (try! (stx-transfer? ufriedger tx-sender ctr-dplyr))
    (ft-mint? friedger ufriedger tx-sender)))
