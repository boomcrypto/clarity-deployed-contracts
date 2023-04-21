;; Satoshi's Inu
;; https://twitter.com/SatoshisInu

(define-constant ERR-UNAUTHORIZED u1)
(define-fungible-token satoshisinu)
(define-data-var token-uri (optional (string-utf8 256)) none)
(define-constant contract-creator tx-sender)
(impl-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)

;; SIP-010 Standard

(define-public (transfer (amount uint) (from principal) (to principal) (memo (optional (buff 34))))
    (begin
        (asserts! (is-eq from tx-sender)
            (err ERR-UNAUTHORIZED))

        (ft-transfer? satoshisinu amount from to)
    )
)

(define-read-only (get-name)
    (ok "Satoshi's Inu")
)

(define-read-only (get-symbol)
    (ok "SATNU")
)

(define-read-only (get-decimals)
    (ok u8)
)

(define-read-only (get-balance (user principal))
    (ok (ft-get-balance satoshisinu user)
    )
)

(define-read-only (get-total-supply)
    (ok (ft-get-supply satoshisinu)
    )
)

(define-public (set-token-uri (value (string-utf8 256)))
    (if 
        (is-eq tx-sender contract-creator) 
            (ok (var-set token-uri (some value))) 
        (err ERR-UNAUTHORIZED)
    )
)

(define-read-only (get-token-uri)
    (ok (var-get token-uri)
    )
)

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

(begin
  (try! (ft-mint? satoshisinu u210000000000000000000000 contract-creator))
  (set-token-uri u"https://d3s7y1fcxf7lb5.cloudfront.net/satoshis-inu.json")
)
