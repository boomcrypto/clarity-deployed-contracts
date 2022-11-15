(impl-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)

(define-constant TOTAL-SUPPLY u100000000)
(define-fungible-token token TOTAL-SUPPLY)
(define-constant contract-creator tx-sender)
(define-data-var token-uri (optional (string-utf8 256)) none)
(define-data-var token-name  (string-ascii 32) "NAME")
(define-data-var token-symbol (string-ascii 32) "SYMBOL")
(define-constant ERR-UNAUTHORIZED u1)

(define-read-only (get-balance (user principal))
  (ok (ft-get-balance token user)))

(define-read-only (get-caller-balance)
  (begin
    (ok (ft-get-balance token tx-sender))))

(define-read-only (get-total-supply)
  (ok (ft-get-supply token)))

(define-read-only (get-name)
    (ok (var-get token-name)))

(define-read-only (get-symbol)
  (ok (var-get token-symbol)))

(define-read-only (get-decimals)
  (ok u0))

(define-public (transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
  (begin
    (asserts! (is-eq tx-sender sender) (err u4))
    (try! (ft-transfer? token amount sender recipient))
    (print memo)
    (ok true)))

(define-public (set-token-uri (value (string-utf8 256)))
  (if (is-eq tx-sender contract-creator) 
    (ok (var-set token-uri (some value))) 
    (err ERR-UNAUTHORIZED)))

(define-public (set-token-name (value (string-ascii 32)))
  (if (is-eq tx-sender contract-creator) 
    (ok (var-set token-name value)) 
    (err ERR-UNAUTHORIZED)))

(define-public (set-token-symbol (value (string-ascii 32)))
  (if (is-eq tx-sender contract-creator) 
    (ok (var-set token-symbol value)) 
    (err ERR-UNAUTHORIZED)))

(define-read-only (get-token-uri)
  (ok (var-get token-uri)))
    
(ft-mint? token u100000000 'SP3775PSEYXAF7810KCGHT9F2SZ8ACVG2AWBNCRJF)