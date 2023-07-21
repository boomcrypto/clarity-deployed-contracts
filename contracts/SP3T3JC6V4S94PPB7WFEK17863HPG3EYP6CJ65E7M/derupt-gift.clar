;; Derupt Giftable Fungible Tokens

(define-constant ERR-UNAUTHORIZED (err u1))
(define-fungible-token gift u44440000)
(define-data-var token-uri (optional (string-utf8 256)) (some u"https://derupt.io/gift.json"))
(define-constant contract-creator tx-sender)
(impl-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)

(define-map crypto-bros (string-ascii 11) principal)

;; SIP-010 Standard

(define-public (transfer (amount uint) (from principal) (to principal) (memo (optional (buff 34))))
  (begin
    (asserts! (is-eq from tx-sender) ERR-UNAUTHORIZED)
    (if (is-some memo)
      (print memo)
      none
    )
    (ft-transfer? gift amount from to)
  )
)

(define-read-only (get-name)
    (ok "gift")
)

(define-read-only (get-symbol)
    (ok "GIFT")
)

(define-read-only (get-decimals)
    (ok u0)
)

(define-read-only (get-balance (user principal))
    (ok (ft-get-balance gift user)
    )
)

(define-read-only (get-total-supply)
    (ok (ft-get-supply gift)
    )
)

(define-public (set-token-uri (value (string-utf8 256)))
    (if 
        (is-eq tx-sender contract-creator) 
        (ok (var-set token-uri (some value))) 
        ERR-UNAUTHORIZED
    )
)

(define-read-only (get-token-uri)
    (ok (var-get token-uri)
    )
)

;; send-many

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

(define-public (obtain (obtain-amount uint)) 
  (let 
    (
      (stx-amount (* obtain-amount u10000))
    ) 
    (try! (stx-transfer? (/ stx-amount u2) tx-sender (unwrap! (map-get? crypto-bros "cryptodude") ERR-UNAUTHORIZED)))
    (try! (stx-transfer? (/ stx-amount u2) tx-sender (unwrap! (map-get? crypto-bros "cryptosmith") ERR-UNAUTHORIZED)))
    (try! (ft-mint? gift obtain-amount tx-sender))
    (ok true)
  )
)

(define-public (update-crypto-bros (bro (string-ascii 11)) (new-bro principal))        
    (begin 
      (asserts! (is-eq (unwrap! (map-get? crypto-bros bro) ERR-UNAUTHORIZED) tx-sender) ERR-UNAUTHORIZED)
      (ok (map-set crypto-bros bro new-bro))
    )
)

(define-public (view-crypto-bros (bro (string-ascii 11))) 
  (ok (unwrap! (map-get? crypto-bros bro) ERR-UNAUTHORIZED))
)

(map-insert crypto-bros "cryptodude" 'SP2BZ2YP68CABE7D32HE6308P6C7GMYN2ECJM8A7P)
(map-insert crypto-bros "cryptosmith" 'SPT4SQP5RC1BFAJEQKBHZMXQ8NQ7G118F335BD85)

;; AirDrop GIFT to Derupt Founders

(begin
  (try! (ft-mint? gift u2220000 (unwrap! (map-get? crypto-bros "cryptodude") ERR-UNAUTHORIZED)))  ;; cryptodude.btc
  (try! (ft-mint? gift u2220000 (unwrap! (map-get? crypto-bros "cryptosmith") ERR-UNAUTHORIZED))) ;; cryptosmith.btc                
)