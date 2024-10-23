(impl-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)
(define-constant ERR-UNAUTHORIZED (err u401))
(define-fungible-token viking)
(define-data-var token-uri (optional (string-utf8 256)) (some u"https://raw.githubusercontent.com/VIKITOKEN/Vkg/main/viking.json"))
(define-data-var contract-owner principal tx-sender)
(define-constant TOKEN_NAME "Viking")
(define-constant TOKEN_SYMBOL "VIKI")
(define-constant TOKEN_DECIMALS u6) 

;; SIP-010 Standard
(define-public (transfer
  (amount uint)
  (sender principal)
  (recipient principal)
  (memo (optional (buff 34)))
)
  (begin
    ;; #[filter(amount, recipient)]
    (asserts! (is-eq tx-sender sender) ERR-UNAUTHORIZED)
    (try! (ft-transfer? viking amount sender recipient))
    (match memo to-print (print to-print) 0x)
    (ok true)
  )
)


(define-read-only (get-name)
    (ok TOKEN_NAME)
)

(define-read-only (get-symbol)
    (ok TOKEN_SYMBOL)
)

(define-read-only (get-decimals)
    (ok TOKEN_DECIMALS)
)

(define-read-only (get-balance (user principal))
    (ok (ft-get-balance viking user)
    )
)

(define-read-only (get-total-supply)
    (ok (ft-get-supply viking)
    )
)

(define-public (set-token-uri (value (string-utf8 256)))
    (if 
        (is-eq tx-sender (var-get contract-owner)) 
            (ok (var-set token-uri (some value))) 
        (err ERR-UNAUTHORIZED)
    )
)

(define-read-only (get-token-uri)
    (ok (var-get token-uri)
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

(define-public (burn 
(amount uint)
(sender principal))
  (begin
    (asserts! (is-eq tx-sender sender) ERR-UNAUTHORIZED)
    (try! (ft-burn? viking amount sender))
    (ok true)
  )
)


(begin
  (try! (ft-mint? viking u1000000000000000 (var-get contract-owner))
)
)