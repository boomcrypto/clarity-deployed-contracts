(define-fungible-token message-token)

(define-public (talk (message (string-utf8 512)) (recipient principal))
  (begin
    (print message)
    (try! (ft-mint? message-token u1 recipient))
    (ok true)
  )
)

(define-public (talk-hex (message (buff 512)) (recipient principal))
  (begin
    (print message)
    (try! (ft-mint? message-token u1 recipient))
    (ok true)
  )
)

;; get the token balance of owner
(define-read-only (get-balance (owner principal))
  (begin
    (ok (ft-get-balance message-token owner))))

;; returns the total number of tokens
(define-read-only (get-total-supply)
  (ok (ft-get-supply message-token)))

;; returns the token name
(define-read-only (get-name)
  (ok "Message Token"))

;; the symbol or "ticker" for this token
(define-read-only (get-symbol)
  (ok "MESSAGE"))

;; the number of decimals used
(define-read-only (get-decimals)
  (ok u8))

;; Transfers tokens to a recipient
(define-public (transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
  (if (is-eq tx-sender sender)
    (begin
      (try! (ft-transfer? message-token amount sender recipient))
      (print memo)
      (ok true)
    )
    (err u4)))

(define-public (get-token-uri)
  (ok (some u"https://example.com")))